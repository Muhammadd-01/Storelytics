import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storelytics/features/analytics/presentation/screens/dashboard_screen.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:storelytics/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:storelytics/features/auth/presentation/screens/login_screen.dart';
import 'package:storelytics/features/auth/presentation/screens/signup_screen.dart';
import 'package:storelytics/features/demand/presentation/screens/demand_list_screen.dart';
import 'package:storelytics/features/inventory/data/models/inventory_item_model.dart';
import 'package:storelytics/features/inventory/presentation/screens/add_edit_item_screen.dart';
import 'package:storelytics/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:storelytics/features/inventory/presentation/screens/item_detail_screen.dart';
import 'package:storelytics/features/reports/presentation/screens/reports_screen.dart';
import 'package:storelytics/features/sales/presentation/screens/record_sale_screen.dart';
import 'package:storelytics/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:storelytics/features/auth/presentation/screens/profile_screen.dart';
import 'package:storelytics/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:storelytics/features/settings/presentation/screens/settings_screen.dart';
import 'package:storelytics/features/store/presentation/screens/store_setup_screen.dart';
import 'package:storelytics/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:storelytics/shared/widgets/main_shell.dart';

import 'package:storelytics/features/auth/presentation/screens/splash_screen.dart';
import 'package:storelytics/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:storelytics/features/auth/data/repositories/onboarding_repository.dart';
import 'package:storelytics/features/notifications/presentation/screens/notification_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userModelAsync = ref.watch(currentUserProvider);
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isForgotPassword = state.uri.toString() == '/forgot-password';
      final isSplash = state.uri.toString() == '/splash';
      final isOnboarding = state.uri.toString() == '/onboarding';
      final isAuthRoute = isLoggingIn || isSigningUp || isForgotPassword;

      if (isSplash) return null;

      // Wait for auth initialization
      if (authState.isLoading) return null;

      final user = authState.value;

      // Handle onboarding logic for new users
      if (!onboardingCompleted && !isOnboarding && user == null) {
        return '/onboarding';
      }

      // Unauthenticated state
      if (user == null) {
        if (isOnboarding || isAuthRoute) return null;
        return '/login';
      }

      // Logged in — Already onboarding and finished? go home
      if (isOnboarding && onboardingCompleted) return '/';

      // Wait for user model to load
      if (userModelAsync.isLoading) return null;

      return userModelAsync.maybeWhen(
        data: (userModel) {
          if (userModel == null) return null;

          final hasStore = userModel.currentStoreId != null;
          final isStoreSetup = state.uri.toString() == '/store-setup';
          final isVerification = state.uri.toString() == '/email-verification';

          // If no store and not on setup/verification page, go to setup
          if (!hasStore && !isStoreSetup && !isVerification) {
            return '/store-setup';
          }

          // If logged in and on auth route, go home
          if (isAuthRoute) {
            return '/';
          }
          return null;
        },
        orElse: () => null,
      );
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (_, __) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/store-setup',
        builder: (_, __) => const StoreSetupScreen(),
      ),

      // Main Shell Routes
      ShellRoute(
        builder:
            (context, state, child) => MainShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: InventoryListScreen()),
          ),
          GoRoute(
            path: '/sales',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: SalesHistoryScreen()),
          ),
          GoRoute(
            path: '/demand',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: DemandListScreen()),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ReportsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),

      // Detail / Push Routes (not inside shell)
      GoRoute(
        path: '/inventory/add',
        builder: (_, __) => const AddEditItemScreen(),
      ),
      GoRoute(
        path: '/inventory/edit',
        builder: (_, state) {
          final item = state.extra as InventoryItem?;
          return AddEditItemScreen(item: item);
        },
      ),
      GoRoute(
        path: '/inventory/:id',
        builder: (_, state) {
          final item = state.extra as InventoryItem;
          return ItemDetailScreen(item: item);
        },
      ),
      GoRoute(
        path: '/sales/record',
        builder: (_, __) => const RecordSaleScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationScreen(),
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(
        path: '/edit-profile',
        builder: (_, __) => const EditProfileScreen(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Page not found: ${state.uri}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
  );
});
