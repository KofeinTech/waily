# WAIL-11 — Bottom Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the demo router with a 5-tab bottom navigation shell, stub auth guard, and placeholder destinations for Home / Meal / Chat / Hydration / Profile.

**Architecture:** `StatefulShellRoute.indexedStack` from go_router 17, branch-per-tab navigators for independent back-stacks. A `ChangeNotifier`-shaped `AuthSessionGate` (stub backed by `SecureStorage.read('auth_token')`) is plugged into `GoRouter.refreshListenable` and a top-level `redirect` that gates everything except `/sign-in`. Each tab gets its own feature folder under `lib/features/`.

**Tech Stack:** Flutter 3.10, go_router 17.2.2, injectable + get_it, flutter_secure_storage (already wrapped by `SecureStorage`), existing `WailyMenuItemContainer` from the WAIL-10 UI kit.

**Spec:** [`docs/superpowers/specs/2026-04-27-wail-11-bottom-navigation-design.md`](../specs/2026-04-27-wail-11-bottom-navigation-design.md)

**Conventions:**
- All commands prefixed with `fvm flutter` per CLAUDE.md.
- Run `dart run build_runner build --delete-conflicting-outputs` after changing Mockito mock targets or adding `@injectable`/`@LazySingleton(as: ...)`.
- Each task ends with a `feat:`/`refactor:`/`test:` commit per the repo's commit conventions.
- Hooks already enforce `dart format` after every edit.

---

## File Structure

**Create:**
- `lib/core/router/app_routes.dart` — typed route names, paths, tab labels.
- `lib/core/router/auth_session_gate.dart` — abstract gate + `StubAuthSessionGate` impl.
- `lib/core/ui_kit/components/nav/app_bottom_nav.dart` — bottom nav bar, drives `StatefulNavigationShell`.
- `lib/features/home/presentation/screens/home_screen.dart` — placeholder.
- `lib/features/meal/presentation/screens/meal_screen.dart` — placeholder.
- `lib/features/chat/presentation/screens/chat_screen.dart` — placeholder (Waily AI tab).
- `lib/features/hydration/presentation/screens/hydration_screen.dart` — placeholder.
- `lib/features/profile/presentation/screens/profile_screen.dart` — placeholder + nav button to dev-tools.
- `lib/features/profile/presentation/screens/dev_tools_screen.dart` — relocated `DemoHomeScreen`.
- `lib/features/auth/presentation/screens/sign_in_placeholder_screen.dart` — redirect target.
- `test/core/router/auth_session_gate_test.dart`
- `test/core/router/app_router_redirect_test.dart` — auth redirect coverage.
- `test/core/router/app_router_shell_test.dart` — tab switching + back-stack preservation.
- `test/core/ui_kit/components/nav/app_bottom_nav_test.dart`

**Modify:**
- `lib/core/router/app_router.dart` — full rewrite (StatefulShellRoute + redirect).
- `lib/main.dart` — call `gate.refresh()` once after DI is configured, before `runApp`.
- `test/features/core/mocks.dart` — add `SecureStorage` to `@GenerateMocks`.
- `test/widget_test.dart` — replace demo-screen expectations with sign-in / home expectations under the new router.

**Delete:**
- `lib/features/core/presentation/screens/demo_home_screen.dart` — content moved to `dev_tools_screen.dart`.

---

## Task 1: Add typed route constants

**Why first:** Every later task references these names — locking them in once removes magic strings everywhere else.

**Files:**
- Create: `lib/core/router/app_routes.dart`

- [ ] **Step 1: Create `lib/core/router/app_routes.dart`**

