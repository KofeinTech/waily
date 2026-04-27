# WAIL-12 — State management setup

**Ticket:** [WAIL-12](https://improvs.atlassian.net/browse/WAIL-12) — Configure state management solution
**Branch:** `WAIL-12-state-management-setup`
**Status:** Design approved 2026-04-27

## 1. Summary

Wire up the state-management infrastructure that CLAUDE.md describes but the codebase does not yet implement. The library choice (`flutter_bloc` Cubit + `injectable` + `get_it`) is already fixed by project rules — the ticket text recommended Riverpod, but CLAUDE.md takes precedence. This ticket lands the runtime plumbing (DI, BlocObserver, AppGateway, AsyncUseCase/SyncUseCase, NotificationManager + AppNotificationCubit + AppNotificationBuilder), thin storage wrappers (SharedPreferences + flutter_secure_storage), a small demo screen that exercises the notification flow end-to-end, and the team-facing documentation.

After this ticket, follow-up feature tickets can write Cubits and use cases by copying patterns directly out of the codebase, not out of docs.

## 2. Acceptance criteria → deliverables

| AC | How it is satisfied |
|----|---------------------|
| Library is configured | DI initialised in `main.dart`; `Bloc.observer` set; `MultiBlocProvider` at app shell with `AppNotificationCubit` |
| Global app state structure is defined | `lib/features/core/` infrastructure + `MultiBlocProvider` slot ready for future app-scope cubits (auth, theme, locale) |
| Example state provider/notifier is created and demonstrated | `AppNotificationCubit` + `DemoHomeScreen` with two buttons (direct send + via use case) |
| Persistence strategy is documented | `docs/state-management.md` + `LocalStorage` / `SecureStorage` interfaces + concrete impls registered in DI |
| Team documentation created | `docs/state-management.md` (main); short pointer in `README.md`; brief "Persistence" addition in `CLAUDE.md` |

## 3. Folder structure

```
lib/
  main.dart                                # Bloc.observer + DI init + runApp(App())
  app.dart                                 # MultiBlocProvider + MaterialApp.router + AppNotificationBuilder
  core/
    di/
      injection.dart                       # @InjectableInit configureDependencies()
      injection.config.dart                # generated
      app_module.dart                      # @module: Talker, future third-party @factoryMethod registrations
    observers/
      app_bloc_observer.dart               # BlocObserver -> Talker
    router/
      app_router.dart                      # final GoRouter appRouter = GoRouter(...)
  features/
    core/
      domain/
        entities/
          app_notification.dart            # Freezed sealed: success/error/info/warning
          notification_exception.dart      # Exception with AppNotification payload
        managers/
          notification_manager.dart        # abstract
        use_cases/
          async_use_case.dart              # AsyncUseCase<P,R>
          sync_use_case.dart               # SyncUseCase<P,R>
          trigger_demo_error_use_case.dart # @lazySingleton AsyncUseCase<NoParams,void>
          no_params.dart                   # const NoParams()
        sources/
          local_storage.dart               # abstract
          secure_storage.dart              # abstract
      data/
        gateway/
          app_gateway.dart                 # safeCall<T> / voidSafeCall
        managers/
          notification_manager_impl.dart   # @Singleton(as: NotificationManager)
        sources/
          local_storage_impl.dart          # @LazySingleton(as: LocalStorage)
          secure_storage_impl.dart         # @LazySingleton(as: SecureStorage)
      presentation/
        bloc/
          app_notification_cubit.dart      # @injectable
          app_notification_state.dart      # Freezed
        widgets/
          app_notification_builder.dart    # SnackBar surface
        screens/
          demo_home_screen.dart            # 2 demo buttons (AC3)

test/
  features/core/
    data/gateway/app_gateway_test.dart
    data/managers/notification_manager_impl_test.dart
    domain/use_cases/async_use_case_test.dart
    presentation/bloc/app_notification_cubit_test.dart
    presentation/widgets/app_notification_builder_test.dart
    mocks.dart                             # @GenerateMocks([...])
  widget_test.dart                         # update: app boots after DI init
docs/
  state-management.md                      # main team doc (AC5)
README.md                                  # +State management section pointing at docs
CLAUDE.md                                  # +Persistence subsection
pubspec.yaml                               # +shared_preferences, +flutter_secure_storage, +bloc_test
```

## 4. Notification flow

```
use case (AsyncUseCase)
  throws NotificationException(notification)
        │
        ▼
  AsyncUseCase.call() catches it, calls
  notificationManager.sendNotification(notification),
  returns Left(NotificationException)
        │
        ▼ stream
  AppNotificationCubit (subscribed in ctor)
  emits AppNotificationState.received(notification)
        │
        ▼
  AppNotificationBuilder (BlocListener under MaterialApp.builder)
  renders SnackBar via ScaffoldMessenger
```

**Direct path:** code may call `notificationManager.sendNotification(...)` without throwing. Same stream → same UI.

### Contracts

`AppNotification` (Freezed sealed in `domain/entities`):

```dart
@freezed
sealed class AppNotification with _$AppNotification {
  const factory AppNotification.success({required String message, String? title}) = _Success;
  const factory AppNotification.error({required String message, String? title})   = _Error;
  const factory AppNotification.info({required String message, String? title})    = _Info;
  const factory AppNotification.warning({required String message, String? title}) = _Warning;
}
```

`NotificationException`:

```dart
class NotificationException implements Exception {
  final AppNotification notification;
  const NotificationException(this.notification);
}
```

`NotificationManager` (abstract):

```dart
abstract class NotificationManager {
  Stream<AppNotification> get notificationStream;
  void sendNotification(AppNotification notification);
  void dispose();
}
```

`NotificationManagerImpl` — `StreamController<AppNotification>.broadcast()` inside; `@disposeMethod` on `dispose`.

`AppNotificationCubit` — subscribes once in ctor, cancels in `close()`; emits `AppNotificationState.received(notification)` per event.

`AppNotificationBuilder` — `BlocListener<AppNotificationCubit, AppNotificationState>` mounted under `MaterialApp.builder`; on `received` calls `_showSnackBar(context, n)` which selects color/icon by `AppNotification` variant. Uses `Theme.of(context).colorScheme` until ThemeExtensions land in a future ticket.

## 5. Use case bases and AppGateway

`AsyncUseCase<P, R>` and `SyncUseCase<P, R>` are taken **verbatim** from CLAUDE.md (Use Cases section) — same try/catch, same Either return, same `isSilent` flag, same dependency on `Talker` + `NotificationManager`. The implementation lives once at `lib/features/core/domain/use_cases/`.

Concrete use cases extend the base, take `super.talker, super.notificationManager` in the constructor, and override `onExecute(P params)`.

`AppGateway` (`lib/features/core/data/gateway/app_gateway.dart`):

```dart
abstract class AppGateway {
  final Talker talker;
  AppGateway(this.talker);

  @protected
  Future<T> safeCall<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (e, st) {
      talker.handle(e, st);
      rethrow;
    } catch (e, st) {
      talker.handle(e, st);
      rethrow;
    }
  }

  @protected
  Future<void> voidSafeCall(Future<void> Function() operation) async {
    await safeCall<void>(operation);
  }
}
```

CLAUDE.md describes `AppGateway` as "provides error handling for calls" without prescribing a specific exception mapping. This ticket lands the minimal version: log every error through Talker, rethrow. Mapping `DioException` to a domain-specific exception (e.g., `NetworkException`, `AuthException`) belongs to the auth/networking ticket, where the API error envelope is known.

## 6. App shell, demo, main.dart

`lib/main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = AppBlocObserver(getIt<Talker>());
  runApp(const App());
}
```

`AppBlocObserver` overrides `onChange` (logs `bloc.runtimeType: prev -> next` via `talker.debug`) and `onError` (forwards to `talker.handle`).

`Talker` is registered via `@module` (since it is third-party):

```dart
@module
abstract class AppModule {
  @singleton
  Talker talker() => Talker();
}
```

`lib/app.dart`:

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppNotificationCubit>(
          create: (_) => getIt<AppNotificationCubit>(),
        ),
        // future app-scope cubits (auth, theme, locale) go here
      ],
      child: MaterialApp.router(
        title: 'Waily',
        builder: (context, child) =>
          AppNotificationBuilder(child: child ?? const SizedBox.shrink()),
        routerConfig: appRouter,
      ),
    );
  }
}
```

`AppNotificationBuilder` mounts inside `MaterialApp.builder` so `ScaffoldMessenger` is available on every route.

`lib/core/router/app_router.dart`:

```dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DemoHomeScreen(),
    ),
  ],
);
```

`DemoHomeScreen`:

```dart
class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waily — state mgmt demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => getIt<NotificationManager>()
                  .sendNotification(const AppNotification.success(message: 'Hello!')),
              child: const Text('Show notification (direct)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => getIt<TriggerDemoErrorUseCase>()(const NoParams()),
              child: const Text('Trigger error via use case'),
            ),
          ],
        ),
      ),
    );
  }
}
```

`TriggerDemoErrorUseCase` extends `AsyncUseCase<NoParams, void>` and throws `NotificationException(AppNotification.error(...))`. Base class catches → forwards to manager → cubit → snackbar. Same UX as the direct path, different code path.

## 7. Storage skeleton

```dart
abstract class LocalStorage {
  Future<String?> readString(String key);
  Future<void>    writeString(String key, String value);
  Future<bool?>   readBool(String key);
  Future<void>    writeBool(String key, bool value);
  Future<int?>    readInt(String key);
  Future<void>    writeInt(String key, int value);
  Future<void>    remove(String key);
  Future<void>    clear();
}
```

`LocalStorageImpl` — `@LazySingleton(as: LocalStorage)`, lazy `SharedPreferences.getInstance()` cached on first call.

```dart
abstract class SecureStorage {
  Future<String?> read(String key);
  Future<void>    write(String key, String value);
  Future<void>    delete(String key);
  Future<void>    deleteAll();
}
```

`SecureStorageImpl` — `@LazySingleton(as: SecureStorage)`, wraps `FlutterSecureStorage()` with default options. iOS uses Keychain, Android uses encrypted shared prefs (default).

No consumer of either interface ships in this ticket. Concrete features bind to them via constructor DI when they arrive.

## 8. Tests

Coverage matches the runtime delta: every new infrastructure unit gets a focused test.

| Test file | What it verifies |
|-----------|------------------|
| `notification_manager_impl_test.dart` | `sendNotification` → event arrives on `notificationStream`; `dispose` closes the controller |
| `app_gateway_test.dart` | `safeCall<T>` propagates success; logs `DioException` via Talker and rethrows; logs and rethrows other exceptions |
| `async_use_case_test.dart` | Success → `Right(result)`; `NotificationException` → `Left(...)` AND manager called once; plain `Exception` → `Left(...)` AND manager NOT called; `isSilent: true` suppresses the manager call on `NotificationException` |
| `app_notification_cubit_test.dart` | `bloc_test`: stream event → emits `received(notification)`; `close()` cancels subscription |
| `app_notification_builder_test.dart` | Widget test: cubit emits `received(success)` → green `SnackBar` is shown; `received(error)` → red `SnackBar` |
| `widget_test.dart` (update) | Smoke: `App` boots after `configureDependencies()`; `getIt.reset()` in `tearDown` |

Mocks live in `test/features/core/mocks.dart` with `@GenerateMocks([Talker, NotificationManager, ...])`. Generated `mocks.mocks.dart` is committed.

Out of test scope (covered by manual run / future tickets):
- `LocalStorageImpl`, `SecureStorageImpl` — platform-channel-backed; needs method-channel mocks. Add when first consumer lands.
- `AppBlocObserver` — trivial Talker delegation; verified by running the app and seeing logs.
- `TriggerDemoErrorUseCase` — its behaviour is covered by `async_use_case_test.dart` + by hand-running the demo screen.

## 9. pubspec changes

`dependencies:`

```yaml
shared_preferences: ^2.3.0
flutter_secure_storage: ^9.2.0
```

`dev_dependencies:`

```yaml
bloc_test: ^9.1.7
```

(All version ranges are starting points — the implementer pins to the latest stable that resolves against `sdk: ^3.10.7`.)

## 10. Documentation

`docs/state-management.md` — primary team-facing doc. Sections:

1. Stack one-liner.
2. Big picture diagram (UI → Cubit → UseCase → Repository → Datasource).
3. Layer responsibilities (matches CLAUDE.md, human-readable).
4. Notification flow with the decision rule "throw NotificationException vs call NotificationManager directly".
5. Persistence — decision matrix (auth tokens / refresh tokens → SecureStorage; theme, locale, prefs, onboarding flags → LocalStorage; future cubit auto-restoration → consider `hydrated_bloc`). Hard rule: never store tokens in LocalStorage; never log SecureStorage values.
6. Conventions list (Cubits never touch repos directly; use cases always return `Either<Exception, R>`; one use case per action; `@injectable` cubits).
7. Testing patterns (`bloc_test`, `@GenerateMocks`, widget tests for screens with cubits).
8. Pointer to `lib/features/core/` as the in-tree reference.

`CLAUDE.md` — append to existing `## State management` section:

