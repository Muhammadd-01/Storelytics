import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storelytics/features/inventory/data/models/inventory_item_model.dart';
import 'package:storelytics/features/inventory/data/repositories/inventory_repository.dart';

// ── Repository ──
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

// ── Stream All Items ──
final inventoryListProvider =
    StreamProvider.family<List<InventoryItem>, String>((ref, storeId) {
      return ref.watch(inventoryRepositoryProvider).streamItems(storeId);
    });

// ── Stream Items by Category ──
final inventoryByCategoryProvider =
    StreamProvider.family<
      List<InventoryItem>,
      ({String storeId, String category})
    >((ref, params) {
      return ref
          .watch(inventoryRepositoryProvider)
          .streamItemsByCategory(params.storeId, params.category);
    });

// ── Low Stock Items ──
final lowStockItemsProvider =
    FutureProvider.family<List<InventoryItem>, String>((ref, storeId) async {
      return ref.read(inventoryRepositoryProvider).getLowStockItems(storeId);
    });

// ── Expiring Items ──
final expiringItemsProvider =
    FutureProvider.family<List<InventoryItem>, String>((ref, storeId) async {
      return ref.read(inventoryRepositoryProvider).getExpiringItems(storeId);
    });

// ── Categories ──
final categoriesProvider = FutureProvider.family<List<String>, String>((
  ref,
  storeId,
) async {
  return ref.read(inventoryRepositoryProvider).getCategories(storeId);
});

// ── Search ──
final inventorySearchProvider =
    FutureProvider.family<
      List<InventoryItem>,
      ({String storeId, String query})
    >((ref, params) async {
      return ref
          .read(inventoryRepositoryProvider)
          .searchItems(params.storeId, params.query);
    });

// ── Item Count ──
final itemCountProvider = FutureProvider.family<int, String>((
  ref,
  storeId,
) async {
  return ref.read(inventoryRepositoryProvider).getItemCount(storeId);
});

// ── Selected Category Filter ──
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// ── Search Query ──
final inventorySearchQueryProvider = StateProvider<String>((ref) => '');