```dart
/// Typed route names and paths for go_router.
///
/// Names are used with `context.goNamed(...)`. Paths are used inside
/// the [GoRoute] / [StatefulShellBranch] tree.
class AppRoutes {
  AppRoutes._();

  // --- Public ---
  static const String signIn = 'signIn';
  static const String signInPath = '/sign-in';

  // --- Shell branches ---
  static const String home = 'home';
  static const String homePath = '/home';

  static const String meal = 'meal';
  static const String mealPath = '/meal';

  static const String chat = 'chat';
  static const String chatPath = '/chat';

  static const String hydration = 'hydration';
  static const String hydrationPath = '/hydration';

  static const String profile = 'profile';
  static const String profilePath = '/profile';

  // --- Profile sub-routes ---
  static const String devTools = 'devTools';
  static const String devToolsSubPath = 'dev-tools';
  static const String devToolsFullPath = '/profile/dev-tools';

  /// Order of the 5 bottom-nav branches. Index here drives
  /// `StatefulShellRoute.indexedStack` and `AppBottomNav`.
  static const List<String> shellBranchOrder = [
    home,
    meal,
    chat,
    hydration,
    profile,
  ];

  /// Centered placeholder labels until per-tab features are built.
  static const Map<String, String> tabLabels = {
    home: 'Home',
    meal: 'Meal',
    chat: 'Chat',
    hydration: 'Hydration',
    profile: 'Profile',
  };
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/router/app_routes.dart
git commit -m "feat(wail-11): add AppRoutes constants for the shell + sign-in"
```

---

## Task 2: Build the auth session gate (abstract + stub) + tests

**Files:**
- Create: `lib/core/router/auth_session_gate.dart`
- Create: `test/core/router/auth_session_gate_test.dart`
- Modify: `test/features/core/mocks.dart`

- [ ] **Step 1: Add `SecureStorage` to the mock generation list**

Edit `test/features/core/mocks.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:talker/talker.dart';
import 'package:waily/features/core/domain/managers/notification_manager.dart';
import 'package:waily/features/core/domain/sources/secure_storage.dart';

@GenerateMocks([Talker, NotificationManager, Dio, SecureStorage])
void main() {}
```

- [ ] **Step 2: Regenerate mocks**

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `test/features/core/mocks.mocks.dart` now contains `MockSecureStorage`. No errors.

- [ ] **Step 3: Write the failing test for `StubAuthSessionGate`**

Create `test/core/router/auth_session_gate_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/router/auth_session_gate.dart';

import '../../features/core/mocks.mocks.dart';

void main() {
  group('StubAuthSessionGate', () {
    late MockSecureStorage storage;
    late StubAuthSessionGate gate;

    setUp(() {
      storage = MockSecureStorage();
      gate = StubAuthSessionGate(storage);
    });

    test('isAuthenticated is false before refresh', () {
      expect(gate.isAuthenticated, isFalse);
    });

    test('refresh() flips to true when storage holds a non-empty token', () async {
      when(storage.read('auth_token')).thenAnswer((_) async => 'jwt-value');

      var notified = 0;
      gate.addListener(() => notified++);

      await gate.refresh();

      expect(gate.isAuthenticated, isTrue);
      expect(notified, 1);
    });

    test('refresh() stays false on null token and does not notify', () async {
      when(storage.read('auth_token')).thenAnswer((_) async => null);

      var notified = 0;
      gate.addListener(() => notified++);

      await gate.refresh();

      expect(gate.isAuthenticated, isFalse);
      expect(notified, 0);
    });

    test('refresh() stays false on empty string token', () async {
      when(storage.read('auth_token')).thenAnswer((_) async => '');

      await gate.refresh();

      expect(gate.isAuthenticated, isFalse);
    });

    test('refresh() does not notify when state is unchanged', () async {
      when(storage.read('auth_token')).thenAnswer((_) async => 'jwt');
      await gate.refresh();

      var notified = 0;
      gate.addListener(() => notified++);

      await gate.refresh();

      expect(notified, 0);
    });

    test('refresh() swallows storage errors and treats user as unauthenticated', () async {
      when(storage.read('auth_token')).thenThrow(Exception('keychain miss'));

      await gate.refresh();

      expect(gate.isAuthenticated, isFalse);
    });
  });
}
```

- [ ] **Step 4: Run tests to verify they fail**

```bash
fvm flutter test test/core/router/auth_session_gate_test.dart
```

Expected: FAIL with "Target of URI doesn't exist" / "AuthSessionGate not defined".

