import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelytics/core/constants.dart';
import 'package:storelytics/features/sales/data/models/sale_model.dart';

class SalesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.salesCollection);

  /// Record a new sale.
  Future<void> recordSale(SaleModel sale) async {
    await _collection.doc(sale.saleId).set(sale.toMap());

    // Decrement stock
    await _firestore
        .collection(AppConstants.inventoryCollection)
        .doc(sale.itemId)
        .update({'stockQuantity': FieldValue.increment(-sale.quantity)});
  }

  /// Delete a sale.
  Future<void> deleteSale(String saleId) async {
    await _collection.doc(saleId).delete();
  }

  /// Stream sales for a store.
  Stream<List<SaleModel>> streamSales(String storeId) {
    return _collection
        .where('storeId', isEqualTo: storeId)
        .orderBy('date', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => SaleModel.fromMap(d.data())).toList(),
        );
  }

  /// Get today's sales.
  Future<List<SaleModel>> getTodaySales(String storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _collection
        .where('storeId', isEqualTo: storeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((d) => SaleModel.fromMap(d.data())).toList();
  }

  /// Get sales for a date range.
  Future<List<SaleModel>> getSalesForRange(
    String storeId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _collection
        .where('storeId', isEqualTo: storeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((d) => SaleModel.fromMap(d.data())).toList();
  }

  /// Get weekly sales (last 7 days).
  Future<List<SaleModel>> getWeeklySales(String storeId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getSalesForRange(storeId, weekAgo, now);
  }

  /// Get monthly sales.
  Future<List<SaleModel>> getMonthlySales(String storeId) async {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    return getSalesForRange(storeId, monthAgo, now);
  }

  /// Get sales by item (for analytics).
  Future<Map<String, List<SaleModel>>> getSalesByItem(String storeId) async {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    final sales = await getSalesForRange(storeId, monthAgo, now);

    final Map<String, List<SaleModel>> grouped = {};
    for (final sale in sales) {
      grouped.putIfAbsent(sale.itemId, () => []).add(sale);
    }
    return grouped;
  }

  /// Get total sales count for a store (all time).
  Future<int> getTotalSalesCount(String storeId) async {
    final snapshot = await _collection
        .where('storeId', isEqualTo: storeId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Get all sales (admin) for platform revenue.
  Future<List<SaleModel>> getAllSales() async {
    final snapshot = await _collection
        .orderBy('date', descending: true)
        .limit(500)
        .get();
    return snapshot.docs.map((d) => SaleModel.fromMap(d.data())).toList();
  }
}