```markdown
### Persistence

- LocalStorage (SharedPreferences-backed) for non-sensitive prefs.
- SecureStorage (flutter_secure_storage) for tokens and secrets.
- Never store tokens in LocalStorage. See docs/state-management.md.
```

`README.md` — add a `## State management` section with one paragraph and a link to `docs/state-management.md`.

## 11. Verification

| AC | Verification step |
|----|-------------------|
| Library is configured | `fvm flutter analyze` exits 0; `fvm flutter run` boots; `Bloc.observer` set in `main.dart` (`grep "Bloc.observer"`) |
| Global app state structure is defined | `MultiBlocProvider` present in `lib/app.dart`; `lib/features/core/` matches §3 |
| Example provider/notifier created and demoed | Both buttons on `DemoHomeScreen` produce a `SnackBar` when pressed (manual run on iOS sim or Android emu) |
| Persistence strategy documented | `docs/state-management.md` exists; `LocalStorage` / `SecureStorage` registered in `getIt` (`grep "@LazySingleton(as: LocalStorage)"`) |
| Team documentation created | `docs/state-management.md`, `README.md` section, `CLAUDE.md` Persistence subsection all present |

`fvm flutter analyze` and `fvm flutter test` are the gating commands; both must pass before `/improvs:finish`.

## 12. Out of scope