- [ ] **Step 5: Implement `auth_session_gate.dart`**

Create `lib/core/router/auth_session_gate.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/core/domain/sources/secure_storage.dart';

/// Tracks whether the current user has an active session.
///
/// Plugged into `GoRouter.refreshListenable` so the router re-evaluates
/// its `redirect` whenever the gate state changes. The interface stays
/// stable when the real auth feature lands — only the implementation
/// behind `@LazySingleton(as: AuthSessionGate)` changes.
abstract class AuthSessionGate extends ChangeNotifier {
  bool get isAuthenticated;

  /// Re-reads the underlying source of truth. Idempotent.
  Future<void> refresh();
}

/// Storage key under which the session token lives.
///
/// Kept as a top-level constant so the future real auth implementation
/// can write to the same slot.
const String authTokenStorageKey = 'auth_token';

/// Default implementation until the auth feature ships.
///
/// Reads the token directly from [SecureStorage]. The future
/// `AuthCubit`-backed gate will replace this binding via DI.
@LazySingleton(as: AuthSessionGate)
class StubAuthSessionGate extends ChangeNotifier implements AuthSessionGate {
  StubAuthSessionGate(this._secureStorage);

  final SecureStorage _secureStorage;

  bool _isAuthenticated = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> refresh() async {
    final next = await _readToken();
    if (next != _isAuthenticated) {
      _isAuthenticated = next;
      notifyListeners();
    }
  }

  Future<bool> _readToken() async {
    try {
      final token = await _secureStorage.read(authTokenStorageKey);
      return token != null && token.isNotEmpty;
    } catch (_) {
      // Treat any storage failure as unauthenticated. This is intentional —
      // a corrupt/locked keychain should not strand the user inside the shell.
      return false;
    }
  }
}
```

- [ ] **Step 6: Regenerate DI bindings**

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `injection.config.dart` updated to register `StubAuthSessionGate as AuthSessionGate`. No errors.

- [ ] **Step 7: Run tests to verify they pass**

```bash
fvm flutter test test/core/router/auth_session_gate_test.dart
```

Expected: PASS, 6 tests.

- [ ] **Step 8: Commit**

```bash
git add lib/core/router/auth_session_gate.dart \
        test/core/router/auth_session_gate_test.dart \
        test/features/core/mocks.dart \
        test/features/core/mocks.mocks.dart \
        lib/core/di/injection.config.dart
git commit -m "feat(wail-11): add stub AuthSessionGate backed by SecureStorage"
```

---

## Task 3: Create the five tab placeholder screens

**Why grouped:** The five screens are identical in shape — write once, repeat with the right strings.

**Files:**
- Create: `lib/features/home/presentation/screens/home_screen.dart`
- Create: `lib/features/meal/presentation/screens/meal_screen.dart`
- Create: `lib/features/chat/presentation/screens/chat_screen.dart`
- Create: `lib/features/hydration/presentation/screens/hydration_screen.dart`

(Profile is built separately in Task 4 because it gets a navigation button.)

