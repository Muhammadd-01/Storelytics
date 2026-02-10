import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storelytics/core/extensions.dart';
import 'package:storelytics/features/inventory/data/models/inventory_item_model.dart';
import 'package:storelytics/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:storelytics/shared/widgets/alert_badge.dart';
import 'package:storelytics/theme/app_colors.dart';

class ItemDetailScreen extends ConsumerWidget {
  final InventoryItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => context.push('/inventory/edit', extra: item),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: AppColors.loss,
                size: 20,
              ),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Prominent Header Image or Placeholder
            Hero(
              tag: 'item_image_${item.itemId}',
              child: Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  image:
                      item.imageUrl != null
                          ? DecorationImage(
                            image: NetworkImage(item.imageUrl!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    item.imageUrl == null
                        ? const Center(
                          child: Icon(
                            Icons.inventory_2_rounded,
                            size: 100,
                            color: Colors.white38,
                          ),
                        )
                        : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                item.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.isLowStock)
                          const AlertBadge(
                            text: 'LOW STOCK',
                            type: AlertType.danger,
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Financial Highlights
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Unit Profit',
                            value: item.profitPerUnit.toCurrency,
                            icon: Icons.trending_up_rounded,
                            color: AppColors.profit,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _MetricCard(
                            label: 'Stock Left',
                            value: '${item.stockQuantity}',
                            icon: Icons.warehouse_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'PRICING ARCHITECTURE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPricingRow(
                      'Purchase Cost',
                      item.purchasePrice.toCurrency,
                      isDark,
                    ),
                    _buildDivider(isDark),
                    _buildPricingRow(
                      'Selling Revenue',
                      item.sellingPrice.toCurrency,
                      isDark,
                      isPrimary: true,
                    ),
                    _buildDivider(isDark),
                    _buildPricingRow(
                      'Profit Margin',
                      item.profitMarginPercent.toPercent,
                      isDark,
                      valueColor:
                          item.profitMarginPercent >= 10
                              ? AppColors.profit
                              : AppColors.warning,
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'LOGISTICS & TRACKING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(
                      Icons.store_rounded,
                      'Supplier',
                      item.supplierName,
                      isDark,
                    ),
                    if (item.barcode != null)
                      _buildInfoTile(
                        Icons.qr_code_rounded,
                        'Barcode ID',
                        item.barcode!,
                        isDark,
                      ),
                    if (item.expiryDate != null)
                      _buildInfoTile(
                        Icons.event_busy_rounded,
                        'Expiry Date',
                        item.expiryDate!.formatted,
                        isDark,
                        color: AppColors.warning,
                      ),
                    _buildInfoTile(
                      Icons.history_rounded,
                      'Registry Date',
                      item.createdAt.formatted,
                      isDark,
                    ),

                    const SizedBox(height: 48),

                    // Interaction
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showStockAdjustment(context, ref),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text(
                          'CALIBRATE STOCK LEVELS',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(
    String label,
    String value,
    bool isDark, {
    bool isPrimary = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isPrimary ? 18 : 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? (isPrimary ? AppColors.secondary : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppColors.secondary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color ?? AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 24,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
    );
  }

  void _showStockAdjustment(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Stock Calibration',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current inventory count: ${item.stockQuantity}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'e.g. +10 or -5',
                    labelText: 'Quantity Adjustment',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('DISMISS'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final adjustment = int.tryParse(controller.text);
                  if (adjustment == null) return;
                  await ref
                      .read(inventoryRepositoryProvider)
                      .adjustStock(item.itemId, adjustment);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Delete Product?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to permanently remove "${item.name}" from your catalog?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loss,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await ref
                      .read(inventoryRepositoryProvider)
                      .deleteItem(item.itemId);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) context.pop();
                },
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
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
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
