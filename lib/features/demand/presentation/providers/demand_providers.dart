import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storelytics/features/demand/data/models/demand_model.dart';
import 'package:storelytics/features/demand/data/repositories/demand_repository.dart';

// ── Repository ──
final demandRepositoryProvider = Provider<DemandRepository>((ref) {
  return DemandRepository();
});

// ── Stream Demands ──
final demandStreamProvider = StreamProvider.family<List<DemandModel>, String>((
  ref,
  storeId,
) {
  return ref.watch(demandRepositoryProvider).streamDemands(storeId);
});

// ── Top Demands ──
final topDemandsProvider = FutureProvider.family<List<DemandModel>, String>((
  ref,
  storeId,
) async {
  return ref.read(demandRepositoryProvider).getTopDemands(storeId);
});
