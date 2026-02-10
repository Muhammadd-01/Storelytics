import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelytics/core/constants.dart';
import 'package:storelytics/features/store/data/models/store_model.dart';

class StoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new store.
  Future<void> createStore(StoreModel store) async {
    await _firestore
        .collection(AppConstants.storesCollection)
        .doc(store.storeId)
        .set(store.toMap());

    // Link store to user
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(store.ownerId)
        .update({'storeId': store.storeId});
  }

  /// Get store by ID.
  Future<StoreModel?> getStore(String storeId) async {
    final doc = await _firestore
        .collection(AppConstants.storesCollection)
        .doc(storeId)
        .get();
    if (!doc.exists) return null;
    return StoreModel.fromMap(doc.data()!);
  }

  /// Stream store.
  Stream<StoreModel?> streamStore(String storeId) {
    return _firestore
        .collection(AppConstants.storesCollection)
        .doc(storeId)
        .snapshots()
        .map((doc) => doc.exists ? StoreModel.fromMap(doc.data()!) : null);
  }

  /// Update store.
  Future<void> updateStore(StoreModel store) async {
    await _firestore
        .collection(AppConstants.storesCollection)
        .doc(store.storeId)
        .update(store.toMap());
  }

  /// Get all stores (admin).
  Future<List<StoreModel>> getAllStores() async {
    final snapshot = await _firestore
        .collection(AppConstants.storesCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => StoreModel.fromMap(d.data())).toList();
  }
}
