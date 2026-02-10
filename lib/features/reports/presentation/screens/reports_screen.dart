import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:storelytics/core/extensions.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:storelytics/features/sales/presentation/providers/sales_providers.dart';
import 'package:storelytics/features/demand/presentation/providers/demand_providers.dart';
import 'package:storelytics/features/store/presentation/providers/store_providers.dart';
import 'package:storelytics/theme/app_colors.dart';
import 'package:storelytics/theme/app_spacing.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate & Export Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color:
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Export detailed PDF reports for your business',
              style: TextStyle(
                fontSize: 13,
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ReportCard(
              icon: Icons.receipt_long,
              title: 'Monthly Sales Report',
              subtitle: 'Complete sales breakdown for the current month',
              color: AppColors.secondary,
              onTap: () => _generateSalesReport(context, ref),
            ),
            const SizedBox(height: AppSpacing.md),
            _ReportCard(
              icon: Icons.attach_money,
              title: 'Profit Summary Report',
              subtitle: 'Revenue, costs, and profit analysis',
              color: AppColors.profit,
              onTap: () => _generateProfitReport(context, ref),
            ),
            const SizedBox(height: AppSpacing.md),
            _ReportCard(
              icon: Icons.inventory_2,
              title: 'Inventory Report',
              subtitle: 'Current stock levels, alerts, and valuations',
              color: AppColors.primary,
              onTap: () => _generateInventoryReport(context, ref),
            ),
            const SizedBox(height: AppSpacing.md),
            _ReportCard(
              icon: Icons.trending_up,
              title: 'Demand Analysis Report',
              subtitle: 'Missing items and restock recommendations',
              color: AppColors.warning,
              onTap: () => _generateDemandReport(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateSalesReport(BuildContext context, WidgetRef ref) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null || user.storeId == null) return;
      final store = await ref.read(currentStoreProvider.future);
      final sales = await ref.read(monthlySalesProvider(user.storeId!).future);

      final totalRevenue = sales.fold(0.0, (s, e) => s + e.revenue);
      final totalCost = sales.fold(0.0, (s, e) => s + e.cost);
      final totalProfit = sales.fold(0.0, (s, e) => s + e.profit);

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header:
              (ctx) =>
                  _pdfHeader('Monthly Sales Report', store?.storeName ?? ''),
          build:
              (ctx) => [
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _pdfStatBox('Total Revenue', totalRevenue.toCurrency),
                    _pdfStatBox('Total Cost', totalCost.toCurrency),
                    _pdfStatBox('Total Profit', totalProfit.toCurrency),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Sales Details',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headers: ['Item', 'Qty', 'Revenue', 'Cost', 'Profit', 'Date'],
                  data:
                      sales
                          .map(
                            (s) => [
                              s.itemName,
                              '${s.quantity}',
                              s.revenue.toCurrency,
                              s.cost.toCurrency,
                              s.profit.toCurrency,
                              s.date.formatted,
                            ],
                          )
                          .toList(),
                ),
              ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.loss),
        );
      }
    }
  }

  Future<void> _generateProfitReport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null || user.storeId == null) return;
      final store = await ref.read(currentStoreProvider.future);
      final sales = await ref.read(monthlySalesProvider(user.storeId!).future);

      // Group by item for profit breakdown
      final Map<String, Map<String, dynamic>> byItem = {};
      for (final s in sales) {
        byItem.putIfAbsent(
          s.itemName,
          () => {'qty': 0, 'revenue': 0.0, 'cost': 0.0, 'profit': 0.0},
        );
        byItem[s.itemName]!['qty'] =
            (byItem[s.itemName]!['qty'] as int) + s.quantity;
        byItem[s.itemName]!['revenue'] =
            (byItem[s.itemName]!['revenue'] as double) + s.revenue;
        byItem[s.itemName]!['cost'] =
            (byItem[s.itemName]!['cost'] as double) + s.cost;
        byItem[s.itemName]!['profit'] =
            (byItem[s.itemName]!['profit'] as double) + s.profit;
      }

      final sorted =
          byItem.entries.toList()..sort(
            (a, b) => (b.value['profit'] as double).compareTo(
              a.value['profit'] as double,
            ),
          );

      final totalProfit = sales.fold(0.0, (s, e) => s + e.profit);
      final totalRevenue = sales.fold(0.0, (s, e) => s + e.revenue);
      final margin =
          totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0.0;

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header:
              (ctx) =>
                  _pdfHeader('Profit Summary Report', store?.storeName ?? ''),
          build:
              (ctx) => [
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _pdfStatBox('Total Profit', totalProfit.toCurrency),
                    _pdfStatBox('Overall Margin', margin.toPercent),
                    _pdfStatBox('Total Sales', '${sales.length}'),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Profit by Item',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headers: ['Item', 'Units', 'Revenue', 'Cost', 'Profit'],
                  data:
                      sorted
                          .map(
                            (e) => [
                              e.key,
                              '${e.value['qty']}',
                              (e.value['revenue'] as double).toCurrency,
                              (e.value['cost'] as double).toCurrency,
                              (e.value['profit'] as double).toCurrency,
                            ],
                          )
                          .toList(),
                ),
              ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.loss),
        );
      }
    }
  }

  Future<void> _generateInventoryReport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null || user.storeId == null) return;
      final store = await ref.read(currentStoreProvider.future);
      final items = await ref.read(inventoryListProvider(user.storeId!).future);

      final totalValue = items.fold(
        0.0,
        (s, i) => s + (i.sellingPrice * i.stockQuantity),
      );
      final lowStock = items.where((i) => i.isLowStock).length;
      final expiring = items.where((i) => i.isExpiringSoon).length;

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header:
              (ctx) => _pdfHeader('Inventory Report', store?.storeName ?? ''),
          build:
              (ctx) => [
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _pdfStatBox('Total Items', '${items.length}'),
                    _pdfStatBox('Total Value', totalValue.toCurrency),
                    _pdfStatBox('Low Stock', '$lowStock'),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(children: [_pdfStatBox('Expiring Soon', '$expiring')]),
                pw.SizedBox(height: 20),
                pw.Text(
                  'All Items',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headers: [
                    'Name',
                    'Category',
                    'Stock',
                    'Min',
                    'Price',
                    'Margin%',
                    'Status',
                  ],
                  data:
                      items
                          .map(
                            (i) => [
                              i.name,
                              i.category,
                              '${i.stockQuantity}',
                              '${i.minStockLevel}',
                              i.sellingPrice.toCurrency,
                              i.profitMarginPercent.toPercent,
                              i.isOutOfStock
                                  ? 'OUT'
                                  : i.isLowStock
                                  ? 'LOW'
                                  : 'OK',
                            ],
                          )
                          .toList(),
                ),
              ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.loss),
        );
      }
    }
  }

  Future<void> _generateDemandReport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null || user.storeId == null) return;
      final store = await ref.read(currentStoreProvider.future);
      final demands = await ref.read(topDemandsProvider(user.storeId!).future);

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build:
              (ctx) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _pdfHeader('Demand Analysis Report', store?.storeName ?? ''),
                  pw.SizedBox(height: 20),
                  _pdfStatBox('Total Demand Entries', '${demands.length}'),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Most Requested Items',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.TableHelper.fromTextArray(
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    headers: [
                      'Rank',
                      'Item Name',
                      'Times Requested',
                      'Last Date',
                    ],
                    data:
                        demands
                            .asMap()
                            .entries
                            .map(
                              (e) => [
                                '${e.key + 1}',
                                e.value.itemName,
                                '${e.value.timesRequested}',
                                e.value.date.formatted,
                              ],
                            )
                            .toList(),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Recommendation: Consider restocking items with high demand frequency.',
                    style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.loss),
        );
      }
    }
  }

  static pw.Widget _pdfHeader(String title, String storeName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Storelytics',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              DateTime.now().toString().substring(0, 10),
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          storeName,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(thickness: 1),
      ],
    );
  }

  static pw.Widget _pdfStatBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
