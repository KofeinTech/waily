import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/sign_in_placeholder_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/hydration/presentation/screens/hydration_screen.dart';
import '../../features/meal/presentation/screens/meal_screen.dart';
import '../../features/profile/presentation/screens/dev_tools_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../di/injection.dart';
import '../ui_kit/components/nav/app_bottom_nav.dart';
import 'app_routes.dart';
import 'auth_session_gate.dart';

/// Application-wide router.
///
/// Lazy top-level final — first read happens inside `App.build`, by which
/// time DI is configured (see `main.dart`).
final GoRouter appRouter = _buildAppRouter();

GoRouter _buildAppRouter() {
  final gate = getIt<AuthSessionGate>();

  return GoRouter(
    initialLocation: AppRoutes.homePath,
    refreshListenable: gate,
    redirect: (context, state) {
      final atSignIn = state.matchedLocation == AppRoutes.signInPath;
      if (!gate.isAuthenticated && !atSignIn) return AppRoutes.signInPath;
      if (gate.isAuthenticated && atSignIn) return AppRoutes.homePath;
      return null;
    },
    routes: [
      GoRoute(
        name: AppRoutes.signIn,
        path: AppRoutes.signInPath,
        builder: (context, state) => const SignInPlaceholderScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.home,
                path: AppRoutes.homePath,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.meal,
                path: AppRoutes.mealPath,
                builder: (context, state) => const MealScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.chat,
                path: AppRoutes.chatPath,
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.hydration,
                path: AppRoutes.hydrationPath,
                builder: (context, state) => const HydrationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.profile,
                path: AppRoutes.profilePath,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    name: AppRoutes.devTools,
                    path: AppRoutes.devToolsSubPath,
                    builder: (context, state) => const DevToolsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
