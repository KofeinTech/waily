# State management

Waily uses `flutter_bloc` (Cubit), `injectable` + `get_it`, and a small set of base classes that every feature is expected to follow.

## Big picture

```
UI widget ─► Cubit ─► UseCase ─► Repository ─► Datasource (extends AppGateway)
   ▲                              (interface)   (Dio / SharedPreferences /
   │                                            flutter_secure_storage)
   └───── BlocBuilder / BlocListener
```

## Layers

- **Cubit** (`lib/features/<name>/presentation/bloc/`) — owns UI state. Calls use cases. Never touches repositories directly.
- **UseCase** (`lib/features/<name>/domain/use_cases/`) — encapsulates business logic. Extends `AsyncUseCase` or `SyncUseCase`. Returns `Either<Exception, R>`.
- **Repository** — interface in `domain/repositories/`, implementation in `data/repositories/`.
- **Datasource** (`lib/features/<name>/data/datasources/`) — extends `AppGateway`; wraps Dio / storage / DB calls in `safeCall<T>` or `voidSafeCall`.

## Notification flow

`AppNotificationCubit` listens to `NotificationManager.notificationStream`. The `AppNotificationBuilder` widget (mounted under `MaterialApp.builder`) renders a `SnackBar` per emission.

There are two ways to send a notification:

1. **Throw `NotificationException` from a use case.** `AsyncUseCase` / `SyncUseCase` catches it, forwards the payload to `NotificationManager.sendNotification`, and returns `Left(exception)`. Use this when an error in business logic should both be visible to the user and surface as a `Left` to the cubit.
2. **Call `NotificationManager.sendNotification(...)` directly.** Use this for purely informational notifications that do not represent a `Left`-returning failure (e.g. "Saved", "Copied to clipboard").

Use `isSilent: true` on a use case when the notification should be suppressed for that one call (e.g. background polling — the user does not need to see every retry).

## Persistence

Two thin storage interfaces live in `lib/features/core/domain/sources/`. Both are registered in DI as lazy singletons.

| Data | Storage |
| --- | --- |
| Auth tokens, refresh tokens, biometric secrets, anything sensitive | `SecureStorage` (flutter_secure_storage) |
| Theme mode, locale, onboarding flags, non-sensitive preferences | `LocalStorage` (SharedPreferences) |
| Future per-cubit auto-restoration | Consider `hydrated_bloc` |

### Hard rules

- Never store tokens in `LocalStorage` / SharedPreferences.
- Never log values read from `SecureStorage`.
- All storage methods are async — call them from use cases, not directly from cubits.
- On Android, `flutter_secure_storage` requires API 23+. The project's `minSdk` is 23.

### When to consider `hydrated_bloc`

`hydrated_bloc` makes a Cubit auto-persist its state and rehydrate on app start. Useful when:
- The cubit owns a small, JSON-serialisable state.
- The state should survive a process restart without an explicit "load" use case.

Avoid it when:
- The cubit owns sensitive data (it serialises through plaintext storage).
- The state requires a non-trivial migration story.

## Conventions

- Cubits never call repositories directly; always via use cases.
- Use cases return `Either<Exception, R>` (dartz).
- One use case per action. Params class lives in the same file.
- Cubits register with `@injectable` (new instance per scope) by default.
- App-shell cubits that wrap a global broadcast stream (e.g. `AppNotificationCubit`) are exceptions — register with `@lazySingleton` + `@disposeMethod` on `close()` so the singleton lifecycle is owned by `get_it`. Use `BlocProvider.value(value: getIt<...>())` at the app root.
- Repositories register with `@LazySingleton(as: <Interface>)`.
- Datasources register with `@Injectable(as: <Interface>)` and extend `AppGateway`.
- Mappers are Dart extensions on API models (`toEntity()`), invoked at the repository layer.

## Testing

- `mockito` with `@GenerateMocks` for collaborator mocks.
- One mocks file per feature (e.g. `test/features/<name>/mocks.dart`).
- Cubit tests use vanilla `mockito` + a controllable `StreamController` (NOT `bloc_test`; it pulls a `test_api` version incompatible with the Flutter SDK).
- For widget tests that interact with cubits driven by streams, create the cubit + controller INSIDE each `testWidgets` body (use `addTearDown`); creating them in `setUp` causes events not to flush via `tester.pump()` because of `FakeAsync` zone boundaries.
- Widget tests required for any screen wired to a cubit.

## Reference implementation

The complete reference flow ships in `lib/features/core/`:

- `domain/use_cases/async_use_case.dart` — `AsyncUseCase<P, R>` base
- `domain/use_cases/sync_use_case.dart` — `SyncUseCase<P, R>` base
- `domain/managers/notification_manager.dart` — abstract
- `data/managers/notification_manager_impl.dart` — broadcast `StreamController`
- `data/gateway/app_gateway.dart` — `safeCall<T>` / `voidSafeCall`
- `presentation/bloc/app_notification_cubit.dart` — example cubit consuming a stream
- `presentation/widgets/app_notification_builder.dart` — example widget consuming a cubit
- `presentation/screens/demo_home_screen.dart` — buttons that exercise both paths

Copy the patterns from these files when building new features. If you find yourself diverging, update this doc first.
