import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:storelytics/core/validators.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/inventory/data/models/inventory_item_model.dart';
import 'package:storelytics/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:storelytics/shared/services/storage_service.dart';
import 'package:storelytics/shared/widgets/app_text_field.dart';
import 'package:storelytics/theme/app_colors.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  final InventoryItem? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _supplierController;
  late final TextEditingController _barcodeController;
  DateTime? _expiryDate;
  XFile? _image;
  bool _isLoading = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _categoryController = TextEditingController(text: item?.category ?? '');
    _purchasePriceController = TextEditingController(
      text:
          item?.purchasePrice == 0 ? '' : item?.purchasePrice.toString() ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: item?.sellingPrice == 0 ? '' : item?.sellingPrice.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: item?.stockQuantity.toString() ?? '',
    );
    _minStockController = TextEditingController(
      text: item?.minStockLevel.toString() ?? '10',
    );
    _supplierController = TextEditingController(text: item?.supplierName ?? '');
    _barcodeController = TextEditingController(text: item?.barcode ?? '');
    _expiryDate = item?.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _supplierController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) setState(() => _image = image);
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null || user.storeId == null)
        throw Exception('Identity validation failed');

      final repo = ref.read(inventoryRepositoryProvider);
      final storage = ref.read(storageServiceProvider);

      String? imageUrl = widget.item?.imageUrl;
      if (_image != null) {
        imageUrl = await storage.uploadItemImage(
          file: _image!,
          storeId: user.storeId!,
        );
      }

      final item = InventoryItem(
        itemId: widget.item?.itemId ?? const Uuid().v4(),
        storeId: user.storeId!,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        purchasePrice: double.parse(_purchasePriceController.text.trim()),
        sellingPrice: double.parse(_sellingPriceController.text.trim()),
        stockQuantity: int.parse(_stockController.text.trim()),
        minStockLevel: int.parse(_minStockController.text.trim()),
        expiryDate: _expiryDate,
        supplierName: _supplierController.text.trim(),
        barcode:
            _barcodeController.text.trim().isEmpty
                ? null
                : _barcodeController.text.trim(),
        imageUrl: imageUrl,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await repo.updateItem(item);
      } else {
        await repo.addItem(item);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.loss,
            behavior: SnackBarBehavior.floating,
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
        title: Text(
          _isEditing ? 'REDEFINE PRODUCT' : 'CATALOG NEW PRODUCT',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageUploader(isDark),
              const SizedBox(height: 40),

              _buildSectionHeader('CORE SPECIFICATIONS'),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                label: 'PRODUCT NAME',
                hint: 'Enter item designation',
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _categoryController,
                label: 'CLASSIFICATION',
                hint: 'e.g. PHARMACEUTICALS',
                validator: (v) => Validators.required(v, 'Category'),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('FINANCIAL CALIBRATION'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _purchasePriceController,
                      label: 'PURCHASE COST',
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => Validators.positiveNumber(v, 'Cost'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _sellingPriceController,
                      label: 'SELLING VALUE',
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => Validators.positiveNumber(v, 'Price'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('INVENTORY DYNAMICS'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _stockController,
                      label: 'CURRENT STOCK',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.nonNegativeInt(v, 'Stock'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _minStockController,
                      label: 'CRITICAL LEVEL',
                      hint: '10',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.nonNegativeInt(v, 'Level'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('LOGISTICS & EXPIRY'),
              const SizedBox(height: 16),
              _buildExpiryPicker(isDark),
              const SizedBox(height: 16),
              AppTextField(
                controller: _supplierController,
                label: 'SUPPLIER AUTHORITY',
                hint: 'Designate source provider',
                validator: (v) => Validators.required(v, 'Supplier'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _barcodeController,
                label: 'BARCODE SYSTEM (OPTIONAL)',
                hint: 'Scan or input manually',
                prefixIcon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 60),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.secondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildImageUploader(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.1),
              width: 2,
            ),
            image:
                _image != null
                    ? DecorationImage(
                      image:
                          kIsWeb
                              ? NetworkImage(_image!.path)
                              : FileImage(File(_image!.path)) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                    : (widget.item?.imageUrl != null
                        ? DecorationImage(
                          image: NetworkImage(widget.item!.imageUrl!),
                          fit: BoxFit.cover,
                        )
                        : null),
          ),
          child:
              _image == null && widget.item?.imageUrl == null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_enhance_rounded,
                          size: 32,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'VISUAL ASSET UPLOAD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                  : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildExpiryPicker(bool isDark) {
    return InkWell(
      onTap: _pickExpiryDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.05,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_available_rounded,
              size: 22,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHELF LIFE EXPIRY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _expiryDate != null
                        ? DateFormat('MMMM dd, yyyy').format(_expiryDate!)
                        : 'UNSET (NO EXPIRY)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          _expiryDate != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
                : Text(
                  _isEditing ? 'UPDATE MASTER CATALOG' : 'COMPOSE NEW PRODUCT',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
      ),
    );
  }
}