- Concrete API client (`ApiClient`, Retrofit interfaces). Lands with the first feature that needs it.
- DioException → domain-exception mapping. Lands with the first feature that needs it.
- ThemeExtension classes (`AppColors`, `AppTextStyles`, etc.). Theme ticket.
- Localisation (`.arb` files, `flutter gen-l10n`). Localisation ticket.
- `hydrated_bloc` integration. Documented as a future option, not used.
- AppGateway ↔ NotificationException mapping. Lands when AppGateway has a real consumer.
- Theming the `SnackBar` to match design tokens. Snackbar uses `Theme.of(context).colorScheme` until ThemeExtensions exist.
- Deep router structure (sub-routes, nested navigation, redirects). Single root route only.
- Unit tests for `LocalStorageImpl` / `SecureStorageImpl`.

## 13. Isolation and clarity

Each new unit is reviewable on its own:

- **DI module + injection.dart** — pure plumbing. Adding a class with the right annotation suffices.
- **AppBlocObserver** — depends only on Talker. No coupling to features.
- **AppGateway** — depends only on Talker; mock Talker to test.
- **NotificationManager** — pure stream wrapper. Zero domain knowledge.
- **AsyncUseCase / SyncUseCase** — depend on Talker + NotificationManager. Tested with a fake subclass.
- **AppNotificationCubit** — depends only on NotificationManager. Tested with a controller-backed mock.
- **AppNotificationBuilder** — depends only on the cubit. Pumped in widget tests with `BlocProvider.value`.
- **LocalStorage / SecureStorage** — independent abstractions; impls don't know about each other.
- **DemoHomeScreen** — depends on `getIt`. Removable in follow-up tickets without touching infrastructure.

