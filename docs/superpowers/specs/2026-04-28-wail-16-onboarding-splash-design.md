# WAIL-16 — Onboarding Splash Screen

**Status:** Design approved 2026-04-28
**Branch:** `WAIL-16-onboarding-splash`
**Jira:** https://improvs.atlassian.net/browse/WAIL-16
**Figma:** node `145:16307` — `design/screens/splash_screen.json`

## Goal

Stand up the first screen of the onboarding flow: a branded splash that
fades in, displays the Waily logo and a welcome message, auto-advances
to the next onboarding step after 2 seconds (or on tap), and is shown
only on the first launch. The work also scaffolds a new `onboarding/`
feature module and a placeholder `welcome` route so future onboarding
steps (WAIL-17+) plug in without re-routing.

## Non-goals

- Native (pre-Flutter) splash screen
- The real Logo asset (180×56 wordmark) — temporary `Text('Waily')`
  placeholder used until the asset lands; replacing it is a follow-up
- Subsequent onboarding screens (main goal, name/sex/height, etc.)
- Localization (l10n) — welcome text hardcoded in a feature constants file
- Multi-page tutorial carousel
- Tablet-optimised layout polishing — design is phone-first; the splash
  works on tablets but does not redistribute its empty top space

## Acceptance Criteria

1. Splash screen displays the app logo, branding, and welcome message
   per the Figma design (logo via temporary placeholder, see Risks).
2. The screen auto-advances to the next onboarding step after **2.0 s**
   or immediately on tap anywhere on the screen.
3. Entrance and exit transitions are smooth fades.
4. The screen renders correctly on both iOS and Android.
5. The screen renders correctly on phones and tablets (no overflow,
   contents stay readable across sizes).

## Key decisions (locked in brainstorming)

| Decision | Choice |
|---|---|
| Module placement | New `lib/features/onboarding/` with full `presentation/domain/data/` layering, matching CLAUDE.md conventions |
| Persistence | Single boolean flag `onboarding_splash_seen` in `LocalStorage` (SharedPreferences). Set when the splash advances. |
| Navigation target on advance | Placeholder route `/onboarding/welcome` (scaffolded by this ticket) so future onboarding steps replace the placeholder without further router churn |
| Auto-advance timing | 2.0 s (lower bound of the AC range) |
| Tap-to-skip area | Whole screen via root `GestureDetector` |
| Transition | Custom `GoRouter` `pageBuilder` with `FadeTransition` for both `/onboarding/splash` and `/onboarding/welcome`, 400 ms |
| Logo | Temporary `Text('Waily')` placeholder sized to a 180×56 box; real SVG follow-up |
| Welcome text | Hardcoded constant in `lib/features/onboarding/presentation/onboarding_strings.dart` |
| Auth gate interaction | Onboarding redirect runs **before** auth redirect; once `splash_seen=true` the user falls through to the existing auth gate |
| State machine | Cubit holds `initial → visible → advancing`; widget owns `AnimationController` (vsync, timing) and reacts via `BlocListener` |
| Navigation responsibility | The widget calls `context.goNamed(onboardingWelcome)` after the fade-out completes; the router redirect does **not** drive the splash-to-welcome transition. Redirect only enforces "new users hit `/onboarding/splash`" and "splash is unreachable once seen" on cold starts |
| Repository as plain class | `OnboardingFlagRepositoryImpl` is **not** a `Listenable`. The flag is written once and consumed synchronously by the redirect on each navigation; live `notifyListeners` would yank the user off the splash mid-fade-out |
| Loading the flag | Async `init()` on the repo, awaited in `main.dart` before the router is read (mirrors `AuthSessionGate.refresh()`) |

## Architecture

### Module layout

```
lib/features/onboarding/
  presentation/
    bloc/
      onboarding_splash_cubit.dart
      onboarding_splash_state.dart        # Freezed sealed: initial, visible, advancing
    router/
      onboarding_routes.dart              # path/name constants for the feature
      onboarding_router.dart              # GoRoute factory + redirect helper
    screens/
      onboarding_splash_screen.dart
      onboarding_welcome_placeholder_screen.dart
    widgets/
      splash_background.dart              # gradient container
      splash_content.dart                 # logo placeholder + description
    onboarding_strings.dart               # private const welcomeMessage
  domain/
    repositories/
      onboarding_flag_repository.dart     # abstract: bool isSplashSeen, init(), markSplashSeen()
    use_cases/
      mark_onboarding_splash_seen_use_case.dart   # AsyncUseCase<NoParams, void>
      is_onboarding_splash_seen_use_case.dart     # SyncUseCase<NoParams, bool>
  data/
    repositories/
      onboarding_flag_repository_impl.dart        # @LazySingleton(as: OnboardingFlagRepository), extends ChangeNotifier
    sources/
      onboarding_local_source.dart                # interface
      onboarding_local_source_impl.dart           # @Injectable(as: OnboardingLocalSource); wraps LocalStorage with key 'onboarding_splash_seen'
```

