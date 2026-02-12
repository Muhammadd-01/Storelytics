import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class OnboardingRepository {
  final SharedPreferences _prefs;
  static const _key = 'onboarding_completed';

  OnboardingRepository(this._prefs);

  bool isOnboardingCompleted() {
    return _prefs.getBool(_key) ?? false;
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_key, true);
  }

  Future<void> resetOnboarding() async {
    await _prefs.remove(_key);
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingRepository(prefs);
});

final onboardingCompletedProvider = StateProvider<bool>((ref) {
  final repo = ref.watch(onboardingRepositoryProvider);
  return repo.isOnboardingCompleted();
});
