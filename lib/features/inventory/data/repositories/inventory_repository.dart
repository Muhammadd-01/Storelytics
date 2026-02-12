import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelytics/core/constants.dart';
import 'package:storelytics/features/inventory/data/models/inventory_item_model.dart';

class InventoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.inventoryCollection);

  /// Add a new item.
  Future<void> addItem(InventoryItem item) async {
    await _collection.doc(item.itemId).set(item.toMap());
  }

  /// Update an item.
  Future<void> updateItem(InventoryItem item) async {
    await _collection.doc(item.itemId).update(item.toMap());
  }

  /// Delete an item.
  Future<void> deleteItem(String itemId) async {
    await _collection.doc(itemId).delete();
  }

  /// Get all items for a store.
  Stream<List<InventoryItem>> streamItems(String storeId) {
    return _collection
        .where('storeId', isEqualTo: storeId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((d) => InventoryItem.fromMap(d.data()))
                  .toList(),
        );
  }

  /// Get items by category.
  Stream<List<InventoryItem>> streamItemsByCategory(
    String storeId,
    String category,
  ) {
    return _collection
        .where('storeId', isEqualTo: storeId)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((d) => InventoryItem.fromMap(d.data()))
                  .toList(),
        );
  }

  /// Get low stock items.
  Future<List<InventoryItem>> getLowStockItems(String storeId) async {
    final snapshot =
        await _collection.where('storeId', isEqualTo: storeId).get();

    return snapshot.docs
        .map((d) => InventoryItem.fromMap(d.data()))
        .where((item) => item.isLowStock)
        .toList();
  }

  /// Get expiring-soon items.
  Future<List<InventoryItem>> getExpiringItems(String storeId) async {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30));

    final snapshot =
        await _collection
            .where('storeId', isEqualTo: storeId)
            .where(
              'expiryDate',
              isLessThanOrEqualTo: Timestamp.fromDate(threshold),
            )
            .where('expiryDate', isGreaterThan: Timestamp.fromDate(now))
            .get();

    return snapshot.docs.map((d) => InventoryItem.fromMap(d.data())).toList();
  }

  /// Adjust stock quantity.
  Future<void> adjustStock(String itemId, int adjustment) async {
    await _collection.doc(itemId).update({
      'stockQuantity': FieldValue.increment(adjustment),
    });
  }

  /// Get single item.
  Future<InventoryItem?> getItem(String itemId) async {
    final doc = await _collection.doc(itemId).get();
    if (!doc.exists) return null;
    return InventoryItem.fromMap(doc.data()!);
  }

  /// Get item count for a store.
  Future<int> getItemCount(String storeId) async {
    final snapshot =
        await _collection.where('storeId', isEqualTo: storeId).count().get();
    return snapshot.count ?? 0;
  }

  /// Search items by name.
  Future<List<InventoryItem>> searchItems(String storeId, String query) async {
    final snapshot =
        await _collection.where('storeId', isEqualTo: storeId).get();

    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((d) => InventoryItem.fromMap(d.data()))
        .where(
          (item) =>
              item.name.toLowerCase().contains(lowerQuery) ||
              item.category.toLowerCase().contains(lowerQuery) ||
              item.supplierName.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Get all categories for a store.
  Future<List<String>> getCategories(String storeId) async {
    final snapshot =
        await _collection.where('storeId', isEqualTo: storeId).get();

    final categories =
        snapshot.docs
            .map((d) => d.data()['category'] as String)
            .toSet()
            .toList();
    categories.sort();
    return categories;
  }

  /// Get item by barcode for a specific store.
  Future<InventoryItem?> getItemByBarcode(
    String storeId,
    String barcode,
  ) async {
    final snapshot =
        await _collection
            .where('storeId', isEqualTo: storeId)
            .where('barcode', isEqualTo: barcode)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;
    return InventoryItem.fromMap(snapshot.docs.first.data());
  }
}