Tests mirror `lib/` under `test/`:

```
test/features/onboarding/
  data/repositories/onboarding_flag_repository_impl_test.dart
  domain/use_cases/mark_onboarding_splash_seen_use_case_test.dart
  domain/use_cases/is_onboarding_splash_seen_use_case_test.dart
  presentation/bloc/onboarding_splash_cubit_test.dart
  presentation/screens/onboarding_splash_screen_test.dart
```

### Touched outside the feature

- `lib/core/router/app_routes.dart` — add `onboardingSplash` /
  `onboardingWelcome` name + path constants.
- `lib/core/router/app_router.dart` — change `initialLocation` to
  `/onboarding/splash`; switch `refreshListenable` to
  `Listenable.merge([authGate, onboardingRepo])`; add the two onboarding
  `GoRoute`s **before** the `StatefulShellRoute`; extend `redirect` with
  the onboarding gate (see Redirect chain below).
- `lib/main.dart` — `await getIt<OnboardingFlagRepository>().init()`
  alongside the existing `authGate.refresh()`.

### Domain contracts

```dart
// onboarding_flag_repository.dart
abstract class OnboardingFlagRepository {
  bool get isSplashSeen;            // sync read of in-memory cache
  Future<void> init();              // load flag from LocalStorage; idempotent
  Future<void> markSplashSeen();    // persist + notifyListeners
}
```

`init()` is required because `LocalStorage` is fully async
(`Future<bool?> readBool`). The repository owns an in-memory cache
populated by `init()` and consumed synchronously by the router redirect.

### Use cases

- `IsOnboardingSplashSeenUseCase extends SyncUseCase<NoParams, bool>`
  — proxies `repository.isSplashSeen`. Used by the cubit / future code
  that needs to branch on first-launch.
- `MarkOnboardingSplashSeenUseCase extends AsyncUseCase<NoParams, void>`
  — proxies `repository.markSplashSeen()`. Called by the cubit when
  advancing.

Both follow the project's `Either<Exception, R>` convention via the base
class.

### Data layer

```dart
@LazySingleton(as: OnboardingFlagRepository)
class OnboardingFlagRepositoryImpl implements OnboardingFlagRepository {
  final OnboardingLocalSource _source;
  bool _splashSeen = false;
  bool _initialized = false;

  OnboardingFlagRepositoryImpl(this._source);

  @override
  bool get isSplashSeen => _splashSeen;

  @override
  Future<void> init() async {
    if (_initialized) return;
    _splashSeen = await _source.readSplashSeen();
    _initialized = true;
  }

  @override
  Future<void> markSplashSeen() async {
    if (_splashSeen) return;
    _splashSeen = true;
    await _source.writeSplashSeen();
  }
}
```

The repository deliberately does **not** broadcast changes. The flag is
consumed by the router redirect, but only at navigation time — and the
splash-to-welcome navigation is driven by the screen itself, not by the
redirect. Adding `ChangeNotifier` would cause GoRouter to recompute
during the cubit's `advance()` and bounce the user off the splash before
the fade-out finishes.

```dart
abstract class OnboardingLocalSource {
  Future<bool> readSplashSeen();
  Future<void> writeSplashSeen();
}

@Injectable(as: OnboardingLocalSource)
class OnboardingLocalSourceImpl implements OnboardingLocalSource {
  static const _key = 'onboarding_splash_seen';
  final LocalStorage _storage;

  OnboardingLocalSourceImpl(this._storage);

  @override
  Future<bool> readSplashSeen() async =>
      (await _storage.readBool(_key)) ?? false;

  @override
  Future<void> writeSplashSeen() => _storage.writeBool(_key, true);
}
```

### Cubit & state machine

```dart
@freezed
sealed class OnboardingSplashState with _$OnboardingSplashState {
  const factory OnboardingSplashState.initial() = _Initial;
  const factory OnboardingSplashState.visible() = _Visible;
  const factory OnboardingSplashState.advancing() = _Advancing;
}
```

```dart
@injectable
class OnboardingSplashCubit extends Cubit<OnboardingSplashState> {
  static const Duration autoAdvanceDelay = Duration(seconds: 2);

  final MarkOnboardingSplashSeenUseCase _markSeen;
  Timer? _autoAdvanceTimer;

  OnboardingSplashCubit(this._markSeen)
      : super(const OnboardingSplashState.initial());

  void start() {
    if (state is! _Initial) return;
    emit(const OnboardingSplashState.visible());
    _autoAdvanceTimer = Timer(autoAdvanceDelay, advance);
  }

  Future<void> advance() async {
    if (state is _Advancing) return;
    _autoAdvanceTimer?.cancel();
    emit(const OnboardingSplashState.advancing());
    await _markSeen(NoParams());
  }

  @override
  Future<void> close() {
    _autoAdvanceTimer?.cancel();
    return super.close();
  }
}
```

