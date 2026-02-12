import 'package:cloud_firestore/cloud_firestore.dart';

/// Inventory item model for Firestore.
class InventoryItem {
  final String itemId;
  final String storeId;
  final String name;
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minStockLevel;
  final DateTime? expiryDate;
  final String supplierName;
  final String? barcode;
  final String? imageUrl;
  final String? barcodeImageUrl;
  final DateTime createdAt;

  const InventoryItem({
    required this.itemId,
    required this.storeId,
    required this.name,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minStockLevel,
    this.expiryDate,
    required this.supplierName,
    this.barcode,
    this.imageUrl,
    this.barcodeImageUrl,
    required this.createdAt,
  });

  /// Computed: profit margin per unit.
  double get profitPerUnit => sellingPrice - purchasePrice;

  /// Computed: profit margin percentage.
  double get profitMarginPercent =>
      sellingPrice > 0 ? (profitPerUnit / sellingPrice) * 100 : 0;

  /// Computed: is low stock.
  bool get isLowStock => stockQuantity <= minStockLevel;

  /// Computed: is out of stock.
  bool get isOutOfStock => stockQuantity == 0;

  /// Computed: is expiring soon (within 30 days).
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    return daysLeft > 0 && daysLeft <= 30;
  }

  /// Computed: is expired.
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Computed: days until expiry.
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  InventoryItem copyWith({
    String? itemId,
    String? storeId,
    String? name,
    String? category,
    double? purchasePrice,
    double? sellingPrice,
    int? stockQuantity,
    int? minStockLevel,
    DateTime? expiryDate,
    String? supplierName,
    String? barcode,
    String? imageUrl,
    String? barcodeImageUrl,
    DateTime? createdAt,
  }) {
    return InventoryItem(
      itemId: itemId ?? this.itemId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      expiryDate: expiryDate ?? this.expiryDate,
      supplierName: supplierName ?? this.supplierName,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      barcodeImageUrl: barcodeImageUrl ?? this.barcodeImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'storeId': storeId,
      'currentStoreId': storeId, // Added for cross-compatibility
      'name': name,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'supplierName': supplierName,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'barcodeImageUrl': barcodeImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      itemId: map['itemId'] as String,
      storeId: (map['storeId'] ?? map['currentStoreId']) as String,
      name: map['name'] as String,
      category: map['category'] as String,
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      stockQuantity: map['stockQuantity'] as int,
      minStockLevel: map['minStockLevel'] as int,
      expiryDate:
          map['expiryDate'] != null
              ? (map['expiryDate'] as Timestamp).toDate()
              : null,
      supplierName: map['supplierName'] as String,
      barcode: map['barcode'] as String?,
      imageUrl: map['imageUrl'] as String?,
      barcodeImageUrl: map['barcodeImageUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
