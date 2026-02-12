import 'package:cloud_firestore/cloud_firestore.dart';

/// Demand log model for tracking requested-but-unavailable items.
class DemandModel {
  final String demandId;
  final String storeId;
  final String itemName;
  final int timesRequested;
  final DateTime date;
  final DateTime createdAt;

  const DemandModel({
    required this.demandId,
    required this.storeId,
    required this.itemName,
    required this.timesRequested,
    required this.date,
    required this.createdAt,
  });

  DemandModel copyWith({
    String? demandId,
    String? storeId,
    String? itemName,
    int? timesRequested,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return DemandModel(
      demandId: demandId ?? this.demandId,
      storeId: storeId ?? this.storeId,
      itemName: itemName ?? this.itemName,
      timesRequested: timesRequested ?? this.timesRequested,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'demandId': demandId,
      'storeId': storeId,
      'currentStoreId': storeId, // Added for compatibility
      'itemName': itemName,
      'timesRequested': timesRequested,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DemandModel.fromMap(Map<String, dynamic> map) {
    return DemandModel(
      demandId: map['demandId'] as String,
      storeId: (map['storeId'] ?? map['currentStoreId']) as String,
      itemName: map['itemName'] as String,
      timesRequested: map['timesRequested'] as int,
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
