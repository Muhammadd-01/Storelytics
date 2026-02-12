import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelytics/core/enums.dart';

/// User model for Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? currentStoreId;
  final List<String> storeIds;
  final String? profileImageUrl;
  final String? phoneNumber;
  final SubscriptionPlan subscriptionPlan;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.currentStoreId,
    this.storeIds = const [],
    this.profileImageUrl,
    this.phoneNumber,
    this.subscriptionPlan = SubscriptionPlan.free,
    this.isActive = true,
    required this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? currentStoreId,
    List<String>? storeIds,
    String? profileImageUrl,
    String? phoneNumber,
    SubscriptionPlan? subscriptionPlan,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      currentStoreId: currentStoreId ?? this.currentStoreId,
      storeIds: storeIds ?? this.storeIds,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'storeId': currentStoreId, // Keep for rules compatibility
      'currentStoreId': currentStoreId,
      'storeIds': storeIds,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'subscriptionPlan': subscriptionPlan.name,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.storeOwner,
      ),
      currentStoreId: (map['currentStoreId'] ?? map['storeId']) as String?,
      storeIds: List<String>.from(map['storeIds'] ?? []),
      profileImageUrl: map['profileImageUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      subscriptionPlan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == map['subscriptionPlan'],
        orElse: () => SubscriptionPlan.free,
      ),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
