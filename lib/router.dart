import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/firebase_auth_provider.dart';
import 'models/user.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile/profile_step1_screen.dart';
import 'screens/profile/profile_step2_screen.dart';
import 'screens/profile/profile_step3_screen.dart';
import 'screens/profile/profile_step4_screen.dart';
import 'screens/profile/profile_step5_screen.dart';
import 'screens/profile/quick_start_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/example_list_screen.dart';
import 'screens/study/study_screen.dart';
import 'screens/error_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/settings/daily_goal_setting_screen.dart';
import 'screens/category_management_screen.dart';
import 'widgets/main_layout.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String profileStep1 = '/profile/step1';
  static const String profileStep2 = '/profile/step2';
  static const String profileStep3 = '/profile/step3';
  static const String profileStep4 = '/profile/step4';
  static const String profileStep5 = '/profile/step5';
  static const String quickStart = '/profile/quick-start';
  static const String loading = '/loading';
  static const String home = '/home';
  static const String category = '/category';
  static const String exampleList = '/examples';
  static const String study = '/study';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String dailyGoalSetting = '/settings/daily-goal';
  static const String categoryManagement = '/category-management';
  static const String error = '/error';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: splash,
      routes: [
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: profileSetup,
          name: 'profileSetup',
          builder: (context, state) => const ProfileStep1Screen(),
        ),
        GoRoute(
          path: profileStep1,
          name: 'profileStep1',
          builder: (context, state) => const ProfileStep1Screen(),
        ),
        GoRoute(
          path: profileStep2,
          name: 'profileStep2',
          builder: (context, state) => const ProfileStep2Screen(),
        ),
        GoRoute(
          path: profileStep3,
          name: 'profileStep3',
          builder: (context, state) => const ProfileStep3Screen(),
        ),
        GoRoute(
          path: profileStep4,
          name: 'profileStep4',
          builder: (context, state) => const ProfileStep4Screen(),
        ),
        GoRoute(
          path: profileStep5,
          name: 'profileStep5',
          builder: (context, state) => const ProfileStep5Screen(),
        ),
        GoRoute(
          path: quickStart,
          name: 'quickStart',
          builder: (context, state) => const QuickStartScreen(),
        ),
        GoRoute(
          path: loading,
          name: 'loading',
          builder: (context, state) => const LoadingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final location = state.fullPath ?? state.matchedLocation;
            final queryParams = state.uri.queryParameters;
            return MainLayout(
              currentIndex: _getCurrentIndex(location, queryParams),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: home,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: favorites,
              name: 'favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: profile,
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: profileEdit,
              name: 'profileEdit',
              builder: (context, state) => const ProfileEditScreen(),
            ),
            GoRoute(
              path: dailyGoalSetting,
              name: 'dailyGoalSetting',
              builder: (context, state) => const DailyGoalSettingScreen(),
            ),
            GoRoute(
              path: categoryManagement,
              name: 'categoryManagement',
              builder: (context, state) => const CategoryManagementScreen(),
            ),
            GoRoute(
              path: category,
              name: 'category',
              builder: (context, state) {
                final levelId = state.uri.queryParameters['levelId'] ?? '';
                return CategoryScreen(levelId: levelId);
              },
            ),
            GoRoute(
              path: exampleList,
              name: 'exampleList',
              builder: (context, state) {
                final categoryId =
                    state.uri.queryParameters['categoryId'] ?? '';
                return ExampleListScreen(categoryId: categoryId);
              },
            ),
          ],
        ),
        GoRoute(
          path: study,
          name: 'study',
          builder: (context, state) {
            final categoryId = state.uri.queryParameters['categoryId'] ?? '';
            final levelId = state.uri.queryParameters['levelId'] ?? '';
            final mixed = state.uri.queryParameters['mixed'] == 'true';
            final allLevels = state.uri.queryParameters['allLevels'] == 'true';
            final exampleIndex =
                int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;

            if (allLevels) {
              return StudyScreen.allLevels(initialIndex: exampleIndex);
            } else if (mixed && levelId.isNotEmpty) {
              return StudyScreen.mixed(
                levelId: levelId,
                initialIndex: exampleIndex,
              );
            } else {
              return StudyScreen(
                categoryId: categoryId,
                initialIndex: exampleIndex,
              );
            }
          },
        ),
        GoRoute(
          path: error,
          name: 'error',
          builder: (context, state) {
            final message =
                state.uri.queryParameters['message'] ?? 'An error occurred';
            return ErrorScreen(message: message);
          },
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        try {
          final authProvider = Provider.of<FirebaseAuthProvider>(
            context,
            listen: false,
          );
          final isAuthenticated = authProvider.isAuthenticated;
          final currentUser = authProvider.currentUser;
          final profile = currentUser?.profile;
          final hasValidProfile = _hasValidProfile(profile);
          final isLoading = authProvider.isLoading;

          final isOnAuthPages = [login].contains(state.matchedLocation);
          final isOnProfilePages = [
            profileSetup,
            profileStep1,
            profileStep2,
            profileStep3,
            profileStep4,
            profileStep5,
            quickStart,
          ].contains(state.matchedLocation);
          final isOnSplash = state.matchedLocation == splash;
          final isOnError = state.matchedLocation == error;
          final isOnProfileEdit = state.matchedLocation == profileEdit;

          // デバッグ用ログ
          print(
            '🔄 Router Debug: path=${state.matchedLocation}, auth=$isAuthenticated, user=${currentUser?.email}, hasProfile=$hasValidProfile, loading=$isLoading',
          );

          // エラーページ、スプラッシュページ、プロフィール編集ページの場合はリダイレクトしない
          if (isOnError || isOnSplash || isOnProfileEdit) {
            return null;
          }

          // 未認証の場合はログイン画面へ
          if (!isAuthenticated && !isOnAuthPages) {
            print('🔄 Redirecting to login: not authenticated');
            return login;
          }

          // 認証済みでプロフィール未設定の場合、プロフィール設定画面へ（プロフィール編集中は除く）
          if (isAuthenticated && !hasValidProfile && !isOnProfilePages && !isOnProfileEdit) {
            print('🔄 Redirecting to profile setup: no valid profile');
            return profileSetup;
          }

          // 認証済みでプロフィール設定済みの場合、認証ページやプロフィール設定ページからホームへ
          if (isAuthenticated &&
              hasValidProfile &&
              (isOnAuthPages || isOnProfilePages)) {
            print('🔄 Redirecting to home: profile completed');
            return home;
          }

          return null;
        } catch (e, stackTrace) {
          print('🔄 Router Error: $e');
          print('🔄 Stack trace: $stackTrace');
          // エラー時は現在のページに留まる（スプラッシュにリダイレクトしない）
          return null;
        }
      },
    );
  }

  static bool _hasValidProfile(Profile? profile) {
    if (profile == null) {
      return false;
    }

    // Check if profile setup is completed
    final isCompleted = profile.isCompleted;
    print(
      '🔄 Profile Check: isCompleted=$isCompleted, occupation=${profile.occupation}, englishLevel=${profile.englishLevel}',
    );
    return isCompleted;
  }

  static int _getCurrentIndex(
    String location,
    Map<String, String> queryParams,
  ) {
    // 学習タブからのホーム遷移の場合
    if (queryParams['tab'] == 'study') {
      return 1;
    }
    // カテゴリー、例文一覧は学習タブ
    if (location.startsWith(category)) return 1;
    if (location.startsWith(exampleList)) return 1;
    // その他のページ
    if (location.startsWith(home)) return 0;
    if (location.startsWith(favorites)) return 2;
    if (location.startsWith(profile)) return 3;

    return 0; // Default to home
  }
}
