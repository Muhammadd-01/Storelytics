import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storelytics/features/store/data/models/store_model.dart';
import 'package:storelytics/features/store/data/repositories/store_repository.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';

// ── Repository ──
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository();
});

// ── Current Store ──
final currentStoreProvider = FutureProvider<StoreModel?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.storeId == null) return null;
  return ref.read(storeRepositoryProvider).getStore(user.storeId!);
});

// ── Store Stream ──
final storeStreamProvider = StreamProvider.family<StoreModel?, String>((
  ref,
  storeId,
) {
  return ref.watch(storeRepositoryProvider).streamStore(storeId);
});

// ── All Stores (Admin) ──
final allStoresProvider = FutureProvider<List<StoreModel>>((ref) async {
  return ref.read(storeRepositoryProvider).getAllStores();
});
