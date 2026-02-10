import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelytics/core/constants.dart';
import 'package:storelytics/core/enums.dart';
import 'package:storelytics/core/extensions.dart';
import 'package:storelytics/features/auth/data/models/user_model.dart';
import 'package:storelytics/features/store/data/models/store_model.dart';
import 'package:storelytics/features/store/presentation/providers/store_providers.dart';
import 'package:storelytics/features/sales/presentation/providers/sales_providers.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';
import 'package:storelytics/theme/app_colors.dart';

// ── Admin Providers ──
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .get();
  return snapshot.docs.map((d) => UserModel.fromMap(d.data())).toList();
});

final platformRevenueProvider = FutureProvider<double>((ref) async {
  final sales = await ref.read(salesRepositoryProvider).getAllSales();
  return sales.fold<double>(0.0, (s, e) => s + e.revenue);
});

// ── Admin Dashboard Screen ──
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final storesAsync = ref.watch(allStoresProvider);
    final revenueAsync = ref.watch(platformRevenueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              onPressed: () => context.go('/profile'),
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 24,
              errorBuilder:
                  (_, __, ___) => const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ADMIN PANEL',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              ref.invalidate(allUsersProvider);
              ref.invalidate(allStoresProvider);
              ref.invalidate(platformRevenueProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Header Background
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allUsersProvider);
              ref.invalidate(allStoresProvider);
              ref.invalidate(platformRevenueProvider);
            },
            displacement: 100,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 110, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Platform Analytics',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Premium Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _AdminStatCard(
                                label: 'TOTAL USERS',
                                value: usersAsync.maybeWhen(
                                  data: (v) => '${v.length}',
                                  orElse: () => '...',
                                ),
                                icon: Icons.people_alt_rounded,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _AdminStatCard(
                                label: 'TOTAL STORES',
                                value: storesAsync.maybeWhen(
                                  data: (v) => '${v.length}',
                                  orElse: () => '...',
                                ),
                                icon: Icons.store_mall_directory_rounded,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _AdminStatCard(
                                label: 'ACTIVE NOW',
                                value: usersAsync.maybeWhen(
                                  data:
                                      (v) =>
                                          '${v.where((u) => u.isActive).length}',
                                  orElse: () => '...',
                                ),
                                icon: Icons.shutter_speed_rounded,
                                color: AppColors.profit,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _AdminStatCard(
                                label: 'PLATFORM REV',
                                value: revenueAsync.maybeWhen(
                                  data: (v) => v.toCurrency,
                                  orElse: () => '...',
                                ),
                                icon: Icons.account_balance_wallet_rounded,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Sections
                        _AdminSectionHeader(
                          title: 'REGISTERED STORES',
                          count: storesAsync.maybeWhen(
                            data: (v) => v.length,
                            orElse: () => 0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        storesAsync.when(
                          loading: () => const AppLoadingWidget(),
                          error:
                              (e, _) => AppErrorWidget(message: e.toString()),
                          data:
                              (stores) =>
                                  stores.isEmpty
                                      ? const Text('No stores found')
                                      : Column(
                                        children:
                                            stores
                                                .map(
                                                  (s) => _StoreDetailTile(
                                                    store: s,
                                                  ),
                                                )
                                                .toList(),
                                      ),
                        ),

                        const SizedBox(height: 40),

                        _AdminSectionHeader(
                          title: 'USER MANAGEMENT',
                          count: usersAsync.maybeWhen(
                            data: (v) => v.length,
                            orElse: () => 0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        usersAsync.when(
                          loading: () => const AppLoadingWidget(),
                          error:
                              (e, _) => AppErrorWidget(message: e.toString()),
                          data:
                              (users) => Column(
                                children:
                                    users
                                        .map(
                                          (u) => _UserDetailTile(
                                            user: u,
                                            ref: ref,
                                          ),
                                        )
                                        .toList(),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _AdminSectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count total',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreDetailTile extends StatelessWidget {
  final StoreModel store;
  const _StoreDetailTile({required this.store});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            child: Icon(
              store.storeType == StoreType.pharmacy
                  ? Icons.medical_services_rounded
                  : Icons.store_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${store.storeType.label} • ${store.address}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

class _UserDetailTile extends StatelessWidget {
  final UserModel user;
  final WidgetRef ref;
  const _UserDetailTile({required this.user, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          _UserAvatar(user: user),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(label: user.role.label, color: Colors.blue),
                    const SizedBox(width: 4),
                    _Badge(
                      label: user.subscriptionPlan.label,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: user.isActive,
            activeColor: AppColors.profit,
            onChanged: (v) async {
              await FirebaseFirestore.instance
                  .collection(AppConstants.usersCollection)
                  .doc(user.uid)
                  .update({'isActive': v});
              ref.invalidate(allUsersProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final UserModel user;
  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            user.isActive
                ? LinearGradient(
                  colors: [
                    AppColors.profit.withValues(alpha: 0.4),
                    AppColors.profit.withValues(alpha: 0.1),
                  ],
                )
                : LinearGradient(
                  colors: [
                    AppColors.loss.withValues(alpha: 0.4),
                    AppColors.loss.withValues(alpha: 0.1),
                  ],
                ),
      ),
      child: Center(
        child: Text(
          user.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: user.isActive ? AppColors.profit : AppColors.loss,
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
