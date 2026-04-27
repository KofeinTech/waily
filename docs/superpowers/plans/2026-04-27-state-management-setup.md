# WAIL-12 State Management Setup — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land the runtime infrastructure for `flutter_bloc`-based state management (DI, BlocObserver, AppGateway, use-case bases, NotificationManager + AppNotificationCubit + AppNotificationBuilder), thin storage wrappers, a working demo screen, and team documentation.

**Architecture:** All cross-feature plumbing lives under `lib/features/core/` (per CLAUDE.md). DI is `injectable` + `get_it`. Notifications flow as `use case → NotificationException → AsyncUseCase base → NotificationManager.sendNotification → AppNotificationCubit → AppNotificationBuilder → SnackBar`. Persistence is two thin storage interfaces with concrete impls; no consumers ship in this ticket.

**Tech Stack:** Flutter (FVM 3.38.6), `flutter_bloc`, `injectable` + `get_it`, `freezed`, `dartz`, `talker`, `go_router`, `shared_preferences`, `flutter_secure_storage`, `mockito`. (Note: `bloc_test` is intentionally NOT used — its current major pulls a `test` version incompatible with the Flutter SDK's pinned `test_api`. Cubit and widget tests use vanilla `mockito` + manual `StreamController` control instead.)

**Spec:** `docs/superpowers/specs/2026-04-27-state-management-setup-design.md`

**Conventions used in every task:**
- All shell commands assume CWD = repo root.
- All Flutter commands use `fvm flutter ...`.
- After every code change to a `freezed` / `injectable` / `mockito` annotated file: `fvm flutter pub run build_runner build --delete-conflicting-outputs`.
- After every file edit, run `dart format <file>` (the repo hook does this automatically — confirm with `git diff --check`).
- `flutter analyze` must exit 0 before each commit.
- Do not commit generated `.g.dart` / `.freezed.dart` / `.config.dart` / `.mocks.dart` files only — commit them with the source file that produced them.

---

## Task 1: Add dependencies and bump Android minSdk

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle.kts`

- [ ] **Step 1: Add runtime deps to `pubspec.yaml`**

In the `dependencies:` block, after `talker:`, add:

```yaml
  shared_preferences: ^2.3.2
  flutter_secure_storage: ^9.2.2
```

- [ ] **Step 2: Resolve dependencies**

Run: `fvm flutter pub get`
Expected: exits 0, no version conflicts.

- [ ] **Step 3: Bump Android `minSdk` to 23**

Open `android/app/build.gradle.kts`. Inside `android { defaultConfig { ... } }`, replace:

```kotlin
        minSdk = flutter.minSdkVersion
```

with:

```kotlin
        minSdk = 23
```

(Reason: `flutter_secure_storage` requires Android API 23+. Google Play minimum is already 23, so this is safe.)

- [ ] **Step 4: Verify analyze still clean**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock android/app/build.gradle.kts
git commit -m "chore(wail-12): add shared_preferences, flutter_secure_storage; bump Android minSdk to 23"
```

---

## Task 2: DI scaffolding (injection.dart + app_module.dart)

**Files:**
- Create: `lib/core/di/injection.dart`
- Create: `lib/core/di/app_module.dart`
- Generated: `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create `app_module.dart`**

`lib/core/di/app_module.dart`:

```dart
import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';

@module
abstract class AppModule {
  @singleton
  Talker get talker => Talker();
}
```

- [ ] **Step 2: Create `injection.dart`**

`lib/core/di/injection.dart`:

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

- [ ] **Step 3: Run codegen**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: exits 0, creates `lib/core/di/injection.config.dart` registering `Talker` as a singleton.

- [ ] **Step 4: Sanity-check the generated file**

Run: `grep "Talker" lib/core/di/injection.config.dart`
Expected: at least one match, showing `Talker` is registered through `AppModule`.

- [ ] **Step 5: Verify analyze**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/core/di/
git commit -m "feat(wail-12): wire injectable + get_it scaffolding with Talker module"
```

---

## Task 3: AppBlocObserver

**Files:**
- Create: `lib/core/observers/app_bloc_observer.dart`
- Test: none (tiny delegation; covered by hand via `flutter run`)

- [ ] **Step 1: Create the observer**

`lib/core/observers/app_bloc_observer.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this._talker);

  final Talker _talker;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _talker.debug(
      '${bloc.runtimeType}: ${change.currentState} -> ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _talker.handle(error, stackTrace, '${bloc.runtimeType} error');
    super.onError(bloc, error, stackTrace);
  }
}
```

- [ ] **Step 2: Verify analyze**

Run: `fvm flutter analyze lib/core/observers/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/observers/
git commit -m "feat(wail-12): add AppBlocObserver wired to Talker"
```

---

## Task 4: `AppNotification` entity (Freezed)

**Files:**
- Create: `lib/features/core/domain/entities/app_notification.dart`
- Test: `test/features/core/domain/entities/app_notification_test.dart`
- Generated: `lib/features/core/domain/entities/app_notification.freezed.dart`

- [ ] **Step 1: Create the entity**

`lib/features/core/domain/entities/app_notification.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

@freezed
sealed class AppNotification with _$AppNotification {
  const factory AppNotification.success({required String message, String? title}) = AppNotificationSuccess;
  const factory AppNotification.error({required String message, String? title}) = AppNotificationError;
  const factory AppNotification.info({required String message, String? title}) = AppNotificationInfo;
  const factory AppNotification.warning({required String message, String? title}) = AppNotificationWarning;
}
```

- [ ] **Step 2: Run codegen**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: creates `app_notification.freezed.dart`.

- [ ] **Step 3: Write the test**

`test/features/core/domain/entities/app_notification_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';

void main() {
  group('AppNotification', () {
    test('success variant carries message and optional title', () {
      const n = AppNotification.success(message: 'ok', title: 'Saved');
      expect(n, isA<AppNotificationSuccess>());
      n.maybeWhen(success: (m, t) {
        expect(m, 'ok');
        expect(t, 'Saved');
      }, orElse: () => fail('expected success'));
    });

    test('error variant carries only message when title omitted', () {
      const n = AppNotification.error(message: 'boom');
      expect(n, isA<AppNotificationError>());
      n.maybeWhen(error: (m, t) {
        expect(m, 'boom');
        expect(t, isNull);
      }, orElse: () => fail('expected error'));
    });

    test('two equal success notifications are equal', () {
      const a = AppNotification.success(message: 'x');
      const b = AppNotification.success(message: 'x');
      expect(a, equals(b));
    });
  });
}
```

- [ ] **Step 4: Run the test**

Run: `fvm flutter test test/features/core/domain/entities/app_notification_test.dart`
Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/core/domain/entities/app_notification.dart \
        lib/features/core/domain/entities/app_notification.freezed.dart \
        test/features/core/domain/entities/app_notification_test.dart
git commit -m "feat(wail-12): add AppNotification freezed entity"
```

---

## Task 5: `NotificationException`

**Files:**
- Create: `lib/features/core/domain/entities/notification_exception.dart`
- Test: `test/features/core/domain/entities/notification_exception_test.dart`

- [ ] **Step 1: Write the failing test**

`test/features/core/domain/entities/notification_exception_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/domain/entities/notification_exception.dart';

void main() {
  test('NotificationException carries the AppNotification payload', () {
    const notification = AppNotification.error(message: 'boom');
    const exception = NotificationException(notification);

    expect(exception, isA<Exception>());
    expect(exception.notification, equals(notification));
  });
}
```

- [ ] **Step 2: Run the test (expect FAIL — file does not exist)**

Run: `fvm flutter test test/features/core/domain/entities/notification_exception_test.dart`
Expected: FAIL with import error referencing `notification_exception.dart`.

- [ ] **Step 3: Create the class**

`lib/features/core/domain/entities/notification_exception.dart`:

```dart
import 'app_notification.dart';

class NotificationException implements Exception {
  const NotificationException(this.notification);

  final AppNotification notification;
}
```

- [ ] **Step 4: Run the test (expect PASS)**

Run: `fvm flutter test test/features/core/domain/entities/notification_exception_test.dart`
Expected: 1 test passes.

- [ ] **Step 5: Commit**

```bash
git add lib/features/core/domain/entities/notification_exception.dart \
        test/features/core/domain/entities/notification_exception_test.dart
git commit -m "feat(wail-12): add NotificationException carrying AppNotification"
```

---

## Task 6: `NotificationManager` + `NotificationManagerImpl`

**Files:**
- Create: `lib/features/core/domain/managers/notification_manager.dart`
- Create: `lib/features/core/data/managers/notification_manager_impl.dart`
- Test: `test/features/core/data/managers/notification_manager_impl_test.dart`

- [ ] **Step 1: Create the abstract interface**

`lib/features/core/domain/managers/notification_manager.dart`:

```dart
import '../entities/app_notification.dart';

abstract class NotificationManager {
  Stream<AppNotification> get notificationStream;
  void sendNotification(AppNotification notification);
  void dispose();
}
```

- [ ] **Step 2: Write the failing test**

`test/features/core/data/managers/notification_manager_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/core/data/managers/notification_manager_impl.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';

void main() {
  group('NotificationManagerImpl', () {
    test('sendNotification emits the notification on the stream', () async {
      final manager = NotificationManagerImpl();
      const notification = AppNotification.success(message: 'hi');

      final future = expectLater(
        manager.notificationStream,
        emits(notification),
      );

      manager.sendNotification(notification);

      await future;
      manager.dispose();
    });

    test('multiple subscribers receive the same event (broadcast)', () async {
      final manager = NotificationManagerImpl();
      const notification = AppNotification.error(message: 'boom');

      final a = expectLater(manager.notificationStream, emits(notification));
      final b = expectLater(manager.notificationStream, emits(notification));

      manager.sendNotification(notification);

      await Future.wait([a, b]);
      manager.dispose();
    });
  });
}
```

- [ ] **Step 3: Run the test (expect FAIL — impl not created)**

Run: `fvm flutter test test/features/core/data/managers/notification_manager_impl_test.dart`
Expected: FAIL with import error.

- [ ] **Step 4: Create the impl**

`lib/features/core/data/managers/notification_manager_impl.dart`:

```dart
import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/managers/notification_manager.dart';

@Singleton(as: NotificationManager)
class NotificationManagerImpl implements NotificationManager {
  NotificationManagerImpl();

  final StreamController<AppNotification> _controller =
      StreamController<AppNotification>.broadcast();

  @override
  Stream<AppNotification> get notificationStream => _controller.stream;

  @override
  void sendNotification(AppNotification notification) {
    _controller.add(notification);
  }

  @override
  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
```

- [ ] **Step 5: Run codegen and tests**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs && fvm flutter test test/features/core/data/managers/notification_manager_impl_test.dart`
Expected: codegen exits 0; 2 tests pass; `injection.config.dart` now references `NotificationManagerImpl`.

- [ ] **Step 6: Commit**

```bash
git add lib/features/core/domain/managers/ \
        lib/features/core/data/managers/ \
        lib/core/di/injection.config.dart \
        test/features/core/data/managers/
git commit -m "feat(wail-12): add NotificationManager and broadcast impl"
```

---

## Task 7: `AppGateway` base

**Files:**
- Create: `lib/features/core/data/gateway/app_gateway.dart`
- Test: `test/features/core/data/gateway/app_gateway_test.dart`
- Test mocks: `test/features/core/mocks.dart` (new file)
- Generated: `test/features/core/mocks.mocks.dart`

- [ ] **Step 1: Create the mocks generation file**

`test/features/core/mocks.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:talker/talker.dart';
import 'package:waily/features/core/domain/managers/notification_manager.dart';

@GenerateMocks([Talker, NotificationManager, Dio])
void main() {}
```

- [ ] **Step 2: Run codegen**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: creates `test/features/core/mocks.mocks.dart`.

- [ ] **Step 3: Write the failing test**

`test/features/core/data/gateway/app_gateway_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/data/gateway/app_gateway.dart';

import '../../mocks.mocks.dart';

class _Gateway extends AppGateway {
  _Gateway(super.talker);

  Future<int> doIt(Future<int> Function() op) => safeCall<int>(op);
  Future<void> doVoid(Future<void> Function() op) => voidSafeCall(op);
}

void main() {
  late MockTalker talker;
  late _Gateway gateway;

  setUp(() {
    talker = MockTalker();
    gateway = _Gateway(talker);
  });

  test('safeCall returns the operation result on success', () async {
    final result = await gateway.doIt(() async => 42);
    expect(result, 42);
    verifyNever(talker.handle(any, any, any));
  });

  test('safeCall logs DioException via Talker and rethrows', () async {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/x'),
      message: 'boom',
    );

    await expectLater(
      gateway.doIt(() async => throw dioError),
      throwsA(isA<DioException>()),
    );
    verify(talker.handle(dioError, any, any)).called(1);
  });

  test('safeCall logs other Exception via Talker and rethrows', () async {
    final exception = Exception('plain');

    await expectLater(
      gateway.doIt(() async => throw exception),
      throwsA(isA<Exception>()),
    );
    verify(talker.handle(exception, any, any)).called(1);
  });

  test('voidSafeCall completes when operation completes', () async {
    var ran = false;
    await gateway.doVoid(() async {
      ran = true;
    });
    expect(ran, isTrue);
  });
}
```

- [ ] **Step 4: Run the test (expect FAIL — class missing)**

Run: `fvm flutter test test/features/core/data/gateway/app_gateway_test.dart`
Expected: FAIL with import error.

- [ ] **Step 5: Create `AppGateway`**

`lib/features/core/data/gateway/app_gateway.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

abstract class AppGateway {
  AppGateway(this._talker);

  final Talker _talker;

  @protected
  Future<T> safeCall<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (e, st) {
      _talker.handle(e, st, 'AppGateway DioException');
      rethrow;
    } catch (e, st) {
      _talker.handle(e, st, 'AppGateway error');
      rethrow;
    }
  }

  @protected
  Future<void> voidSafeCall(Future<void> Function() operation) async {
    await safeCall<void>(operation);
  }
}
```

- [ ] **Step 6: Run the test (expect PASS)**

Run: `fvm flutter test test/features/core/data/gateway/app_gateway_test.dart`
Expected: 4 tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/features/core/data/gateway/ \
        test/features/core/mocks.dart \
        test/features/core/mocks.mocks.dart \
        test/features/core/data/gateway/
git commit -m "feat(wail-12): add AppGateway base with safeCall/voidSafeCall and Talker logging"
```

---

## Task 8: `AsyncUseCase` and `SyncUseCase` bases

**Files:**
- Create: `lib/features/core/domain/use_cases/async_use_case.dart`
- Create: `lib/features/core/domain/use_cases/sync_use_case.dart`
- Test: `test/features/core/domain/use_cases/async_use_case_test.dart`
- Test: `test/features/core/domain/use_cases/sync_use_case_test.dart`

- [ ] **Step 1: Write the failing async test**

`test/features/core/domain/use_cases/async_use_case_test.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/domain/entities/notification_exception.dart';
import 'package:waily/features/core/domain/use_cases/async_use_case.dart';

import '../../mocks.mocks.dart';

class _SuccessUseCase extends AsyncUseCase<int, int> {
  _SuccessUseCase(super.talker, super.notificationManager);

  @override
  Future<int> onExecute(int params) async => params * 2;
}

class _NotificationFailingUseCase extends AsyncUseCase<void, void> {
  _NotificationFailingUseCase(
    super.talker,
    super.notificationManager, {
    super.isSilent = false,
  });

  @override
  Future<void> onExecute(void params) async {
    throw const NotificationException(AppNotification.error(message: 'boom'));
  }
}

class _PlainFailingUseCase extends AsyncUseCase<void, void> {
  _PlainFailingUseCase(super.talker, super.notificationManager);

  @override
  Future<void> onExecute(void params) async {
    throw Exception('plain');
  }
}

void main() {
  late MockTalker talker;
  late MockNotificationManager manager;

  setUp(() {
    talker = MockTalker();
    manager = MockNotificationManager();
  });

  test('success path returns Right(value)', () async {
    final uc = _SuccessUseCase(talker, manager);
    final result = await uc.call(21);
    expect(result, equals(const Right<Exception, int>(42)));
    verifyNever(manager.sendNotification(any));
  });

  test('NotificationException returns Left and forwards to manager', () async {
    final uc = _NotificationFailingUseCase(talker, manager);
    final result = await uc.call(null);

    expect(result.isLeft(), isTrue);
    verify(manager.sendNotification(
      const AppNotification.error(message: 'boom'),
    )).called(1);
    verify(talker.handle(any, any, any)).called(1);
  });

  test('isSilent suppresses NotificationManager call', () async {
    final uc = _NotificationFailingUseCase(talker, manager, isSilent: true);
    final result = await uc.call(null);

    expect(result.isLeft(), isTrue);
    verifyNever(manager.sendNotification(any));
  });

  test('plain Exception returns Left and is NOT forwarded to manager', () async {
    final uc = _PlainFailingUseCase(talker, manager);
    final result = await uc.call(null);

    expect(result.isLeft(), isTrue);
    verifyNever(manager.sendNotification(any));
    verify(talker.handle(any, any, any)).called(1);
  });
}
```

- [ ] **Step 2: Run the test (expect FAIL)**

Run: `fvm flutter test test/features/core/domain/use_cases/async_use_case_test.dart`
Expected: FAIL with import error on `async_use_case.dart`.

- [ ] **Step 3: Create `AsyncUseCase`**

`lib/features/core/domain/use_cases/async_use_case.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

import '../entities/notification_exception.dart';
import '../managers/notification_manager.dart';

abstract class AsyncUseCase<P, R> {
  AsyncUseCase(this.talker, this.notificationManager, {this.isSilent = false});

  final Talker talker;
  final NotificationManager notificationManager;
  final bool isSilent;

  @protected
  Future<R> onExecute(P params);

  Future<Either<Exception, R>> call(P params) async {
    try {
      final result = await onExecute(params);
      return Right(result);
    } catch (error, stackTrace) {
      talker.handle(
        error,
        stackTrace,
        'Unhandled Exception in $runtimeType with params: $params',
      );

      if (error is NotificationException && !isSilent) {
        notificationManager.sendNotification(error.notification);
        return Left(error);
      } else if (error is Exception) {
        return Left(error);
      }
      return Left(Exception(error.toString()));
    }
  }
}
```

- [ ] **Step 4: Run the async test (expect PASS)**

Run: `fvm flutter test test/features/core/domain/use_cases/async_use_case_test.dart`
Expected: 4 tests pass.

- [ ] **Step 5: Write the failing sync test**

`test/features/core/domain/use_cases/sync_use_case_test.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/domain/entities/notification_exception.dart';
import 'package:waily/features/core/domain/use_cases/sync_use_case.dart';

import '../../mocks.mocks.dart';

class _SyncSuccess extends SyncUseCase<int, int> {
  _SyncSuccess(super.talker, super.notificationManager);

  @override
  int onExecute(int params) => params + 1;
}

class _SyncNotificationFailing extends SyncUseCase<void, void> {
  _SyncNotificationFailing(super.talker, super.notificationManager);

  @override
  void onExecute(void params) {
    throw const NotificationException(AppNotification.warning(message: 'warn'));
  }
}

void main() {
  late MockTalker talker;
  late MockNotificationManager manager;

  setUp(() {
    talker = MockTalker();
    manager = MockNotificationManager();
  });

  test('success path returns Right(value)', () {
    final result = _SyncSuccess(talker, manager).call(1);
    expect(result, equals(const Right<Exception, int>(2)));
  });

  test('NotificationException forwards to manager and returns Left', () {
    final result = _SyncNotificationFailing(talker, manager).call(null);
    expect(result.isLeft(), isTrue);
    verify(manager.sendNotification(
      const AppNotification.warning(message: 'warn'),
    )).called(1);
  });
}
```

- [ ] **Step 6: Run the sync test (expect FAIL)**

Run: `fvm flutter test test/features/core/domain/use_cases/sync_use_case_test.dart`
Expected: FAIL with import error on `sync_use_case.dart`.

- [ ] **Step 7: Create `SyncUseCase`**

`lib/features/core/domain/use_cases/sync_use_case.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

import '../entities/notification_exception.dart';
import '../managers/notification_manager.dart';

abstract class SyncUseCase<P, R> {
  SyncUseCase(this.talker, this.notificationManager, {this.isSilent = false});

  final Talker talker;
  final NotificationManager notificationManager;
  final bool isSilent;

  @protected
  R onExecute(P params);

  Either<Exception, R> call(P params) {
    try {
      final result = onExecute(params);
      return Right(result);
    } catch (error, stackTrace) {
      talker.handle(
        error,
        stackTrace,
        'Unhandled Exception in $runtimeType with params: $params',
      );

      if (error is NotificationException && !isSilent) {
        notificationManager.sendNotification(error.notification);
        return Left(error);
      } else if (error is Exception) {
        return Left(error);
      }
      return Left(Exception(error.toString()));
    }
  }
}
```

- [ ] **Step 8: Run sync test (expect PASS)**

Run: `fvm flutter test test/features/core/domain/use_cases/sync_use_case_test.dart`
Expected: 2 tests pass.

- [ ] **Step 9: Commit**

```bash
git add lib/features/core/domain/use_cases/ test/features/core/domain/use_cases/
git commit -m "feat(wail-12): add AsyncUseCase and SyncUseCase base classes"
```

---

## Task 9: `NoParams` + `TriggerDemoErrorUseCase`

**Files:**
- Create: `lib/features/core/domain/use_cases/no_params.dart`
- Create: `lib/features/core/domain/use_cases/trigger_demo_error_use_case.dart`

- [ ] **Step 1: Create `NoParams`**

`lib/features/core/domain/use_cases/no_params.dart`:

```dart
class NoParams {
  const NoParams();
}
```

- [ ] **Step 2: Create the demo use case**

`lib/features/core/domain/use_cases/trigger_demo_error_use_case.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../entities/app_notification.dart';
import '../entities/notification_exception.dart';
import 'async_use_case.dart';
import 'no_params.dart';

@lazySingleton
class TriggerDemoErrorUseCase extends AsyncUseCase<NoParams, void> {
  TriggerDemoErrorUseCase(super.talker, super.notificationManager);

  @override
  Future<void> onExecute(NoParams params) async {
    throw const NotificationException(
      AppNotification.error(
        title: 'Demo error',
        message: 'This was thrown from a use case',
      ),
    );
  }
}
```

- [ ] **Step 3: Run codegen**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `injection.config.dart` now contains `TriggerDemoErrorUseCase` registration.

- [ ] **Step 4: Verify analyze + run all tests so far**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues, all current tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/core/domain/use_cases/no_params.dart \
        lib/features/core/domain/use_cases/trigger_demo_error_use_case.dart \
        lib/core/di/injection.config.dart
git commit -m "feat(wail-12): add NoParams and TriggerDemoErrorUseCase for demo flow"
```

---

## Task 10: `LocalStorage` + `LocalStorageImpl`

**Files:**
- Create: `lib/features/core/domain/sources/local_storage.dart`
- Create: `lib/features/core/data/sources/local_storage_impl.dart`

- [ ] **Step 1: Create the abstract interface**

`lib/features/core/domain/sources/local_storage.dart`:

```dart
abstract class LocalStorage {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);

  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, bool value);

  Future<int?> readInt(String key);
  Future<void> writeInt(String key, int value);

  Future<void> remove(String key);
  Future<void> clear();
}
```

- [ ] **Step 2: Create the impl**

`lib/features/core/data/sources/local_storage_impl.dart`:

```dart
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/sources/local_storage.dart';

@LazySingleton(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl();

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensure() async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<String?> readString(String key) async => (await _ensure()).getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    final prefs = await _ensure();
    await prefs.setString(key, value);
  }

  @override
  Future<bool?> readBool(String key) async => (await _ensure()).getBool(key);

  @override
  Future<void> writeBool(String key, bool value) async {
    final prefs = await _ensure();
    await prefs.setBool(key, value);
  }

  @override
  Future<int?> readInt(String key) async => (await _ensure()).getInt(key);

  @override
  Future<void> writeInt(String key, int value) async {
    final prefs = await _ensure();
    await prefs.setInt(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _ensure();
    await prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    final prefs = await _ensure();
    await prefs.clear();
  }
}
```

- [ ] **Step 3: Run codegen**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `injection.config.dart` registers `LocalStorageImpl as LocalStorage`.

- [ ] **Step 4: Verify analyze**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/core/domain/sources/local_storage.dart \
        lib/features/core/data/sources/local_storage_impl.dart \
        lib/core/di/injection.config.dart
git commit -m "feat(wail-12): add LocalStorage interface and SharedPreferences impl"
```

---

## Task 11: `SecureStorage` + `SecureStorageImpl`

**Files:**
- Create: `lib/features/core/domain/sources/secure_storage.dart`
- Create: `lib/features/core/data/sources/secure_storage_impl.dart`

- [ ] **Step 1: Create the abstract interface**

`lib/features/core/domain/sources/secure_storage.dart`:

```dart
abstract class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}
```

- [ ] **Step 2: Create the impl**

`lib/features/core/data/sources/secure_storage_impl.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../domain/sources/secure_storage.dart';

@LazySingleton(as: SecureStorage)
class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
```

- [ ] **Step 3: Run codegen**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `injection.config.dart` registers `SecureStorageImpl as SecureStorage`.

- [ ] **Step 4: Verify analyze**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/core/domain/sources/secure_storage.dart \
        lib/features/core/data/sources/secure_storage_impl.dart \
        lib/core/di/injection.config.dart
git commit -m "feat(wail-12): add SecureStorage interface and flutter_secure_storage impl"
```

---

## Task 12: `AppNotificationCubit` + state

**Files:**
- Create: `lib/features/core/presentation/bloc/app_notification_state.dart`
- Create: `lib/features/core/presentation/bloc/app_notification_cubit.dart`
- Test: `test/features/core/presentation/bloc/app_notification_cubit_test.dart`
- Generated: `app_notification_state.freezed.dart`

- [ ] **Step 1: Create the state**

`lib/features/core/presentation/bloc/app_notification_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/app_notification.dart';

part 'app_notification_state.freezed.dart';

@freezed
sealed class AppNotificationState with _$AppNotificationState {
  const factory AppNotificationState.initial() = AppNotificationInitial;
  const factory AppNotificationState.received(AppNotification notification) =
      AppNotificationReceived;
}
```

- [ ] **Step 2: Run codegen**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: creates `app_notification_state.freezed.dart`.

- [ ] **Step 3: Write the failing cubit test**

`test/features/core/presentation/bloc/app_notification_cubit_test.dart`:

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_cubit.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_state.dart';

import '../../mocks.mocks.dart';

void main() {
  group('AppNotificationCubit', () {
    late MockNotificationManager manager;
    late StreamController<AppNotification> controller;

    setUp(() {
      manager = MockNotificationManager();
      controller = StreamController<AppNotification>.broadcast();
      when(manager.notificationStream).thenAnswer((_) => controller.stream);
    });

    tearDown(() async {
      await controller.close();
    });

    test('starts in initial state', () {
      final cubit = AppNotificationCubit(manager);
      expect(cubit.state, const AppNotificationState.initial());
      cubit.close();
    });

    test('emits received() when manager pushes a notification', () async {
      final cubit = AppNotificationCubit(manager);
      final emitted = <AppNotificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      controller.add(const AppNotification.success(message: 'hi'));
      // Let the stream tick.
      await Future<void>.delayed(Duration.zero);

      expect(emitted, const [
        AppNotificationState.received(
          AppNotification.success(message: 'hi'),
        ),
      ]);

      await sub.cancel();
      await cubit.close();
    });
  });
}
```

- [ ] **Step 4: Run the test (expect FAIL — cubit not created)**

Run: `fvm flutter test test/features/core/presentation/bloc/app_notification_cubit_test.dart`
Expected: FAIL with import error on `app_notification_cubit.dart`.

- [ ] **Step 5: Create the cubit**

`lib/features/core/presentation/bloc/app_notification_cubit.dart`:

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/managers/notification_manager.dart';
import 'app_notification_state.dart';

@injectable
class AppNotificationCubit extends Cubit<AppNotificationState> {
  AppNotificationCubit(this._manager)
      : super(const AppNotificationState.initial()) {
    _subscription = _manager.notificationStream.listen(
      (notification) => emit(AppNotificationState.received(notification)),
    );
  }

  final NotificationManager _manager;
  late final StreamSubscription<AppNotification> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
```

- [ ] **Step 6: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs && fvm flutter test test/features/core/presentation/bloc/app_notification_cubit_test.dart`
Expected: codegen exits 0; 2 tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/features/core/presentation/bloc/ \
        lib/core/di/injection.config.dart \
        test/features/core/presentation/bloc/
git commit -m "feat(wail-12): add AppNotificationCubit + state listening to NotificationManager"
```

---

## Task 13: `AppNotificationBuilder` widget

**Files:**
- Create: `lib/features/core/presentation/widgets/app_notification_builder.dart`
- Test: `test/features/core/presentation/widgets/app_notification_builder_test.dart`

The test uses a real `AppNotificationCubit` driven by a controllable `MockNotificationManager` — no need to add `AppNotificationCubit` to the mocks list (that mocking was only needed because of `bloc_test`'s `whenListen`, which we are not using).

- [ ] **Step 1: Write the failing widget test**

`test/features/core/presentation/widgets/app_notification_builder_test.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_cubit.dart';
import 'package:waily/features/core/presentation/widgets/app_notification_builder.dart';

import '../../mocks.mocks.dart';

void main() {
  group('AppNotificationBuilder', () {
    late MockNotificationManager manager;
    late StreamController<AppNotification> controller;
    late AppNotificationCubit cubit;

    setUp(() {
      manager = MockNotificationManager();
      controller = StreamController<AppNotification>.broadcast();
      when(manager.notificationStream).thenAnswer((_) => controller.stream);
      cubit = AppNotificationCubit(manager);
    });

    tearDown(() async {
      await cubit.close();
      await controller.close();
    });

    Widget wrap() => MaterialApp(
          home: BlocProvider<AppNotificationCubit>.value(
            value: cubit,
            child: const AppNotificationBuilder(
              child: Scaffold(body: Text('home')),
            ),
          ),
        );

    testWidgets('renders SnackBar with success message on received(success)',
        (tester) async {
      await tester.pumpWidget(wrap());

      controller.add(const AppNotification.success(message: 'ok'));
      await tester.pump(); // process the stream event
      await tester.pump(); // let the SnackBar animate in

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('ok'), findsOneWidget);
    });

    testWidgets('renders SnackBar with error message on received(error)',
        (tester) async {
      await tester.pumpWidget(wrap());

      controller.add(const AppNotification.error(message: 'boom'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('boom'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test (expect FAIL — widget missing)**

Run: `fvm flutter test test/features/core/presentation/widgets/app_notification_builder_test.dart`
Expected: FAIL with import error on `app_notification_builder.dart`.

- [ ] **Step 3: Create the widget**

`lib/features/core/presentation/widgets/app_notification_builder.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../bloc/app_notification_cubit.dart';
import '../bloc/app_notification_state.dart';

class AppNotificationBuilder extends StatelessWidget {
  const AppNotificationBuilder({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppNotificationCubit, AppNotificationState>(
      listener: (context, state) {
        switch (state) {
          case AppNotificationInitial():
            return;
          case AppNotificationReceived(:final notification):
            _showSnackBar(context, notification);
        }
      },
      child: child,
    );
  }

  void _showSnackBar(BuildContext context, AppNotification notification) {
    final scheme = Theme.of(context).colorScheme;
    final (color, icon, text) = switch (notification) {
      AppNotificationSuccess(:final message, :final title) =>
        (scheme.primaryContainer, Icons.check_circle, _compose(title, message)),
      AppNotificationError(:final message, :final title) =>
        (scheme.errorContainer, Icons.error, _compose(title, message)),
      AppNotificationInfo(:final message, :final title) =>
        (scheme.secondaryContainer, Icons.info, _compose(title, message)),
      AppNotificationWarning(:final message, :final title) =>
        (scheme.tertiaryContainer, Icons.warning, _compose(title, message)),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
  }

  String _compose(String? title, String message) =>
      title == null ? message : '$title: $message';
}
```

- [ ] **Step 4: Run the test (expect PASS)**

Run: `fvm flutter test test/features/core/presentation/widgets/app_notification_builder_test.dart`
Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/core/presentation/widgets/ \
        test/features/core/presentation/widgets/
git commit -m "feat(wail-12): add AppNotificationBuilder rendering SnackBar per variant"
```

---

## Task 14: `DemoHomeScreen`

**Files:**
- Create: `lib/features/core/presentation/screens/demo_home_screen.dart`

- [ ] **Step 1: Create the screen**

`lib/features/core/presentation/screens/demo_home_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/managers/notification_manager.dart';
import '../../domain/use_cases/no_params.dart';
import '../../domain/use_cases/trigger_demo_error_use_case.dart';

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

- [ ] **Step 2: Verify analyze**

Run: `fvm flutter analyze lib/features/core/presentation/screens/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/core/presentation/screens/
git commit -m "feat(wail-12): add DemoHomeScreen with direct + use-case notification triggers"
```

---

## Task 15: `app_router.dart`

**Files:**
- Create: `lib/core/router/app_router.dart`

- [ ] **Step 1: Create the router**

`lib/core/router/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';

import '../../features/core/presentation/screens/demo_home_screen.dart';

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

- [ ] **Step 2: Verify analyze**

Run: `fvm flutter analyze lib/core/router/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/router/
git commit -m "feat(wail-12): add minimal GoRouter with demo home route"
```

---

## Task 16: `app.dart` (App widget)

**Files:**
- Create: `lib/app.dart`

- [ ] **Step 1: Create the App widget**

`lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/core/presentation/bloc/app_notification_cubit.dart';
import 'features/core/presentation/widgets/app_notification_builder.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppNotificationCubit>(
          create: (_) => getIt<AppNotificationCubit>(),
        ),
        // Future app-scope cubits go here.
      ],
      child: MaterialApp.router(
        title: 'Waily',
        builder: (context, child) => AppNotificationBuilder(
          child: child ?? const SizedBox.shrink(),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analyze**

Run: `fvm flutter analyze lib/app.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app.dart
git commit -m "feat(wail-12): add App widget with MultiBlocProvider and MaterialApp.router"
```

---

## Task 17: Rewrite `main.dart` and `widget_test.dart`

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Rewrite `main.dart`**

Replace the entire contents of `lib/main.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/observers/app_bloc_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = AppBlocObserver(getIt<Talker>());
  runApp(const App());
}
```

- [ ] **Step 2: Rewrite `test/widget_test.dart`**

Replace the entire contents of `test/widget_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waily/app.dart';
import 'package:waily/core/di/injection.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('App boots and shows the demo home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.text('Waily — state mgmt demo'), findsOneWidget);
    expect(find.text('Show notification (direct)'), findsOneWidget);
    expect(find.text('Trigger error via use case'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run all tests**

Run: `fvm flutter test`
Expected: every test in the suite passes (incl. the smoke widget test).

- [ ] **Step 4: Verify analyze**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Manual smoke run (optional but recommended)**

Run: `fvm flutter run -d <some-device>`
Expected: app boots, demo home screen renders, both buttons trigger SnackBars in their respective colors.

- [ ] **Step 6: Commit**

```bash
git add lib/main.dart test/widget_test.dart
git commit -m "feat(wail-12): wire main.dart through DI + Bloc.observer; smoke-test App"
```

---

## Task 18: Write `docs/state-management.md`

**Files:**
- Create: `docs/state-management.md`

- [ ] **Step 1: Create the doc**

`docs/state-management.md`:

```markdown
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
- **Datasource** (`lib/features/<name>/data/sources/`) — extends `AppGateway`; wraps Dio / storage / DB calls in `safeCall<T>` or `voidSafeCall`.

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
- Cubits register with `@injectable` (new instance per scope).
- Repositories register with `@LazySingleton(as: <Interface>)`.
- Datasources register with `@Injectable(as: <Interface>)` and extend `AppGateway`.
- Mappers are Dart extensions on API models (`toEntity()`), invoked at the repository layer.

## Testing

- `bloc_test` for cubit emission tests.
- `mockito` with `@GenerateMocks` for collaborator mocks.
- One mocks file per feature (e.g. `test/features/<name>/mocks.dart`).
- Widget tests for any screen wired to a cubit (use `BlocProvider.value` with a mocked cubit and `whenListen`).

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
```

- [ ] **Step 2: Commit**

```bash
git add docs/state-management.md
git commit -m "docs(wail-12): add team state management guide and persistence rules"
```

---

## Task 19: Add Persistence section to `CLAUDE.md`

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Insert subsection**

Open `CLAUDE.md`. Find the line `## State management` and the `Use Cases` example below it. After the existing State management section (right before the next top-level heading or `## Data models`), insert:

```markdown
### Persistence

- `LocalStorage` (SharedPreferences-backed) for non-sensitive prefs (theme, locale, onboarding flags).
- `SecureStorage` (flutter_secure_storage) for tokens and secrets.
- Never store tokens in `LocalStorage`. See `docs/state-management.md` for the full guide.
```

- [ ] **Step 2: Verify rendered markdown**

Run: `grep -n "### Persistence" CLAUDE.md`
Expected: one match.

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs(wail-12): add Persistence subsection to CLAUDE.md"
```

---

## Task 20: Add State management section to `README.md`

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Append section**

Open `README.md`. Append at the end (or after the existing Getting Started / project description, whichever is later):

```markdown
## State management

State is managed with `flutter_bloc` (Cubit), `injectable` + `get_it`, and a small set of base classes documented in detail at [`docs/state-management.md`](docs/state-management.md). New features should copy the patterns from `lib/features/core/`.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs(wail-12): add State management section to README"
```

---

## Task 21: Final verification

**Files:** none (verification only)

- [ ] **Step 1: Clean build of generated files**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: exits 0, no errors.

- [ ] **Step 2: Static analysis**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Run the entire test suite**

Run: `fvm flutter test`
Expected: every test passes; total ≥ 16 tests across:
- `app_notification_test.dart` (3)
- `notification_exception_test.dart` (1)
- `notification_manager_impl_test.dart` (2)
- `app_gateway_test.dart` (4)
- `async_use_case_test.dart` (4)
- `sync_use_case_test.dart` (2)
- `app_notification_cubit_test.dart` (2)
- `app_notification_builder_test.dart` (2)
- `widget_test.dart` (1)

- [ ] **Step 4: AC verification matrix (manual run)**

Boot the app: `fvm flutter run -d <ios-or-android>`

Verify against the spec §11 matrix:

| AC | Manual check |
|----|--------------|
| Library configured | App boots without errors; check console for `AppBlocObserver` debug logs when pressing buttons |
| Global state structure defined | `lib/app.dart` shows `MultiBlocProvider` with the slot for future app-scope cubits |
| Example created and demoed | "Show notification (direct)" → green SnackBar; "Trigger error via use case" → red SnackBar with "Demo error: ..." |
| Persistence documented | `docs/state-management.md` exists; `LocalStorage`/`SecureStorage` exist in `getIt` (search the running app's logs or check `injection.config.dart`) |
| Team docs created | All three docs (`docs/state-management.md`, `README.md` section, `CLAUDE.md` Persistence) exist |

- [ ] **Step 5: Format check**

Run: `dart format --set-exit-if-changed lib test`
Expected: no files changed (the per-edit hook should have caught everything).

- [ ] **Step 6: Verify branch state**

Run: `git status && git log --oneline develop..HEAD`
Expected: clean working tree; one commit per task above (~20 commits).

If everything passes, `WAIL-12` is implementation-complete and ready for `/improvs:review` → `/improvs:finish`.
