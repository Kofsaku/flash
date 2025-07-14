import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/user.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/register_profile_screen.dart';
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
  static const String register = '/register';
  static const String registerProfile = '/register/profile-setup';
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
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: registerProfile,
          name: 'registerProfile',
          builder: (context, state) => const RegisterProfileScreen(),
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
            final uri = state.uri.toString();
            final queryParams = state.uri.queryParameters;
            print('Debug: Full path = ${state.fullPath}, Matched location = ${state.matchedLocation}, URI = $uri, Query params = $queryParams');
            return MainLayout(
              currentIndex: _getCurrentIndex(location, queryParams),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: home,
              name: 'home',
              builder: (context, state) {
                print('Debug: Home route built with query params: ${state.uri.queryParameters}');
                return const HomeScreen();
              },
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
                final categoryId = state.uri.queryParameters['categoryId'] ?? '';
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
            final exampleIndex = int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
            
            if (allLevels) {
              return StudyScreen.allLevels(initialIndex: exampleIndex);
            } else if (mixed && levelId.isNotEmpty) {
              return StudyScreen.mixed(levelId: levelId, initialIndex: exampleIndex);
            } else {
              return StudyScreen(categoryId: categoryId, initialIndex: exampleIndex);
            }
          },
        ),
        GoRoute(
          path: error,
          name: 'error',
          builder: (context, state) {
            final message = state.uri.queryParameters['message'] ?? 'An error occurred';
            return ErrorScreen(message: message);
          },
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        final isAuthenticated = appProvider.isAuthenticated;
        final profile = appProvider.currentUser?.profile;
        final hasValidProfile = _hasValidProfile(profile);
        
        print('Router: isAuthenticated = $isAuthenticated, hasValidProfile = $hasValidProfile');
        if (profile != null) {
          print('Router: Profile ageGroup = ${profile.ageGroup}, industry = ${profile.industry}');
        }
        
        final isOnAuthPages = [login, register, registerProfile].contains(state.matchedLocation);
        final isOnProfilePages = [profileStep1, profileStep2, profileStep3, profileStep4, profileStep5, quickStart].contains(state.matchedLocation);
        final isOnSplash = state.matchedLocation == splash;
        final isOnLoading = state.matchedLocation == loading;
        final isOnError = state.matchedLocation == error;

        if (isOnError) {
          return null;
        }

        if (isOnSplash) {
          return null;
        }

        if (!isAuthenticated && !isOnAuthPages) {
          return login;
        }

        // Only redirect to profile setup during registration flow
        // Existing users should go directly to home

        if (isAuthenticated && hasValidProfile && (isOnAuthPages || isOnProfilePages)) {
          print('Router: Redirecting to home (valid profile exists)');
          return home;
        }

        return null;
      },
    );
  }

  static bool _hasValidProfile(Profile? profile) {
    if (profile == null) {
      print('Router: Profile is null - returning false');
      return false;
    }
    
    // Check if basic required fields are present
    final hasBasicInfo = profile.ageGroup?.isNotEmpty == true &&
                        profile.occupation?.isNotEmpty == true &&
                        profile.englishLevel?.isNotEmpty == true;
    
    print('Router: Profile validity check:');
    print('  - ageGroup: "${profile.ageGroup}" (valid: ${profile.ageGroup?.isNotEmpty == true})');
    print('  - occupation: "${profile.occupation}" (valid: ${profile.occupation?.isNotEmpty == true})');
    print('  - englishLevel: "${profile.englishLevel}" (valid: ${profile.englishLevel?.isNotEmpty == true})');
    print('  - hasBasicInfo = $hasBasicInfo');
    
    return hasBasicInfo;
  }

  static int _getCurrentIndex(String location, Map<String, String> queryParams) {
    print('Debug: Current location = $location, Query params = $queryParams'); // デバッグ用
    
    // 学習タブからのホーム遷移の場合
    if (queryParams['tab'] == 'study') {
      print('Debug: Study tab detected via query param, returning index 1');
      return 1;
    }
    // カテゴリー、例文一覧は学習タブ
    if (location.startsWith(category)) return 1;
    if (location.startsWith(exampleList)) return 1;
    // その他のページ
    if (location.startsWith(home)) return 0;
    if (location.startsWith(favorites)) return 2;
    if (location.startsWith(profile)) return 3;
    
    print('Debug: Returning default index 0');
    return 0; // Default to home
  }
}