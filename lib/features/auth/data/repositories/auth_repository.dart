import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storelytics/core/constants.dart';
import 'package:storelytics/core/enums.dart';
import 'package:storelytics/features/auth/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current auth user stream.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user.
  User? get currentUser => _auth.currentUser;

  /// Sign up with email & password.
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    await user.sendEmailVerification();

    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      role: UserRole.storeOwner,
      subscriptionPlan: SubscriptionPlan.free,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toMap());

    return userModel;
  }

  /// Sign in with email & password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc =
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .get();

    if (!doc.exists) {
      throw Exception('User data not found');
    }

    return UserModel.fromMap(doc.data()!);
  }

  /// Send password reset email.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Resend email verification.
  Future<void> resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current user model from Firestore.
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc =
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

    if (!doc.exists) return null;
    final data = doc.data()!;
    final model = UserModel.fromMap(data);

    // Auto-repair missing fields for security rules compatibility
    final currentId = data['currentStoreId'] ?? data['storeId'];
    if (currentId != null) {
      final updates = <String, dynamic>{};
      if (data['storeId'] != currentId) updates['storeId'] = currentId;
      if (data['currentStoreId'] != currentId)
        updates['currentStoreId'] = currentId;

      // Ensure storeIds is not empty if we have a current store
      final List<dynamic> storeIds = data['storeIds'] ?? [];
      if (storeIds.isEmpty) {
        updates['storeIds'] = [currentId];
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update(updates);
      }
    }

    return model;
  }

  /// Update user document.
  Future<void> updateUser(UserModel user) async {
    final data = user.toMap();
    // Ensure storeId is synced with currentStoreId for security rules compatibility
    if (data['currentStoreId'] != null) {
      data['storeId'] = data['currentStoreId'];
    }

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(data);
  }

  /// Stream user model.
  Stream<UserModel?> streamUserModel(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }
}
