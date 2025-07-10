import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/profile_step1_screen.dart';
import 'screens/profile/profile_step2_screen.dart';
import 'screens/profile/profile_step3_screen.dart';
import 'screens/profile/profile_step4_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/example_list_screen.dart';
import 'screens/study/study_screen.dart';
import 'screens/error_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/main_layout.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileStep1 = '/profile/step1';
  static const String profileStep2 = '/profile/step2';
  static const String profileStep3 = '/profile/step3';
  static const String profileStep4 = '/profile/step4';
  static const String loading = '/loading';
  static const String home = '/home';
  static const String category = '/category';
  static const String exampleList = '/examples';
  static const String study = '/study';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
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
          path: loading,
          name: 'loading',
          builder: (context, state) => const LoadingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainLayout(
              currentIndex: _getCurrentIndex(state.matchedLocation),
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
            final exampleIndex = int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
            
            if (mixed && levelId.isNotEmpty) {
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
        final hasProfile = appProvider.currentUser?.profile != null;
        
        final isOnAuthPages = [login, register].contains(state.matchedLocation);
        final isOnProfilePages = [profileStep1, profileStep2, profileStep3, profileStep4].contains(state.matchedLocation);
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

        if (isAuthenticated && !hasProfile && !isOnProfilePages && !isOnLoading) {
          return profileStep1;
        }

        if (isAuthenticated && hasProfile && (isOnAuthPages || isOnProfilePages)) {
          return home;
        }

        return null;
      },
    );
  }

  static int _getCurrentIndex(String location) {
    // 学習タブからのホーム遷移の場合
    if (location.contains('tab=study')) return 1;
    if (location.startsWith(home)) return 0;
    if (location.startsWith(category)) return 1;
    if (location.startsWith(exampleList)) return 1;
    if (location.startsWith(favorites)) return 2;
    if (location.startsWith(profile)) return 3;
    return 0; // Default to home
  }
}