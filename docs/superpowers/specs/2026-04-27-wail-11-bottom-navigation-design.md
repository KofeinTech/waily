# WAIL-11 — Bottom Navigation Architecture

**Status:** Design approved 2026-04-27
**Branch:** `WAIL-11-bottom-navigation`
**Jira:** https://improvs.atlassian.net/browse/WAIL-11

## Goal

Stand up the navigation skeleton for Waily: a 5-tab bottom navigation bar
(Home, Meal, Chat, Hydration, Profile), tab-state preservation, route
guards keyed off auth state, and placeholder destination screens for each
tab. This unblocks parallel work on the real screens by fixing the route
tree and shell early.

## Non-goals

- Deep linking (URL-from-outside)
- Custom page transitions / animations
- Real screen implementations beyond placeholders
- Auth feature implementation (only the guard scaffold)

## Acceptance Criteria

1. Bottom nav bar with 5 tabs (Home, Meal, Chat, Hydration, Profile).
2. Routes defined for all main screens.
3. User can switch tabs and navigate to nested screens.
4. Back navigation works correctly on every screen, per tab.
5. Placeholder screens exist for all main sections.

## Key decisions (locked in brainstorming)

| Decision | Choice |
|---|---|
| Tab strategy | `StatefulShellRoute.indexedStack` (go_router 17 native) |
| Auth guard | Stub `AuthSessionGate` reading `SecureStorage` for `auth_token`, plugged into `GoRouter.redirect` via `refreshListenable`. Real `AuthCubit` will replace the stub later. |
| Demo screen | Move `DemoHomeScreen` to `/profile/dev-tools` (kept for debugging) |
| Placeholders | Minimal: `Scaffold` + centered tab name |
| Feature layout | Five feature folders under `lib/features/{home,meal,chat,hydration,profile}/`; `auth/` seeded with sign-in placeholder |
| Bottom nav widget | `lib/core/ui_kit/components/nav/app_bottom_nav.dart`, takes `StatefulNavigationShell` |

## Architecture

### Module layout

```
lib/
  core/
    router/
      app_router.dart            # GoRouter with StatefulShellRoute
      app_routes.dart            # Typed route name constants + paths
      auth_session_gate.dart     # Abstract gate + stub impl
    ui_kit/components/nav/
      app_bottom_nav.dart        # Receives StatefulNavigationShell, renders bar
      app_bottom_nav_item.dart   # Single tab item (icon + label, active/inactive)
  features/
    home/presentation/screens/home_screen.dart
    meal/presentation/screens/meal_screen.dart
    chat/presentation/screens/chat_screen.dart
    hydration/presentation/screens/hydration_screen.dart
    profile/presentation/screens/profile_screen.dart
    profile/presentation/screens/dev_tools_screen.dart   # ex DemoHomeScreen
    auth/presentation/screens/sign_in_placeholder_screen.dart
```

`features/core/presentation/screens/demo_home_screen.dart` is removed
once the move to `profile/.../dev_tools_screen.dart` is complete.

### Route tree

```
/sign-in                                  -- public, placeholder until auth lands
/                                         -- redirects to /home
StatefulShellRoute.indexedStack
  branch: /home                           -- HomeScreen
  branch: /meal                           -- MealScreen
  branch: /chat                           -- ChatScreen
  branch: /hydration                      -- HydrationScreen
  branch: /profile                        -- ProfileScreen
    /profile/dev-tools                    -- DevToolsScreen (former demo)
```

Each branch has its own `navigatorKey`; pushing a sub-route under a tab
keeps the back-stack scoped to that tab. Switching tabs is via
`shell.goBranch(index, initialLocation: index == shell.currentIndex)`
so re-tapping the same tab pops to its root.

### Auth guard

```dart
abstract class AuthSessionGate extends ChangeNotifier {
  bool get isAuthenticated;
  Future<void> refresh();
}

@LazySingleton(as: AuthSessionGate)
class StubAuthSessionGate extends ChangeNotifier implements AuthSessionGate {
  StubAuthSessionGate(this._secureStorage);
  final SecureStorage _secureStorage;

  bool _isAuthenticated = false;
  @override bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> refresh() async {
    final token = await _secureStorage.read('auth_token');
    final next = token != null && token.isNotEmpty;
    if (next != _isAuthenticated) {
      _isAuthenticated = next;
      notifyListeners();
    }
  }
}
```

