import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelytics/core/constants.dart';
import 'package:storelytics/features/demand/data/models/demand_model.dart';

class DemandRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.demandCollection);

  /// Add a new demand log.
  Future<void> addDemand(DemandModel demand) async {
    await _collection.doc(demand.demandId).set(demand.toMap());
  }

  /// Update existing demand (increment count).
  Future<void> incrementDemand(String demandId, int increment) async {
    await _collection.doc(demandId).update({
      'timesRequested': FieldValue.increment(increment),
    });
  }

  /// Delete demand.
  Future<void> deleteDemand(String demandId) async {
    await _collection.doc(demandId).delete();
  }

  /// Stream demands for a store.
  Stream<List<DemandModel>> streamDemands(String storeId) {
    return _collection
        .where('storeId', isEqualTo: storeId)
        .orderBy('timesRequested', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => DemandModel.fromMap(d.data())).toList(),
        );
  }

  /// Get top demanded items.
  Future<List<DemandModel>> getTopDemands(
    String storeId, {
    int limit = 10,
  }) async {
    final snapshot = await _collection
        .where('storeId', isEqualTo: storeId)
        .orderBy('timesRequested', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((d) => DemandModel.fromMap(d.data())).toList();
  }

  /// Get demand by item name (to check duplicates).
  Future<DemandModel?> getDemandByItemName(
    String storeId,
    String itemName,
  ) async {
    final snapshot = await _collection
        .where('storeId', isEqualTo: storeId)
        .where('itemName', isEqualTo: itemName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return DemandModel.fromMap(snapshot.docs.first.data());
  }
}
