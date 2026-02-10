import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers.dart';
import '../theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(totalUsersCountProvider);
    final activeAsync = ref.watch(activeUsersCountProvider);
    final storesAsync = ref.watch(totalStoresCountProvider);
    final revenueAsync = ref.watch(platformRevenueProvider);
    final profitAsync = ref.watch(platformProfitProvider);
    final salesAsync = ref.watch(platformSalesProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color:
                    isDark
                        ? AdminColors.darkTextPrimary
                        : AdminColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time metrics across all stores',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // ── Stat Cards ──
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  icon: Icons.people_outline,
                  label: 'Total Users',
                  value: usersAsync.when(
                    data: (v) => '$v',
                    loading: () => '...',
                    error: (_, __) => '--',
                  ),
                  color: AdminColors.accent,
                  isDark: isDark,
                ),
                _StatCard(
                  icon: Icons.verified_user_outlined,
                  label: 'Active Users',
                  value: activeAsync.when(
                    data: (v) => '$v',
                    loading: () => '...',
                    error: (_, __) => '--',
                  ),
                  color: AdminColors.profit,
                  isDark: isDark,
                ),
                _StatCard(
                  icon: Icons.store_outlined,
                  label: 'Total Stores',
                  value: storesAsync.when(
                    data: (v) => '$v',
                    loading: () => '...',
                    error: (_, __) => '--',
                  ),
                  color: AdminColors.secondary,
                  isDark: isDark,
                ),
                _StatCard(
                  icon: Icons.attach_money,
                  label: 'Platform Revenue',
                  value: revenueAsync.when(
                    data: (v) => _formatCurrency(v),
                    loading: () => '...',
                    error: (_, __) => '--',
                  ),
                  color: AdminColors.warning,
                  isDark: isDark,
                ),
                _StatCard(
                  icon: Icons.trending_up,
                  label: 'Platform Profit',
                  value: profitAsync.when(
                    data: (v) => _formatCurrency(v),
                    loading: () => '...',
                    error: (_, __) => '--',
                  ),
                  color: AdminColors.profit,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Revenue Chart ──
            Text(
              'Revenue by Day (Last 7 Days)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isDark
                        ? AdminColors.darkTextPrimary
                        : AdminColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: salesAsync.when(
                data: (sales) => _buildRevenueChart(sales, isDark),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: 32),

            // ── Low Stock Alerts ──
            _LowStockSection(isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<dynamic> sales, bool isDark) {
    final now = DateTime.now();
    final Map<int, double> dailyRevenue = {};
    for (int i = 6; i >= 0; i--) {
      dailyRevenue[i] = 0;
    }
    for (final sale in sales) {
      final diff = now.difference(sale.date).inDays;
      if (diff >= 0 && diff < 7) {
        dailyRevenue[diff] = (dailyRevenue[diff] ?? 0) + sale.revenue;
      }
    }

    final spots = List.generate(7, (i) {
      final dayIndex = 6 - i;
      return FlSpot(i.toDouble(), dailyRevenue[dayIndex] ?? 0);
    });

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
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
              getTitlesWidget: (val, _) {
                final date = now.subtract(Duration(days: 6 - val.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat.E().format(date),
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isDark
                              ? AdminColors.darkTextSecondary
                              : AdminColors.lightTextSecondary,
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
            color: AdminColors.secondary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, _, __, ___) => FlDotCirclePainter(
                    radius: 4,
                    color: AdminColors.secondary,
                    strokeWidth: 2,
                    strokeColor: isDark ? AdminColors.darkCard : Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AdminColors.secondary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class _LowStockSection extends ConsumerWidget {
  final bool isDark;
  const _LowStockSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockItemsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Low Stock Alerts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isDark
                    ? AdminColors.darkTextPrimary
                    : AdminColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        lowStockAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'All items well-stocked ✅',
                      style: TextStyle(
                        color:
                            isDark
                                ? AdminColors.darkTextSecondary
                                : AdminColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length > 10 ? 10 : items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    leading: Icon(
                      item.isOutOfStock
                          ? Icons.error_outline
                          : Icons.warning_amber_rounded,
                      color:
                          item.isOutOfStock
                              ? AdminColors.loss
                              : AdminColors.warning,
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${item.stockQuantity} left • Min: ${item.minStockLevel}',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (item.isOutOfStock
                                ? AdminColors.loss
                                : AdminColors.warning)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.isOutOfStock ? 'OUT' : 'LOW',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color:
                              item.isOutOfStock
                                  ? AdminColors.loss
                                  : AdminColors.warning,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color:
                      isDark
                          ? AdminColors.darkTextPrimary
                          : AdminColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark
                          ? AdminColors.darkTextSecondary
                          : AdminColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
