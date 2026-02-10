import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storelytics/features/auth/data/models/user_model.dart';
import 'package:storelytics/features/auth/data/repositories/auth_repository.dart';

// ── Repository Provider ──
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ── Auth State ──
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ── Current User Model ──
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authRepositoryProvider).getCurrentUserModel();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// ── User Model Stream ──
final userModelStreamProvider = StreamProvider.family<UserModel?, String>((
  ref,
  uid,
) {
  return ref.watch(authRepositoryProvider).streamUserModel(uid);
});

// ── Sign In ──
final signInProvider =
    FutureProvider.family<UserModel, ({String email, String password})>((
      ref,
      params,
    ) async {
      return ref
          .read(authRepositoryProvider)
          .signIn(email: params.email, password: params.password);
    });
