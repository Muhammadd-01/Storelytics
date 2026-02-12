import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/auth/data/models/user_model.dart';
import 'package:storelytics/features/store/presentation/providers/store_providers.dart';
import 'package:storelytics/core/enums.dart';
import 'package:storelytics/theme/app_colors.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                      // Store Management
                      Text(
                        'STORE MANAGEMENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white38 : Colors.black38,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ActionButton(
                        onPressed: () => _showStoreSwitcher(context, ref, user),
                        icon: Icons.sync_rounded,
                        label: 'SWITCH STORE',
                        isPrimary: true,
                      ),
                      const SizedBox(height: 12),
                      _ActionButton(
                        onPressed: () => context.push('/store-setup'),
                        icon: Icons.add_business_rounded,
                        label: 'ADD NEW STORE',
                        isPrimary: false,
                      ),

                      const SizedBox(height: 32),
                      Text(
                        'ACCOUNT SETTINGS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white38 : Colors.black38,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _ActionButton(
                        onPressed: () => context.push('/edit-profile'),
                        icon: Icons.edit_note_rounded,
                        label: 'UPDATE INFO',
                        isPrimary: true,
                      ),
                      const SizedBox(height: 12),

                      if (user.role == UserRole.admin) ...[
                        _ActionButton(
                          onPressed: () => context.push('/admin'),
                          icon: Icons.admin_panel_settings_rounded,
                          label: 'ADMIN CONSOLE',
                          isPrimary: false,
                        ),
                        const SizedBox(height: 12),
                      ],

                      _ActionButton(
                        onPressed: () async {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) context.go('/login');
                        },
                        icon: Icons.power_settings_new_rounded,
                        label: 'LOGOUT',
                        isDangerous: true,
                      ),

                      const SizedBox(height: 150), // Navbar Clearance
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

  void _showStoreSwitcher(BuildContext context, WidgetRef ref, UserModel user) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Switch Active Store',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select which store you want to manage right now.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ref
                    .watch(userStoresProvider)
                    .when(
                      loading: () => const Center(child: AppLoadingWidget()),
                      error: (e, _) => Center(child: Text(e.toString())),
                      data: (stores) {
                        if (stores.isEmpty) {
                          return const Center(child: Text('No stores found'));
                        }
                        return Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: stores.length,
                            itemBuilder: (context, index) {
                              final store = stores[index];
                              final isCurrent =
                                  store.storeId == user.currentStoreId;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      isCurrent
                                          ? AppColors.secondary
                                          : Colors.grey.withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.store_rounded,
                                    color:
                                        isCurrent ? Colors.white : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  store.storeName,
                                  style: TextStyle(
                                    fontWeight:
                                        isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  store.storeType.label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing:
                                    isCurrent
                                        ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.secondary,
                                        )
                                        : null,
                                onTap: () async {
                                  if (!isCurrent) {
                                    final updatedUser = user.copyWith(
                                      currentStoreId: store.storeId,
                                    );
                                    await ref
                                        .read(authRepositoryProvider)
                                        .updateUser(updatedUser);
                                    ref.invalidate(currentUserProvider);
                                    ref.invalidate(currentStoreProvider);
                                  }
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
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
                (user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null)
                    as ImageProvider?,
            child:
                user.profileImageUrl == null
                    ? Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.5),
                    )
                    : null,
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
