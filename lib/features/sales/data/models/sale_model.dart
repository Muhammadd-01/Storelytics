import 'package:cloud_firestore/cloud_firestore.dart';

/// Sale record model for Firestore.
class SaleModel {
  final String saleId;
  final String storeId;
  final String itemId;
  final String itemName;
  final int quantity;
  final double revenue;
  final double cost;
  final double profit;
  final DateTime date;
  final DateTime createdAt;

  const SaleModel({
    required this.saleId,
    required this.storeId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.date,
    required this.createdAt,
  });

  /// Computed: profit margin percentage.
  double get profitMarginPercent => revenue > 0 ? (profit / revenue) * 100 : 0;

  SaleModel copyWith({
    String? saleId,
    String? storeId,
    String? itemId,
    String? itemName,
    int? quantity,
    double? revenue,
    double? cost,
    double? profit,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return SaleModel(
      saleId: saleId ?? this.saleId,
      storeId: storeId ?? this.storeId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      revenue: revenue ?? this.revenue,
      cost: cost ?? this.cost,
      profit: profit ?? this.profit,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'storeId': storeId,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'revenue': revenue,
      'cost': cost,
      'profit': profit,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      saleId: map['saleId'] as String,
      storeId: map['storeId'] as String,
      itemId: map['itemId'] as String,
      itemName: map['itemName'] as String? ?? '',
      quantity: map['quantity'] as int,
      revenue: (map['revenue'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      profit: (map['profit'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