Wired into the router:

```dart
GoRouter(
  refreshListenable: gate,
  redirect: (context, state) {
    final loggedIn = gate.isAuthenticated;
    final atSignIn = state.matchedLocation == '/sign-in';
    if (!loggedIn && !atSignIn) return '/sign-in';
    if (loggedIn && atSignIn) return '/home';
    return null;
  },
  routes: [...],
)
```

The router calls `gate.refresh()` once at app startup (in
`main.dart` after DI is configured) so the initial location is
correct without flicker. When the real auth feature lands, it just
replaces `StubAuthSessionGate` with an `AuthCubitBackedSessionGate` —
the redirect logic stays untouched.

### Bottom nav widget

`AppBottomNav` is a stateless widget that receives the
`StatefulNavigationShell` from the route builder and renders the bar
straight from the design tokens:

- Outer container: `#1D2534`, `width: double.infinity`, `height: 88`
  (matches Figma frame `Nav Bar`).
- Inner row: 5 `AppBottomNavItem` widgets, `MainAxisAlignment.center`,
  `CrossAxisAlignment.center`, `padding: EdgeInsets.fromLTRB(16, 12, 16, 0)`
  (from Figma `Menu List`).
- Each item: SVG icon from `Assets.icons.nav.<name>`, optional label,
  active/inactive variants — colors taken from `context.appColors` once
  the relevant tokens are confirmed against the design JSON during
  implementation (`/improvs:figma-check` will catch drift).

Tapping an item calls `shell.goBranch(index, initialLocation: index == shell.currentIndex)`.

### Placeholder screens

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Home', style: context.appTextStyles.s32w600())));
}
```

Identical pattern for Meal, Chat, Hydration, Profile. Profile's screen
adds a single button navigating to `/profile/dev-tools` so AC #3 / #4
(navigation + back) is exercisable end-to-end.

`SignInPlaceholderScreen` is a `Scaffold` + centered text "Sign-in
coming soon"; its only role is to satisfy the redirect target.

`DevToolsScreen` is the existing `DemoHomeScreen` body verbatim, just
renamed and relocated; the underlying notification-pipeline buttons are
preserved.

## Data flow

```
gate.refresh() -> SecureStorage.read('auth_token')
   |
   v
gate.notifyListeners()
   |
   v
GoRouter.refreshListenable picks up change -> re-runs redirect
   |
   v
authenticated -> /home (Shell renders)
unauthenticated -> /sign-in (placeholder)
```

Tab switching:

```
user taps AppBottomNavItem
   |
   v
shell.goBranch(index)
   |
   v
GoRouter swaps inner navigator; back-stack of inactive tabs preserved
```

## Error handling

- `gate.refresh()` failures are swallowed with a Talker log; treat as
  unauthenticated. The stub never throws because `SecureStorage.read`
  returns `null` on miss, but the real impl may, so the contract is
  defensive from day one.
- Unknown routes fall through to GoRouter's default `errorBuilder` —
  out of scope to customize here.

## Testing

- Widget test: `AppBottomNav` renders 5 items, tapping each updates
  active visual state. Use `MaterialApp.router` with a real
  `StatefulShellRoute` so `goBranch` is exercised.
- Widget test: switching tabs preserves nested state. Pump `Profile`,
  navigate to `/profile/dev-tools`, switch to `/home`, switch back to
  `/profile` and assert the dev-tools page is still the visible route.
- Unit test: `StubAuthSessionGate.refresh()` flips `isAuthenticated`
  based on `SecureStorage.read` and notifies listeners only on change.
- Widget test: redirect routes unauthenticated user from `/home` to
  `/sign-in`, and authenticated user from `/sign-in` to `/home`.
- Mocks: `MockSecureStorage` via `@GenerateMocks`.

Tests live under `test/core/router/` and `test/features/<name>/...`
mirroring lib/.

## Migration / cleanup

- Remove `lib/features/core/presentation/screens/demo_home_screen.dart`
  after content is moved.
- Remove `app_router.dart`'s old single demo route.
- `app.dart` stays unchanged — already passes `appRouter` to
  `MaterialApp.router`.

## Out of scope explicitly

- Deep linking (parsing external URLs into nested locations)
- Custom transitions
- Localizing tab labels (will do in the per-tab feature tickets when
  the screens become real)
- Tablet/landscape adaptations