- [ ] **Step 1: Create `home_screen.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

/// Placeholder destination for the Home tab. Replaced when the real
/// home feature ships.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Text(
          AppRoutes.tabLabels[AppRoutes.home]!,
          style: context.appTextStyles.s32w600(),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create `meal_screen.dart`**

Same structure, `AppRoutes.meal` instead of `AppRoutes.home`. Class name `MealScreen`.

```dart
import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Text(
          AppRoutes.tabLabels[AppRoutes.meal]!,
          style: context.appTextStyles.s32w600(),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create `chat_screen.dart`**

Same structure, `AppRoutes.chat`, class `ChatScreen`.

```dart
import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Text(
          AppRoutes.tabLabels[AppRoutes.chat]!,
          style: context.appTextStyles.s32w600(),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Create `hydration_screen.dart`**

Same structure, `AppRoutes.hydration`, class `HydrationScreen`.

```dart
import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

class HydrationScreen extends StatelessWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Text(
          AppRoutes.tabLabels[AppRoutes.hydration]!,
          style: context.appTextStyles.s32w600(),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Verify analyzer is clean**

```bash
fvm flutter analyze lib/features/home lib/features/meal lib/features/chat lib/features/hydration
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/home lib/features/meal lib/features/chat lib/features/hydration
git commit -m "feat(wail-11): add Home/Meal/Chat/Hydration placeholder screens"
```

---

## Task 4: Profile screen + Dev Tools sub-route (former Demo screen)

**Files:**
- Create: `lib/features/profile/presentation/screens/profile_screen.dart`
- Create: `lib/features/profile/presentation/screens/dev_tools_screen.dart`
- Delete: `lib/features/core/presentation/screens/demo_home_screen.dart`

- [ ] **Step 1: Create `dev_tools_screen.dart` by porting `DemoHomeScreen` verbatim**

```dart
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../core/domain/entities/app_notification.dart';
import '../../../core/domain/managers/notification_manager.dart';
import '../../../core/domain/use_cases/no_params.dart';
import '../../../core/domain/use_cases/trigger_demo_error_use_case.dart';

/// Internal dev-tools screen. Exercises the notification pipeline
/// end-to-end. Reachable only from `Profile -> Dev tools`.
class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waily — state mgmt demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => getIt<NotificationManager>().sendNotification(
                const AppNotification.success(message: 'Hello from manager'),
              ),
              child: const Text('Show notification (direct)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  getIt<TriggerDemoErrorUseCase>().call(const NoParams()),
              child: const Text('Trigger error via use case'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create `profile_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

/// Placeholder destination for the Profile tab. Hosts a link to the
/// internal dev-tools page so back navigation can be exercised
/// end-to-end (AC #4).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppRoutes.tabLabels[AppRoutes.profile]!,
              style: context.appTextStyles.s32w600(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.devTools),
              child: const Text('Dev tools'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Delete the old demo screen**

```bash
git rm lib/features/core/presentation/screens/demo_home_screen.dart
```

- [ ] **Step 4: Verify analyzer is clean**

```bash
fvm flutter analyze lib/features/profile
```

Expected: `No issues found!` (the demo screen had no other importers — `widget_test.dart` references it via `App` mounting, which we'll fix in Task 9.)

- [ ] **Step 5: Commit**

```bash
git add lib/features/profile
git commit -m "refactor(wail-11): move DemoHomeScreen to /profile/dev-tools"
```

---

## Task 5: Sign-in placeholder screen

**Files:**
- Create: `lib/features/auth/presentation/screens/sign_in_placeholder_screen.dart`

- [ ] **Step 1: Create the screen**

```dart
import 'package:flutter/material.dart';

import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

/// Stand-in for the future sign-in screen. Exists so that the auth
/// guard has a valid redirect target while the real auth feature is
/// being built.
class SignInPlaceholderScreen extends StatelessWidget {
  const SignInPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Text(
          'Sign-in coming soon',
          style: context.appTextStyles.s20w600(),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth
git commit -m "feat(wail-11): add sign-in placeholder for the auth guard target"
```

---

## Task 6: Bottom nav widget + tests

**Files:**
- Create: `lib/core/ui_kit/components/nav/app_bottom_nav.dart`
- Create: `test/core/ui_kit/components/nav/app_bottom_nav_test.dart`

The widget reuses the existing `WailyMenuItemContainer` (built in WAIL-10) for each item, wraps them in a horizontal row inside an 88-tall container painted with `AppColors.surface` (#1D2534, matches the Figma `Nav Bar` fill).

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/router/app_routes.dart';
import 'package:waily/core/ui_kit/components/nav/app_bottom_nav.dart';

import '../../helpers/test_theme_wrapper.dart';

class _FakeShell extends StatelessWidget {
  const _FakeShell({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}

void main() {
  testWidgets('renders 5 items, one per shell branch', (tester) async {
    await tester.pumpWidget(
      TestThemeWrapper(
        child: _FakeShell(currentIndex: 0, onTap: (_) {}),
      ),
    );

    for (final branch in AppRoutes.shellBranchOrder) {
      expect(
        find.byKey(ValueKey('app-bottom-nav-item-$branch')),
        findsOneWidget,
        reason: 'missing nav item for $branch',
      );
    }
  });

  testWidgets('shows label only on the active item', (tester) async {
    await tester.pumpWidget(
      TestThemeWrapper(
        child: _FakeShell(currentIndex: 2, onTap: (_) {}),
      ),
    );

    // Active branch = index 2 = 'chat'.
    expect(find.text(AppRoutes.tabLabels[AppRoutes.chat]!), findsOneWidget);
    // Inactive branches do not show their label inside the nav bar.
    expect(find.text(AppRoutes.tabLabels[AppRoutes.home]!), findsNothing);
    expect(find.text(AppRoutes.tabLabels[AppRoutes.profile]!), findsNothing);
  });

  testWidgets('tapping an item invokes onTap with that index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      TestThemeWrapper(
        child: _FakeShell(currentIndex: 0, onTap: (i) => tapped = i),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('app-bottom-nav-item-hydration')));
    await tester.pump();

    expect(tapped, 3); // hydration is index 3 in shellBranchOrder.
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
fvm flutter test test/core/ui_kit/components/nav/app_bottom_nav_test.dart
```

Expected: FAIL with "Target of URI doesn't exist".

- [ ] **Step 3: Implement `app_bottom_nav.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../router/app_routes.dart';
import '../../extensions/theme_context_extension.dart';
import '../../theme/app_colors.dart';
import '../containers/waily_menu_item_container.dart';

/// Bottom navigation bar driving the 5-branch shell.
///
/// Receives the active branch index and a tap callback from the
/// hosting `StatefulShellRoute`. Keeps zero state of its own.
///
/// Geometry / fill come straight from the Figma `Nav Bar` frame
/// (393x88, surface fill, MenuList padding 16/12).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  /// Index into [AppRoutes.shellBranchOrder].
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _height = 88;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < AppRoutes.shellBranchOrder.length; i++)
                  _buildItem(context, i),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final branch = AppRoutes.shellBranchOrder[index];
    return WailyMenuItemContainer(
      key: ValueKey('app-bottom-nav-item-$branch'),
      icon: _iconFor(branch),
      label: AppRoutes.tabLabels[branch]!,
      isActive: index == currentIndex,
      onPressed: () => onTap(index),
    );
  }

  SvgGenImage _iconFor(String branch) {
    switch (branch) {
      case AppRoutes.home:
        return Assets.icons.nav.home;
      case AppRoutes.meal:
        return Assets.icons.nav.meal;
      case AppRoutes.chat:
        return Assets.icons.nav.waily;
      case AppRoutes.hydration:
        return Assets.icons.nav.hydration;
      case AppRoutes.profile:
        return Assets.icons.nav.profile;
    }
    throw StateError('Unknown nav branch: $branch');
  }
}
```

The unused `context.appColors` import wasn't pulled because this widget is intentionally locked to `AppColors.surface` to match the Figma `Nav Bar` fill exactly.

- [ ] **Step 4: Run test to verify it passes**

```bash
fvm flutter test test/core/ui_kit/components/nav/app_bottom_nav_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/components/nav \
        test/core/ui_kit/components/nav
git commit -m "feat(wail-11): add AppBottomNav widget driving the shell"
```

---

## Task 7: Wire up the StatefulShellRoute + redirect

**Files:**
- Modify: `lib/core/router/app_router.dart`

This is the keystone. After this commit the app boots into a real shell.

- [ ] **Step 1: Replace `app_router.dart` end-to-end**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../ui_kit/components/nav/app_bottom_nav.dart';
import '../../features/auth/presentation/screens/sign_in_placeholder_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/hydration/presentation/screens/hydration_screen.dart';
import '../../features/meal/presentation/screens/meal_screen.dart';
import '../../features/profile/presentation/screens/dev_tools_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
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
```

- [ ] **Step 2: Verify analyzer is clean**

```bash
fvm flutter analyze lib/core/router
```

Expected: `No issues found!`.

- [ ] **Step 3: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat(wail-11): wire StatefulShellRoute + auth redirect"
```

---

## Task 8: Refresh the auth gate at startup

**Files:**
- Modify: `lib/main.dart`

Without this step the first frame paints with `isAuthenticated == false`, immediately followed by a redirect to `/sign-in`. Awaiting `gate.refresh()` before `runApp` makes the initial location correct from the first frame.

- [ ] **Step 1: Update `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';
import 'package:waily/core/env/env.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/observers/app_bloc_observer.dart';
import 'core/router/auth_session_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initEnv();
  configureDependencies();
  Bloc.observer = AppBlocObserver(getIt<Talker>());
  await getIt<AuthSessionGate>().refresh();
  runApp(const App());
}
```

- [ ] **Step 2: Verify analyzer is clean**

```bash
fvm flutter analyze lib/main.dart
```

Expected: `No issues found!`.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat(wail-11): refresh auth gate at startup before runApp"
```

---

## Task 9: Update `widget_test.dart` for the new shell

**Files:**
- Modify: `test/widget_test.dart`

The existing test asserts `'Waily — state mgmt demo'` shows up at boot. With the new shell that text only lives on `/profile/dev-tools`, and an unauthenticated user is sent to `/sign-in`. Replace the assertions with the now-correct flow.

- [ ] **Step 1: Replace `test/widget_test.dart`**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waily/app.dart';
import 'package:waily/core/di/injection.dart';
import 'package:waily/core/env/env.dart';

void main() {
  setUp(() {
    resetEnvForTesting();
    dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.com
ENABLE_LOGGING=false
''');
    SharedPreferences.setMockInitialValues({});
    configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
    resetEnvForTesting();
  });

  testWidgets('App boots into the sign-in placeholder when no token is stored',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Sign-in coming soon'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test**

```bash
fvm flutter test test/widget_test.dart
```

Expected: PASS, 1 test. (`gate.refresh()` is only called from `main()`, which the widget test never enters — so `_isAuthenticated` keeps its `false` default and the initial redirect lands on `/sign-in` without ever touching the keychain.)

- [ ] **Step 3: Commit**

```bash
git add test/widget_test.dart
git commit -m "test(wail-11): boot test now asserts sign-in placeholder is shown"
```

---

## Task 10: Router redirect tests (auth gate gating the shell)

**Files:**
- Create: `test/core/router/app_router_redirect_test.dart`

Tests the `redirect` callback in isolation by building a small `GoRouter` with the same wiring but a hand-controlled gate.

- [ ] **Step 1: Write the test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waily/core/router/app_routes.dart';
import 'package:waily/core/router/auth_session_gate.dart';

class _FakeGate extends ChangeNotifier implements AuthSessionGate {
  bool _isAuthenticated;

  _FakeGate({required bool initial}) : _isAuthenticated = initial;

  @override
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    if (value == _isAuthenticated) return;
    _isAuthenticated = value;
    notifyListeners();
  }

  @override
  Future<void> refresh() async {}
}

GoRouter _routerFor(_FakeGate gate) {
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
        builder: (_, __) => const Scaffold(body: Text('sign-in')),
      ),
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.homePath,
        builder: (_, __) => const Scaffold(body: Text('home')),
      ),
    ],
  );
}

void main() {
  testWidgets('unauthenticated user is sent from /home to /sign-in',
      (tester) async {
    final gate = _FakeGate(initial: false);
    final router = _routerFor(gate);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('sign-in'), findsOneWidget);
    expect(find.text('home'), findsNothing);
  });

  testWidgets('authenticated user is sent from /sign-in to /home',
      (tester) async {
    final gate = _FakeGate(initial: true);
    final router = _routerFor(gate);
    router.go(AppRoutes.signInPath);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.text('sign-in'), findsNothing);
  });

  testWidgets('changing gate state re-evaluates redirect', (tester) async {
    final gate = _FakeGate(initial: false);
    final router = _routerFor(gate);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('sign-in'), findsOneWidget);

    gate.setAuthenticated(true);
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test**

```bash
fvm flutter test test/core/router/app_router_redirect_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 3: Commit**

```bash
git add test/core/router/app_router_redirect_test.dart
git commit -m "test(wail-11): cover auth-gated redirect transitions"
```

---

## Task 11: Shell tab-switching + back-stack preservation tests

**Files:**
- Create: `test/core/router/app_router_shell_test.dart`

Builds a minimal `StatefulShellRoute` to verify nested-route state is preserved when switching tabs (AC #3 + #4).

- [ ] **Step 1: Write the test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _buildShellRouter() {
  return GoRouter(
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => Scaffold(
          body: shell,
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < 2; i++)
                TextButton(
                  key: ValueKey('tab-$i'),
                  onPressed: () => shell.goBranch(i,
                      initialLocation: i == shell.currentIndex),
                  child: Text('tab $i'),
                ),
            ],
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/a',
                builder: (_, __) => const Scaffold(body: Text('A root')),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, __) => const Scaffold(body: Text('A detail')),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/b',
                builder: (_, __) => const Scaffold(body: Text('B root')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('tab switch preserves nested route on the inactive branch',
      (tester) async {
    final router = _buildShellRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('A root'), findsOneWidget);

    // Push a detail under tab A.
    router.go('/a/detail');
    await tester.pumpAndSettle();
    expect(find.text('A detail'), findsOneWidget);

    // Switch to tab B.
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('B root'), findsOneWidget);

    // Back to tab A — the detail should still be the visible route.
    await tester.tap(find.byKey(const ValueKey('tab-0')));
    await tester.pumpAndSettle();
    expect(find.text('A detail'), findsOneWidget);
  });

  testWidgets('re-tapping the active tab pops to its branch root',
      (tester) async {
    final router = _buildShellRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/a/detail');
    await tester.pumpAndSettle();
    expect(find.text('A detail'), findsOneWidget);

    // Tab 0 is already active — tapping it must reset to /a.
    await tester.tap(find.byKey(const ValueKey('tab-0')));
    await tester.pumpAndSettle();

    expect(find.text('A root'), findsOneWidget);
    expect(find.text('A detail'), findsNothing);
  });
}
```

- [ ] **Step 2: Run the test**

```bash
fvm flutter test test/core/router/app_router_shell_test.dart
```

Expected: PASS, 2 tests.

- [ ] **Step 3: Commit**

```bash
git add test/core/router/app_router_shell_test.dart
git commit -m "test(wail-11): cover shell tab back-stack preservation"
```

---

## Task 12: Final verification

- [ ] **Step 1: Run the entire test suite**

```bash
fvm flutter test
```

Expected: ALL PASS, no skipped tests, no warnings.

- [ ] **Step 2: Run the analyzer over the whole project**

```bash
fvm flutter analyze
```

Expected: `No issues found!`.

- [ ] **Step 3: Format check**

```bash
dart format --set-exit-if-changed lib test
```

Expected: exit 0 (the post-edit hook should already keep this clean, this is a paranoia check).

- [ ] **Step 4: Smoke run on a simulator (manual)**

```bash
fvm flutter run
```

In the running app:
- App boots into `/sign-in` (text "Sign-in coming soon").
- Manually inject a token via `flutter_secure_storage` is out of scope here — just confirm the unauthenticated path renders correctly and there are no console errors.

To briefly validate the shell visually, temporarily change `_buildAppRouter`'s `redirect` to `(context, state) => null;`, hot-restart, then:
- Tap each of the 5 tabs — visible label switches.
- On Profile, tap "Dev tools" → see the demo notification screen → press the back arrow → return to Profile.
- Switch from Profile (with dev-tools open) to Home → switch back to Profile → dev-tools is still on top.
- Re-tap the active Profile tab → pops back to Profile root.

Restore the redirect before continuing.

- [ ] **Step 5: Update WAIL-11 in Jira via `/improvs:finish` flow** (out of scope for this plan — handled by the standard finishing skill once the work is reviewed and PR-ready).