Cross-unit contracts are exactly:
- Talker is shared (provided once via `@module`).
- NotificationManager stream feeds AppNotificationCubit.
- AsyncUseCase/SyncUseCase consume NotificationManager only on `NotificationException`.
- AppNotificationBuilder consumes AppNotificationCubit state only.

No hidden coupling. Future feature cubits bind to use cases, not to any of the above directly.

## 14. Open risks

- **`flutter_secure_storage` Android minSdk:** package requires API 23+. WAIL-9 set `minSdkVersion 21`. The implementer either bumps to 23 (preferred — Google Play minimum is already 23) or pins to a flutter_secure_storage version compatible with API 21. Decision deferred to implementation; flag in PR.
- **`SharedPreferences` test isolation:** the `widget_test.dart` smoke test must not leak state between runs. Use `SharedPreferences.setMockInitialValues({})` and `getIt.reset()` in `setUp`/`tearDown`.
- **`bloc_test` pin:** must resolve against the installed `bloc` major. If `flutter_bloc: ^9` ships `bloc: ^9`, then `bloc_test: ^9` is the right choice; verify on `pub get`.
- **Talker as @singleton:** if a future logging ticket wants per-feature scoped talkers, this becomes a refactor. Acceptable risk — single shared Talker is the standard pattern.