The cubit is animation-agnostic: it holds the timer and the persistence
call. The widget owns `AnimationController` (vsync) and listens to
state transitions to drive fade-in / fade-out. The widget also calls
`context.goNamed(onboardingWelcome)` once the fade-out completes.

### Screen composition

```
OnboardingSplashScreen (Stateful, owns AnimationController)
└── BlocListener<OnboardingSplashCubit, OnboardingSplashState>
    ├── on visible    → controller.forward()
    └── on advancing  → controller.reverse().whenComplete(goNamed(welcome))
└── Scaffold(extendBodyBehindAppBar: true)
    └── GestureDetector(onTap: cubit.advance)
        └── SplashBackground   // gradient container, full screen
            └── FadeTransition(opacity: controller)
                └── SplashContent
                    ├── _LogoPlaceholder  // SizedBox(180×56) + Text('Waily', s44w500)
                    ├── SizedBox(height: 14)
                    └── Text(welcomeMessage, s16w400 textSecondary, center)
```

`SplashBackground` paints the vertical gradient
`AppColors.surface → AppColors.background` (Figma `#1D2534 → #020815`,
which already match existing tokens exactly).

`SplashContent` mirrors the Figma `Container` (359×110, vertical
auto-layout, `counterAxis: CENTER`, `itemSpacing: 14`). Positioned in
the lower half of the screen via `Column(mainAxisAlignment: end)` with
`padding: EdgeInsets.symmetric(horizontal: 16)` to match the Figma
frame's 16-px horizontal inset and `MAX` primary axis.

### Routing

`app_routes.dart` adds:

```dart
static const String onboardingSplash = 'onboardingSplash';
static const String onboardingSplashPath = '/onboarding/splash';
static const String onboardingWelcome = 'onboardingWelcome';
static const String onboardingWelcomePath = '/onboarding/welcome';
```

`app_router.dart` changes:

```dart
GoRouter _buildAppRouter() {
  final authGate = getIt<AuthSessionGate>();
  final onboardingRepo = getIt<OnboardingFlagRepository>();

  return GoRouter(
    initialLocation: AppRoutes.onboardingSplashPath,
    refreshListenable: authGate,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final atOnboardingSplash = loc == AppRoutes.onboardingSplashPath;
      final atOnboardingWelcome = loc == AppRoutes.onboardingWelcomePath;
      final inOnboarding = atOnboardingSplash || atOnboardingWelcome;
      final atSignIn = loc == AppRoutes.signInPath;

      // First-launch gate: send unseen users to the splash unless already
      // somewhere inside the onboarding flow or the sign-in placeholder.
      if (!onboardingRepo.isSplashSeen && !inOnboarding && !atSignIn) {
        return AppRoutes.onboardingSplashPath;
      }
      // Once seen, the splash itself is no longer reachable; bounce
      // returning users (deep links, back-stack) to the next step.
      if (onboardingRepo.isSplashSeen && atOnboardingSplash) {
        return AppRoutes.onboardingWelcomePath;
      }

      // Existing auth gate (does not block onboarding routes — they live
      // before sign-in in the cold-start flow).
      if (!authGate.isAuthenticated && !atSignIn && !inOnboarding) {
        return AppRoutes.signInPath;
      }
      if (authGate.isAuthenticated && atSignIn) return AppRoutes.homePath;

      return null;
    },
    routes: [
      GoRoute(
        name: AppRoutes.onboardingSplash,
        path: AppRoutes.onboardingSplashPath,
        pageBuilder: (ctx, state) => CustomTransitionPage(
          child: BlocProvider(
            create: (_) => getIt<OnboardingSplashCubit>()..start(),
            child: const OnboardingSplashScreen(),
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        name: AppRoutes.onboardingWelcome,
        path: AppRoutes.onboardingWelcomePath,
        pageBuilder: (ctx, state) => CustomTransitionPage(
          child: const OnboardingWelcomePlaceholderScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        name: AppRoutes.signIn,
        path: AppRoutes.signInPath,
        builder: (context, state) => const SignInPlaceholderScreen(),
      ),
      StatefulShellRoute.indexedStack(
        // ... unchanged
      ),
    ],
  );
}
```

`main.dart` adds:

```dart
await getIt<AuthSessionGate>().refresh();
await getIt<OnboardingFlagRepository>().init();   // new
```

### Visual mapping (Figma → Flutter)

