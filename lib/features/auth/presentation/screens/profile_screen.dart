import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/auth/data/models/user_model.dart';
import 'package:storelytics/core/enums.dart';
import 'package:storelytics/shared/services/storage_service.dart';
import 'package:storelytics/theme/app_colors.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  XFile? _pickedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _handleSave(UserModel user) async {
    if (_pickedImage == null) return;

    setState(() => _isUploading = true);
    try {
      final storage = ref.read(storageServiceProvider);
      final repo = ref.read(authRepositoryProvider);

      final imageUrl = await storage.uploadProfileImage(
        file: _pickedImage!,
        userId: user.uid,
      );

      final updatedUser = user.copyWith(profileImageUrl: imageUrl);
      await repo.updateUser(updatedUser);
      ref.invalidate(currentUserProvider);

      setState(() => _pickedImage = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Identity parameters synchronized'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: AppColors.loss,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      loading: () => const AppLoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (user) {
        if (user == null) return const Center(child: Text('Identity Loss'));

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black26 : Colors.white60,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                  onPressed: () => context.go('/'),
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: isDark ? Colors.black26 : Colors.white60,
                child: IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                  onPressed: () => context.push('/settings'),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Hero Profile Section ──
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      child: Column(
                        children: [
                          _buildAvatar(user, isDark),
                          const SizedBox(height: 20),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            user.email.toLowerCase(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Status Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Badge(
                            label: user.role.label.toUpperCase(),
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          _Badge(
                            label: 'PREMIUM ACTIVE',
                            color: AppColors.profit,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Account Parameters
                      _ParameterCard(
                        icon: Icons.fingerprint_rounded,
                        label: 'STORE REGISTRY ID',
                        value: user.storeId ?? 'UNLINKED',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _ParameterCard(
                        icon: Icons.workspace_premium_rounded,
                        label: 'TIER ACCESS',
                        value: user.subscriptionPlan.label.toUpperCase(),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 48),

                      if (_pickedImage != null) ...[
                        _ActionButton(
                          onPressed:
                              _isUploading ? () {} : () => _handleSave(user),
                          icon: Icons.save_rounded,
                          label:
                              _isUploading
                                  ? 'SYNCHRONIZING...'
                                  : 'SAVE CHANGES',
                          isPrimary: true,
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (user.role == UserRole.admin) ...[
                        _ActionButton(
                          onPressed: () => context.push('/admin'),
                          icon: Icons.admin_panel_settings_rounded,
                          label: 'ADMIN CONSOLE',
                          isPrimary: _pickedImage == null,
                        ),
                        const SizedBox(height: 12),
                      ],

                      _ActionButton(
                        onPressed: () async {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) context.go('/login');
                        },
                        icon: Icons.power_settings_new_rounded,
                        label: 'TERMINATE SESSION',
                        isDangerous: true,
                      ),

                      const SizedBox(height: 120), // Navbar Clearance
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(UserModel user, bool isDark) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: 56,
            backgroundColor:
                isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            backgroundImage:
                _pickedImage != null
                    ? FileImage(io.File(_pickedImage!.path))
                    : (user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null)
                        as ImageProvider?,
            child:
                user.profileImageUrl == null && _pickedImage == null
                    ? Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.5),
                    )
                    : null,
          ),
        ),
        if (_isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: _isUploading ? null : _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.publish_rounded,
                size: 18,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ParameterCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _ParameterCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;
  final bool isDangerous;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDangerous
            ? AppColors.loss
            : (isPrimary ? AppColors.secondary : Colors.grey);
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
