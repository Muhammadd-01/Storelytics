import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:storelytics/core/extensions.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/inventory/data/models/inventory_item_model.dart';
import 'package:storelytics/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:storelytics/features/sales/data/models/sale_model.dart';
import 'package:storelytics/features/sales/presentation/providers/sales_providers.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';
import 'package:storelytics/theme/app_colors.dart';

class RecordSaleScreen extends ConsumerStatefulWidget {
  const RecordSaleScreen({super.key});

  @override
  ConsumerState<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends ConsumerState<RecordSaleScreen> {
  InventoryItem? _selectedItem;
  final _quantityController = TextEditingController(text: '1');
  bool _isLoading = false;

  double get _quantity => double.tryParse(_quantityController.text) ?? 0;
  double get _revenue => (_selectedItem?.sellingPrice ?? 0) * _quantity;
  double get _cost => (_selectedItem?.purchasePrice ?? 0) * _quantity;
  double get _profit => _revenue - _cost;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleRecordSale() async {
    if (_selectedItem == null) {
      _showError('Please select an item first');
      return;
    }
    final qty = int.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) {
      _showError('Enter a valid quantity');
      return;
    }
    if (qty > _selectedItem!.stockQuantity) {
      _showError(
        'Insufficient stock! Only ${_selectedItem!.stockQuantity} remaining',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      final sale = SaleModel(
        saleId: const Uuid().v4(),
        storeId: user!.storeId!,
        itemId: _selectedItem!.itemId,
        itemName: _selectedItem!.name,
        quantity: qty,
        revenue: _revenue,
        cost: _cost,
        profit: _profit,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await ref.read(salesRepositoryProvider).recordSale(sale);
      ref.invalidate(todaySalesProvider(user.storeId!));
      ref.invalidate(todayRevenueProvider(user.storeId!));
      ref.invalidate(todayProfitProvider(user.storeId!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale completed successfully!'),
            backgroundColor: AppColors.profit,
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.loss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale Transaction'),
        centerTitle: true,
      ),
      body: userAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (user) {
          if (user == null || user.storeId == null) {
            return const EmptyStateWidget(
              icon: Icons.store,
              title: 'No store configured',
            );
          }

          final itemsAsync = ref.watch(inventoryListProvider(user.storeId!));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('SELECT PRODUCT'),
                const SizedBox(height: 12),
                itemsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(e.toString()),
                  data: (items) {
                    final availableItems =
                        items.where((i) => i.stockQuantity > 0).toList();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<InventoryItem>(
                          value: _selectedItem,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Select item to sell',
                          ),
                          items:
                              availableItems
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        '${item.name} (${item.stockQuantity} Left)',
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (item) => setState(() => _selectedItem = item),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                _buildSectionHeader('ITEM COUNT'),
                const SizedBox(height: 12),
                _buildQuantityPicker(isDark),

                const SizedBox(height: 40),

                if (_selectedItem != null) _buildSummaryCard(isDark),

                const SizedBox(height: 48),
                _buildRecordButton(),
                const SizedBox(height: 150),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.secondary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuantityPicker(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            icon: Icons.remove_rounded,
            onTap: () {
              final v = (int.tryParse(_quantityController.text) ?? 1) - 1;
              if (v >= 1)
                setState(() => _quantityController.text = v.toString());
            },
            color:
                isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
          Expanded(
            child: TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          _CircleButton(
            icon: Icons.add_rounded,
            onTap: () {
              final v = (int.tryParse(_quantityController.text) ?? 0) + 1;
              setState(() => _quantityController.text = v.toString());
            },
            color: AppColors.secondary,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [Colors.white, const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Unit Price',
            value: _selectedItem!.sellingPrice.toCurrency,
          ),
          const Divider(height: 32),
          _SummaryRow(
            label: 'Total Revenue',
            value: _revenue.toCurrency,
            isPrimary: true,
          ),
          _SummaryRow(
            label: 'Total Cost',
            value: _cost.toCurrency,
            color: AppColors.loss,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.profit.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _SummaryRow(
              label: 'Estimated Profit',
              value: _profit.toCurrency,
              color: AppColors.profit,
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRecordSale,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'RECORD SALE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor ?? AppColors.secondary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;
  final bool isPrimary;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color,
    this.isBold = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isPrimary ? 20 : (isBold ? 18 : 15),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
