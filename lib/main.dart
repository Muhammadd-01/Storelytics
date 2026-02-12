import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storelytics/core/router.dart';
import 'package:storelytics/features/auth/data/repositories/onboarding_repository.dart';
import 'package:storelytics/theme/app_theme.dart';
import 'package:storelytics/features/settings/presentation/providers/settings_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jeelecteirbaawtdhclw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplZWxlY3RlaXJiYWF3dGRoY2x3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MTgxNzMsImV4cCI6MjA4NjI5NDE3M30.TTgEaT0sT23gYh0VgJ4FtXNMNy7XD-joyyjUJ4gfz7E',
  );

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const StorelyticsApp(),
    ),
  );
}

class StorelyticsApp extends ConsumerWidget {
  const StorelyticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Storelytics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
