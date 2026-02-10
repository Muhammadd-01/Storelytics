import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

final _firestore = FirebaseFirestore.instance;

// ── Users ──
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return _firestore
      .collection('users')
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => UserModel.fromMap(d.data())).toList(),
      );
});

final totalUsersCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allUsersProvider).whenData((users) => users.length);
});

final activeUsersCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref
      .watch(allUsersProvider)
      .whenData((users) => users.where((u) => u.isActive).length);
});

// ── Stores ──
final allStoresProvider = StreamProvider<List<StoreModel>>((ref) {
  return _firestore
      .collection('stores')
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => StoreModel.fromMap(d.data())).toList(),
      );
});

final totalStoresCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allStoresProvider).whenData((stores) => stores.length);
});

// ── Platform Revenue ──
final platformSalesProvider = StreamProvider<List<SaleModel>>((ref) {
  return _firestore
      .collectionGroup('sales')
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => SaleModel.fromMap(d.data())).toList(),
      );
});

final platformRevenueProvider = Provider<AsyncValue<double>>((ref) {
  return ref
      .watch(platformSalesProvider)
      .whenData(
        (sales) => sales.fold<double>(0.0, (total, s) => total + s.revenue),
      );
});

final platformProfitProvider = Provider<AsyncValue<double>>((ref) {
  return ref
      .watch(platformSalesProvider)
      .whenData(
        (sales) => sales.fold<double>(0.0, (total, s) => total + s.profit),
      );
});

// ── Platform Inventory ──
final platformInventoryProvider = StreamProvider<List<InventoryItem>>((ref) {
  return _firestore
      .collectionGroup('inventory')
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => InventoryItem.fromMap(d.data())).toList(),
      );
});

final lowStockItemsProvider = Provider<AsyncValue<List<InventoryItem>>>((ref) {
  return ref
      .watch(platformInventoryProvider)
      .whenData(
        (items) => items.where((i) => i.isLowStock || i.isOutOfStock).toList(),
      );
});

// ── Platform Demands ──
final platformDemandsProvider = StreamProvider<List<DemandModel>>((ref) {
  return _firestore
      .collectionGroup('demands')
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => DemandModel.fromMap(d.data())).toList(),
      );
});