| Figma | Flutter |
|---|---|
| Frame 393×852, gradient `#1D2534 → #020815` | `LinearGradient(begin: topCenter, end: bottomCenter, colors: [surface, background])` |
| `padding: 16h`, `primaryAxis: MAX`, `counterAxis: CENTER` | `Padding(horizontal: 16) + Column(mainAxisAlignment: end, crossAxisAlignment: center)` |
| `Container` (Logo + Description, `itemSpacing: 14`) | `Column(crossAxisAlignment: center, children: [_LogoPlaceholder, SizedBox(height: 14), _Description])` with `mainAxisSize: min` |
| Logo INSTANCE 180×56 | `SizedBox(width: 180, height: 56, child: Center(child: Text('Waily', style: s44w500(white))))` |
| Description text Helvetica Neue 16/20 w400 -0.32 ls, color `#9EA3AE`, `textAlignHorizontal: CENTER` | `Text(welcomeMessage, style: context.appTextStyles.s16w400(color: context.appColors.textSecondary), textAlign: TextAlign.center)` |
| Status bar (`Home Indicator` instance) | Skipped — handled by `SafeArea` / system status bar overlay |
| Transition (entrance + exit) | `FadeTransition` via `CustomTransitionPage`, 400 ms |

### Welcome placeholder screen

`OnboardingWelcomePlaceholderScreen` mirrors `SignInPlaceholderScreen`:
`Scaffold` with the dark background and a centered text
`'Onboarding coming soon'`. Replaced by the real first onboarding step
in WAIL-17+.

## Testing

| Layer | File | Coverage |
|---|---|---|
| Data | `onboarding_flag_repository_impl_test.dart` | `init()` reads from source; subsequent `init()` is a no-op; `markSplashSeen` writes through and emits `notifyListeners` once; idempotent on second call |
| Domain | `mark_onboarding_splash_seen_use_case_test.dart` | Calls repo, returns `Right(void)` on success, `Left(Exception)` on throw |
| Domain | `is_onboarding_splash_seen_use_case_test.dart` | Returns `Right(true/false)` matching repo state |
| Bloc | `onboarding_splash_cubit_test.dart` | `start()` emits `visible`; `fakeAsync.elapse(2s)` triggers `advance` and emits `advancing`; manual `advance()` cancels timer and emits `advancing`; second `start()` is no-op; `close()` cancels timer; `markSeen` use case invoked exactly once |
| Widget | `onboarding_splash_screen_test.dart` | gradient background present; `Text('Waily')` placeholder rendered; description text rendered with `TextAlign.center` and `textSecondary` color; tap on root invokes `cubit.advance()`; widget pumps through fade animation; renders without overflow at 360×640 (small phone), 1024×1366 (tablet) |

Mocks generated via Mockito `@GenerateMocks` + `build_runner` per
project convention.

## AC mapping

| AC | How verified |
|---|---|
| 1. Logo + welcome per Figma | Widget test asserts placeholder + welcome text + theme colors. Final visual parity defers to the real Logo asset (see Risks). |
| 2. Auto-advance after 2.0 s or on tap | Bloc test (`fakeAsync` 2-s elapse) + widget tap test |
| 3. Smooth fade transitions | `CustomTransitionPage` covers entrance/exit; widget test asserts `FadeTransition` is present |
| 4. iOS + Android | Pure Flutter, no platform channels. Manual `flutter run` smoke check on both platforms before PR. |
| 5. Phones + tablets | Layout uses fractional alignment + horizontal padding only. Widget test renders at 360×640 and 1024×1366 with no overflow. |

## Risks & mitigations

1. **Logo placeholder ≠ Figma final.** AC1 partially open until the
   180×56 wordmark SVG is delivered. Mitigation: `// TODO(WAIL-X)`
   comment on `_LogoPlaceholder`; `/finish` notes this in Jira so a
   follow-up ticket can swap the asset.
2. **iOS workspace stash on `develop`.** A `git stash` (`WAIL-16-start:
   ios config leftovers`) was created when starting; needs to be
   restored back on `develop` after PR. Mitigation: `/finish` reminds
   the developer to `git stash list` / `apply`.
3. **Tablet layout is correct, not optimal.** With `Column(mainAxis:
   end)` the splash content sits at the bottom on iPad, leaving a large
   blank top area. AC5 only requires "displays correctly", not
   "designed for tablet". Mitigation: ship as-is; tablet polishing is
   out-of-scope.
4. **First launch happens during `init()`.** If `LocalStorage` read
   somehow fails, `_splashSeen` stays `false` and the user sees the
   splash. Acceptable degraded behaviour.

## Out of scope (recap)

- Real Logo SVG asset
- Subsequent onboarding screens (WAIL-17+)
- Localization
- Native pre-Flutter splash
- Tablet-optimised splash composition
- Auth feature implementation (still `StubAuthSessionGate`)
