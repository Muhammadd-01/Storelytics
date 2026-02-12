import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:storelytics/core/enums.dart';
import 'package:storelytics/core/validators.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/store/data/models/store_model.dart';
import 'package:storelytics/features/store/presentation/providers/store_providers.dart';
import 'package:storelytics/shared/services/storage_service.dart';
import 'package:storelytics/shared/services/location_service.dart';
import 'package:storelytics/shared/widgets/app_text_field.dart';
import 'package:storelytics/theme/app_colors.dart';
import 'package:storelytics/theme/app_spacing.dart';

class StoreSetupScreen extends ConsumerStatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  ConsumerState<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends ConsumerState<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _nicController = TextEditingController();
  final _certificationController = TextEditingController();
  StoreType _storeType = StoreType.generalStore;
  bool _isLoading = false;

  XFile? _nicImage;
  XFile? _certificationImage;

  Future<void> _pickImage(bool isNic) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        if (isNic) {
          _nicImage = image;
        } else {
          _certificationImage = image;
        }
      });
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoading = true);
    try {
      final address = await LocationService.getCurrentAddress();
      _addressController.text = address;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.loss,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _nicController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not found');

      if (_nicImage == null || _certificationImage == null) {
        throw Exception(
          'Please upload both NIC and Certification images for verification.',
        );
      }

      final storeId = const Uuid().v4();
      String? nicUrl;
      String? certUrl;

      nicUrl = await ref
          .read(storageServiceProvider)
          .uploadStoreVerificationImage(
            file: _nicImage!,
            storeId: storeId,
            type: 'nic',
          );

      certUrl = await ref
          .read(storageServiceProvider)
          .uploadStoreVerificationImage(
            file: _certificationImage!,
            storeId: storeId,
            type: 'certification',
          );

      final store = StoreModel(
        storeId: storeId,
        storeName: _storeNameController.text.trim(),
        storeType: _storeType,
        ownerName: _ownerNameController.text.trim(),
        address: _addressController.text.trim(),
        ownerId: user.uid,
        ownerNic: _nicController.text.trim(),
        certificationNumber: _certificationController.text.trim(),
        nicImageUrl: nicUrl,
        certificationImageUrl: certUrl,
        createdAt: DateTime.now(),
      );

      await ref.read(storeRepositoryProvider).createStore(store);
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentStoreProvider);

      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.loss,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Store Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Store Type Grid
                    Text(
                      'Select Store Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemCount: StoreType.values.length,
                      itemBuilder: (context, index) {
                        final type = StoreType.values[index];
                        final isSelected = _storeType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _storeType = type),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.secondary.withValues(
                                        alpha: 0.1,
                                      )
                                      : (isDark
                                          ? AppColors.darkSurface
                                          : AppColors.lightSurface),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getStoreIcon(type),
                                  color:
                                      isSelected
                                          ? AppColors.secondary
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary),
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                    color:
                                        isSelected ? AppColors.secondary : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      controller: _storeNameController,
                      label: 'Store Name',
                      hint: 'e.g. Sunny Mart',
                      prefixIcon: const Icon(Icons.store_outlined, size: 20),
                      validator: (v) => Validators.required(v, 'Store name'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      controller: _certificationController,
                      label: 'Store Certification / License No.',
                      hint: 'e.g. REG-123456',
                      prefixIcon: const Icon(Icons.verified_outlined, size: 20),
                      validator:
                          (v) => Validators.required(v, 'Certification number'),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Owner Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      controller: _ownerNameController,
                      label: 'Owner Full Name',
                      hint: 'e.g. John Doe',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      validator: (v) => Validators.required(v, 'Owner name'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      controller: _nicController,
                      label: 'Owner NIC / ID Number',
                      hint: 'e.g. 12345-6789012-3',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                      validator: (v) => Validators.required(v, 'NIC number'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      controller: _addressController,
                      label: 'Store Address',
                      hint: 'e.g. 123 Main St, City',
                      maxLines: 2,
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        onPressed: _fetchLocation,
                        tooltip: 'Fetch Current Location',
                      ),
                      validator: (v) => Validators.required(v, 'Address'),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Verification Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildImagePicker(
                      label: 'Owner NIC Image',
                      image: _nicImage,
                      onTap: () => _pickImage(true),
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildImagePicker(
                      label: 'Store Certification Image',
                      image: _certificationImage,
                      onTap: () => _pickImage(false),
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSetup,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Complete Registration'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStoreIcon(StoreType type) {
    switch (type) {
      case StoreType.pharmacy:
        return Icons.local_pharmacy_outlined;
      case StoreType.grocery:
        return Icons.shopping_basket_outlined;
      case StoreType.electronics:
        return Icons.electrical_services_outlined;
      case StoreType.clothing:
        return Icons.checkroom_outlined;
      case StoreType.restaurant:
        return Icons.restaurant_outlined;
      case StoreType.generalStore:
        return Icons.storefront_outlined;
      case StoreType.other:
        return Icons.more_horiz_outlined;
    }
  }

  Widget _buildImagePicker({
    required String label,
    required XFile? image,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color:
                    image != null
                        ? AppColors.secondary
                        : (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                width: 1,
              ),
            ),
            child:
                image != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          kIsWeb
                              ? Image.network(image.path, fit: BoxFit.cover)
                              : Image.file(File(image.path), fit: BoxFit.cover),
                          Container(
                            color: Colors.black26,
                            child: const Center(
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload image',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }
}
