import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelytics/core/enums.dart';

/// Store model for Firestore.
class StoreModel {
  final String storeId;
  final String storeName;
  final StoreType storeType;
  final String ownerName;
  final String address;
  final String ownerId;
  final String ownerNic;
  final String certificationNumber;
  final String? nicImageUrl;
  final String? certificationImageUrl;
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
    this.nicImageUrl,
    this.certificationImageUrl,
    required this.createdAt,
  });

  StoreModel copyWith({
    String? storeId,
    String? storeName,
    StoreType? storeType,
    String? ownerName,
    String? address,
    String? ownerId,
    String? ownerNic,
    String? certificationNumber,
    String? nicImageUrl,
    String? certificationImageUrl,
    DateTime? createdAt,
  }) {
    return StoreModel(
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeType: storeType ?? this.storeType,
      ownerName: ownerName ?? this.ownerName,
      address: address ?? this.address,
      ownerId: ownerId ?? this.ownerId,
      ownerNic: ownerNic ?? this.ownerNic,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      nicImageUrl: nicImageUrl ?? this.nicImageUrl,
      certificationImageUrl:
          certificationImageUrl ?? this.certificationImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'storeType': storeType.name,
      'ownerName': ownerName,
      'address': address,
      'ownerId': ownerId,
      'ownerNic': ownerNic,
      'certificationNumber': certificationNumber,
      'nicImageUrl': nicImageUrl,
      'certificationImageUrl': certificationImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

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
      nicImageUrl: map['nicImageUrl'] as String?,
      certificationImageUrl: map['certificationImageUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
