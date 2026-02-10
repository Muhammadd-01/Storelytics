import 'package:cloud_firestore/cloud_firestore.dart';

// Shared enums matching the main Storelytics app.
enum UserRole {
  admin,
  storeOwner;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.storeOwner:
        return 'Store Owner';
    }
  }
}

enum StoreType {
  pharmacy,
  grocery,
  electronics,
  clothing,
  restaurant,
  generalStore,
  other;

  String get label {
    switch (this) {
      case StoreType.pharmacy:
        return 'Pharmacy';
      case StoreType.grocery:
        return 'Grocery';
      case StoreType.electronics:
        return 'Electronics';
      case StoreType.clothing:
        return 'Clothing';
      case StoreType.restaurant:
        return 'Restaurant';
      case StoreType.generalStore:
        return 'General Store';
      case StoreType.other:
        return 'Other';
    }
  }
}

enum SubscriptionPlan {
  free,
  pro,
  enterprise;

  String get label {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }
}

// ── User Model ──
class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? storeId;
  final SubscriptionPlan subscriptionPlan;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.storeId,
    this.subscriptionPlan = SubscriptionPlan.free,
    this.isActive = true,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.storeOwner,
      ),
      storeId: map['storeId'] as String?,
      subscriptionPlan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == map['subscriptionPlan'],
        orElse: () => SubscriptionPlan.free,
      ),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

// ── Store Model ──
class StoreModel {
  final String storeId;
  final String storeName;
  final StoreType storeType;
  final String ownerName;
  final String address;
  final String ownerId;
  final String ownerNic;
  final String certificationNumber;
  final DateTime createdAt;

  const StoreModel({
    required this.storeId,
    required this.storeName,
    required this.storeType,
    required this.ownerName,
    required this.address,
    required this.ownerId,
    required this.ownerNic,
    required this.certificationNumber,
    required this.createdAt,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      storeId: map['storeId'] as String,
      storeName: map['storeName'] as String,
      storeType: StoreType.values.firstWhere(
        (e) => e.name == map['storeType'],
        orElse: () => StoreType.generalStore,
      ),
      ownerName: map['ownerName'] as String,
      address: map['address'] as String,
      ownerId: map['ownerId'] as String,
      ownerNic: map['ownerNic'] as String? ?? 'N/A',
      certificationNumber: map['certificationNumber'] as String? ?? 'N/A',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

// ── Sale Model ──
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
  });

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
    );
  }
}

// ── Inventory Item Model ──
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
    required this.createdAt,
  });

  bool get isLowStock => stockQuantity <= minStockLevel;
  bool get isOutOfStock => stockQuantity == 0;

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      itemId: map['itemId'] as String,
      storeId: map['storeId'] as String,
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
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

// ── Demand Model ──
class DemandModel {
  final String demandId;
  final String storeId;
  final String itemName;
  final int timesRequested;
  final DateTime date;

  const DemandModel({
    required this.demandId,
    required this.storeId,
    required this.itemName,
    required this.timesRequested,
    required this.date,
  });

  factory DemandModel.fromMap(Map<String, dynamic> map) {
    return DemandModel(
      demandId: map['demandId'] as String,
      storeId: map['storeId'] as String,
      itemName: map['itemName'] as String,
      timesRequested: map['timesRequested'] as int,
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
