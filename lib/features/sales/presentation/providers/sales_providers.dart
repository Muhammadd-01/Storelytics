import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storelytics/features/sales/data/models/sale_model.dart';
import 'package:storelytics/features/sales/data/repositories/sales_repository.dart';

// ── Repository ──
final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository();
});

// ── Stream Sales ──
final salesStreamProvider = StreamProvider.family<List<SaleModel>, String>((
  ref,
  storeId,
) {
  return ref.watch(salesRepositoryProvider).streamSales(storeId);
});

// ── Today's Sales ──
final todaySalesProvider = FutureProvider.family<List<SaleModel>, String>((
  ref,
  storeId,
) async {
  return ref.read(salesRepositoryProvider).getTodaySales(storeId);
});

// ── Weekly Sales ──
final weeklySalesProvider = FutureProvider.family<List<SaleModel>, String>((
  ref,
  storeId,
) async {
  return ref.read(salesRepositoryProvider).getWeeklySales(storeId);
});

// ── Monthly Sales ──
final monthlySalesProvider = FutureProvider.family<List<SaleModel>, String>((
  ref,
  storeId,
) async {
  return ref.read(salesRepositoryProvider).getMonthlySales(storeId);
});

// ── Sales By Item (for analytics) ──
final salesByItemProvider =
    FutureProvider.family<Map<String, List<SaleModel>>, String>((
      ref,
      storeId,
    ) async {
      return ref.read(salesRepositoryProvider).getSalesByItem(storeId);
    });

// ── Today Stats ──
final todayRevenueProvider = FutureProvider.family<double, String>((
  ref,
  storeId,
) async {
  final sales = await ref.read(salesRepositoryProvider).getTodaySales(storeId);
  return sales.fold<double>(0.0, (sum, s) => sum + s.revenue);
});

final todayProfitProvider = FutureProvider.family<double, String>((
  ref,
  storeId,
) async {
  final sales = await ref.read(salesRepositoryProvider).getTodaySales(storeId);
  return sales.fold<double>(0.0, (sum, s) => sum + s.profit);
});
