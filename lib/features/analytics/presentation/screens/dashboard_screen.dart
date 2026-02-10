import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:storelytics/core/extensions.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:storelytics/features/sales/presentation/providers/sales_providers.dart';
import 'package:storelytics/features/store/presentation/providers/store_providers.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';
import 'package:storelytics/theme/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final storeAsync = ref.watch(currentStoreProvider);

    return userAsync.when(
      loading:
          () => const Scaffold(
            body: AppLoadingWidget(message: 'Initializing Dashboard...'),
          ),
      error: (e, _) => Scaffold(body: AppErrorWidget(message: e.toString())),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final storeId = user.storeId ?? '';

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, storeAsync),
          body:
              storeId.isEmpty
                  ? const EmptyStateWidget(
                    icon: Icons.store,
                    title: 'No Store Linked',
                    subtitle: 'Connect your business to generate insights.',
                  )
                  : Stack(
                    children: [
                      // Premium Brand Header
                      Container(
                        height: 380,
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

                      RefreshIndicator(
                        color: AppColors.secondary,
                        onRefresh: () async {
                          ref.invalidate(todaySalesProvider(storeId));
                          ref.invalidate(weeklySalesProvider(storeId));
                          ref.invalidate(lowStockItemsProvider(storeId));
                          ref.invalidate(expiringItemsProvider(storeId));
                        },
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 120),
                            ),

                            // Operational Intelligence
                            SliverToBoxAdapter(
                              child: _TodayStats(storeId: storeId),
                            ),

                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),

                            // Analytical Sections
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  _WeeklyChart(storeId: storeId),
                                  const SizedBox(height: 32),
                                  _buildSectionHeader('CRITICAL SIGNALS'),
                                  const SizedBox(height: 16),
                                  _AlertsSection(storeId: storeId),
                                  const SizedBox(height: 32),
                                  _buildSectionHeader(
                                    'MASTER CATALOG PERFORMANCE',
                                  ),
                                  const SizedBox(height: 16),
                                  _TopItemsSection(storeId: storeId),
                                  const SizedBox(
                                    height: 120,
                                  ), // Navbar Clearance
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AsyncValue storeAsync,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 24,
            errorBuilder:
                (_, __, ___) => const Text(
                  'INTELLIGENCE HUB',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
          ),
          storeAsync.maybeWhen(
            data:
                (store) => Text(
                  store?.storeName.toUpperCase() ?? 'UNLINKED STORE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
            onPressed: () {},
          ),
        ),
      ],
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
}

class _TodayStats extends ConsumerWidget {
  final String storeId;
  const _TodayStats({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(todayRevenueProvider(storeId));
    final profitAsync = ref.watch(todayProfitProvider(storeId));
    final itemCountAsync = ref.watch(itemCountProvider(storeId));
    final salesAsync = ref.watch(todaySalesProvider(storeId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Operational Pulse",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white60,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _PulseCard(
                  label: "REVENUE",
                  value: revenueAsync.maybeWhen(
                    data: (v) => v.toCurrency,
                    orElse: () => '...',
                  ),
                  icon: Icons.insights_rounded,
                  color: AppColors.secondary,
                  isBright: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PulseCard(
                  label: "PROFIT",
                  value: profitAsync.maybeWhen(
                    data: (v) => v.toCurrency,
                    orElse: () => '...',
                  ),
                  icon: Icons.trending_up_rounded,
                  color: AppColors.profit,
                  isBright: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PulseCard(
                  label: "CATALOG SIZE",
                  value: itemCountAsync.maybeWhen(
                    data: (v) => v.toString(),
                    orElse: () => '...',
                  ),
                  icon: Icons.inventory_2_rounded,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PulseCard(
                  label: "TRANSACTIONS",
                  value: salesAsync.maybeWhen(
                    data: (v) => v.length.toString(),
                    orElse: () => '...',
                  ),
                  icon: Icons.article_rounded,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isBright;

  const _PulseCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isBright = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isBright
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends ConsumerWidget {
  final String storeId;
  const _WeeklyChart({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeklySalesAsync = ref.watch(weeklySalesProvider(storeId));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Velocity Matrix',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Text(
                'LAST 7 DAYS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade500,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: weeklySalesAsync.when(
              loading: () => const AppLoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString()),
              data: (sales) {
                final Map<int, double> dailyRevenue = {};
                final now = DateTime.now();
                for (int i = 0; i < 7; i++) dailyRevenue[i] = 0;
                for (final sale in sales) {
                  final daysAgo = now.difference(sale.date).inDays;
                  if (daysAgo >= 0 && daysAgo < 7) {
                    dailyRevenue[daysAgo] =
                        (dailyRevenue[daysAgo] ?? 0) + sale.revenue;
                  }
                }

                final spots = List.generate(7, (i) {
                  return FlSpot(i.toDouble(), dailyRevenue[6 - i] ?? 0);
                });

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5000,
                      getDrawingHorizontalLine:
                          (v) => FlLine(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.03),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final day = now.subtract(
                              Duration(days: (6 - value.toInt())),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                DateFormat('E').format(day).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppColors.secondary,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withValues(alpha: 0.2),
                              AppColors.secondary.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsSection extends ConsumerWidget {
  final String storeId;
  const _AlertsSection({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockItemsProvider(storeId));
    final expiringAsync = ref.watch(expiringItemsProvider(storeId));

    return Column(
      children: [
        lowStockAsync.maybeWhen(
          data:
              (items) =>
                  items.isEmpty
                      ? const SizedBox.shrink()
                      : _SignalTile(
                        title: '${items.length} DEPLETED SKU DETECTED',
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.loss,
                        message: 'Immediate restock required',
                        onTap: () => context.go('/inventory'),
                      ),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        expiringAsync.maybeWhen(
          data:
              (items) =>
                  items.isEmpty
                      ? const SizedBox.shrink()
                      : _SignalTile(
                        title: '${items.length} OBSOLESCENCE RISK',
                        icon: Icons.event_busy_rounded,
                        color: AppColors.warning,
                        message: 'Items nearing expiration threshold',
                        onTap: () => context.go('/inventory'),
                      ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SignalTile extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SignalTile({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopItemsSection extends ConsumerWidget {
  final String storeId;
  const _TopItemsSection({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salesByItemAsync = ref.watch(salesByItemProvider(storeId));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: salesByItemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (salesByItem) {
          if (salesByItem.isEmpty)
            return const Center(child: Text('No analytical data yet.'));

          final sorted =
              salesByItem.entries.toList()..sort((a, b) {
                final aQty = a.value.fold(0, (sum, s) => sum + s.quantity);
                final bQty = b.value.fold(0, (sum, s) => sum + s.quantity);
                return bQty.compareTo(aQty);
              });

          final topItems = sorted.take(5).toList();

          return Column(
            children:
                topItems.map((entry) {
                  final totalQty = entry.value.fold(
                    0,
                    (sum, s) => sum + s.quantity,
                  );
                  final itemName = entry.value.first.itemName;
                  final index = topItems.indexOf(entry);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$totalQty TRANSACTIONS',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.show_chart_rounded,
                          color: AppColors.profit,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
