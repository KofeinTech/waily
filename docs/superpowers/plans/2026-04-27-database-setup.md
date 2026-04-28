# WAIL-13 Local Database and Persistence — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up Drift (SQLite) as the local database, define schema for `User`, `WorkoutEntry`, `MealEntry`, `HydrationEntry`, and ship a per-feature data layer (entity + repository + datasource + mapper + tests) for each, plus a `data/sources/` → `data/datasources/` rename for the WAIL-12 cross-cutting files.

**Architecture:** `lib/core/database/` owns Drift schema (`tables.dart`), the `AppDatabase` connection, and DI registration. Each entity lives in its own feature folder under `lib/features/<entity>/` with `domain/{entities,repositories}` and `data/{datasources,repositories,mappers}` layers. Datasources extend `AppGateway` (WAIL-12) and wrap Drift queries in `safeCall`/`voidSafeCall`. Repositories consume datasources, apply mappers, return Freezed domain entities. Tests run against `NativeDatabase.memory()` for datasources and against `Mock<Entity>Datasource` (mockito) for repositories.

**Tech Stack:** Flutter (FVM 3.38.6), Drift, sqlite3_flutter_libs, path_provider, injectable + get_it, freezed, mockito.

**Spec:** `docs/superpowers/specs/2026-04-27-database-setup-design.md`

**Conventions used in every task:**
- All shell commands assume CWD = repo root (`/mnt/c/work/waily`).
- All Flutter commands use `fvm flutter ...`.
- Codegen command: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`. `--force-jit` is REQUIRED — without it `build_runner 2.14.1` fails AOT mode because of `objective_c` 9.3.0's native build hooks. Place `--force-jit` AFTER `build_runner build`.
- Generated files convention: `*.freezed.dart`, `*.g.dart`, `*.mocks.dart` are gitignored — DO NOT `git add` them. `injection.config.dart` is NOT gitignored — DO commit it. Staging by directory (`git add lib/foo/`) respects `.gitignore` automatically.
- Repo hooks: `dart format` runs after every file edit; pre-commit runs `flutter analyze` + `flutter test`. If a hook fails, FIX the underlying issue and create a NEW commit. Never use `--no-verify`.
- Never amend commits; always new commits. Heredoc commit messages with the standard `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>` trailer.
- Stage files explicitly by name. No `git add -A` / `.`.

---

## Task 1: Add Drift dependencies and bump build

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add runtime deps**

In `pubspec.yaml` `dependencies:`, after `flutter_secure_storage: ^9.2.2`, add:

```yaml
  drift: ^2.21.0
  drift_flutter: ^0.2.4
  sqlite3_flutter_libs: ^0.5.27
  path_provider: ^2.1.5
```

- [ ] **Step 2: Add dev dep**

In `dev_dependencies:`, after `mockito: ^5.6.4`, add:

```yaml
  drift_dev: ^2.21.0
```

- [ ] **Step 3: Resolve dependencies**

Run: `fvm flutter pub get`
Expected: exits 0; no version conflicts.

If pub solver fails: try the next minor down for the specific failing package (e.g. `drift_flutter: ^0.2.0`). Report BLOCKED only if you've tried two adjacent versions and the failure persists; do not improvise unrelated workarounds.

- [ ] **Step 4: Verify analyze**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "$(cat <<'EOF'
chore(wail-13): add drift, drift_flutter, sqlite3_flutter_libs, path_provider

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Create AppDatabase, tables, DI module, smoke test

**Files:**
- Create: `lib/core/database/tables.dart`
- Create: `lib/core/database/app_database.dart`
- Create: `lib/core/database/database_module.dart`
- Test: `test/core/database/app_database_test.dart`
- Generated (gitignored): `lib/core/database/app_database.g.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create `lib/core/database/tables.dart`**

```dart
import 'package:drift/drift.dart';

@DataClassName('UsersData')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().withLength(min: 1, max: 100).nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
}

@DataClassName('WorkoutsData')
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// One of: 'cardio' | 'strength' | 'rest' | 'hybrid'.
  /// Stored as TEXT; promoted to typed enum in a later migration.
  TextColumn get kind => text()();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
}

@DataClassName('MealsData')
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get calories => integer().nullable()();
  DateTimeColumn get eatenAt => dateTime()();
}

@DataClassName('HydrationsData')
class Hydrations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountMl => integer()();
  DateTimeColumn get createdAt => dateTime()();
}
```

- [ ] **Step 2: Create `lib/core/database/app_database.dart`**

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Workouts, Meals, Hydrations])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'waily_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}
```

- [ ] **Step 3: Create `lib/core/database/database_module.dart`**

```dart
import 'package:injectable/injectable.dart';

import 'app_database.dart';

@module
abstract class DatabaseModule {
  @Singleton(dispose: closeDatabase)
  AppDatabase appDatabase() => AppDatabase();
}

/// Public top-level so injectable_generator can reference it from the
/// generated config without an extra import.
Future<void> closeDatabase(AppDatabase db) => db.close();
```

- [ ] **Step 4: Run codegen**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: exits 0; creates `lib/core/database/app_database.g.dart`; `lib/core/di/injection.config.dart` now references `AppDatabase`.

If `app_database.g.dart` is missing afterwards, the codegen of the part-file failed — re-run with `--verbose` to inspect; do NOT hand-write the part file.

- [ ] **Step 5: Write the smoke test**

`test/core/database/app_database_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/database/app_database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('boots and creates the four core tables', () async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type='table' AND name NOT LIKE 'sqlite_%'",
          )
          .get();

      final tables = rows.map((r) => r.read<String>('name')).toSet();
      expect(tables, containsAll(<String>['users', 'workouts', 'meals', 'hydrations']));
    });
  });
}
```

- [ ] **Step 6: Run the smoke test**

Run: `fvm flutter test test/core/database/app_database_test.dart`
Expected: 1 test passes.

- [ ] **Step 7: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 analyze issues; full suite passes.

- [ ] **Step 8: Commit**

```bash
git add lib/core/database/ \
        lib/core/di/injection.config.dart \
        test/core/database/
git commit -m "$(cat <<'EOF'
feat(wail-13): add Drift AppDatabase with users, workouts, meals, hydrations tables

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: User feature — domain (entity + repository interface)

**Files:**
- Create: `lib/features/user/domain/entities/user.dart`
- Create: `lib/features/user/domain/repositories/user_repository.dart`

- [ ] **Step 1: Create the Freezed entity**

`lib/features/user/domain/entities/user.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    String? displayName,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
  }) = _User;
}
```

- [ ] **Step 2: Run codegen**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: creates `user.freezed.dart` (gitignored).

- [ ] **Step 3: Create the abstract repository**

`lib/features/user/domain/repositories/user_repository.dart`:

```dart
import '../entities/user.dart';

abstract class UserRepository {
  Future<User> add({
    String? displayName,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
  });

  /// Replaces all fields by [user.id].
  Future<User> update(User user);

  Future<User?> getById(int id);
  Future<List<User>> getAll();
  Future<void> delete(int id);
}
```

- [ ] **Step 4: Verify analyze**

Run: `fvm flutter analyze lib/features/user/`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/user/domain/
git commit -m "$(cat <<'EOF'
feat(wail-13): add User entity and UserRepository interface

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: User feature — datasource (interface + impl + tests)

**Files:**
- Create: `lib/features/user/data/datasources/user_datasource.dart`
- Create: `lib/features/user/data/datasources/user_datasource_impl.dart`
- Test: `test/features/user/data/datasources/user_datasource_impl_test.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create the datasource interface**

`lib/features/user/data/datasources/user_datasource.dart`:

```dart
import '../../../../core/database/app_database.dart';

abstract class UserDatasource {
  Future<int> insert({
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  });

  Future<void> updateById(
    int id, {
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  });

  Future<UsersData?> getById(int id);
  Future<List<UsersData>> getAll();
  Future<void> deleteById(int id);
}
```

- [ ] **Step 2: Write the failing datasource test FIRST (TDD)**

`test/features/user/data/datasources/user_datasource_impl_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/user/data/datasources/user_datasource_impl.dart';

import '../../../core/mocks.mocks.dart';

void main() {
  group('UserDatasourceImpl', () {
    late AppDatabase db;
    late MockTalker talker;
    late UserDatasourceImpl ds;

    setUp(() {
      talker = MockTalker();
      db = AppDatabase(NativeDatabase.memory());
      ds = UserDatasourceImpl(talker, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert with all-null optional fields returns assigned id', () async {
      final id = await ds.insert(
        displayName: null,
        dateOfBirth: null,
        heightCm: null,
        weightKg: null,
      );
      expect(id, greaterThan(0));
    });

    test('getById round-trips an inserted row', () async {
      final id = await ds.insert(
        displayName: 'Ana',
        dateOfBirth: DateTime(1990, 1, 1),
        heightCm: 170.5,
        weightKg: 65.0,
      );
      final row = await ds.getById(id);
      expect(row, isNotNull);
      expect(row!.displayName, 'Ana');
      expect(row.dateOfBirth, DateTime(1990, 1, 1));
      expect(row.heightCm, 170.5);
      expect(row.weightKg, 65.0);
    });

    test('getById returns null for non-existent id', () async {
      final row = await ds.getById(999);
      expect(row, isNull);
    });

    test('updateById replaces fields by id', () async {
      final id = await ds.insert(
        displayName: 'A', dateOfBirth: null, heightCm: null, weightKg: null,
      );
      await ds.updateById(
        id,
        displayName: 'B',
        dateOfBirth: DateTime(2000),
        heightCm: 180.0,
        weightKg: null,
      );
      final row = await ds.getById(id);
      expect(row!.displayName, 'B');
      expect(row.dateOfBirth, DateTime(2000));
      expect(row.heightCm, 180.0);
      expect(row.weightKg, isNull);
    });

    test('getAll returns rows in insertion order', () async {
      final id1 = await ds.insert(
        displayName: 'X', dateOfBirth: null, heightCm: null, weightKg: null,
      );
      final id2 = await ds.insert(
        displayName: 'Y', dateOfBirth: null, heightCm: null, weightKg: null,
      );
      final all = await ds.getAll();
      expect(all.map((r) => r.id), [id1, id2]);
    });

    test('deleteById removes the row; subsequent getAll is empty', () async {
      final id = await ds.insert(
        displayName: 'Z', dateOfBirth: null, heightCm: null, weightKg: null,
      );
      await ds.deleteById(id);
      final all = await ds.getAll();
      expect(all, isEmpty);
    });

    test('deleteById on non-existent id is a no-op (no throw)', () async {
      await ds.deleteById(999);
      // No expectation other than reaching this line.
    });
  });
}
```

- [ ] **Step 3: Run the test (expect FAIL)**

Run: `fvm flutter test test/features/user/data/datasources/user_datasource_impl_test.dart`
Expected: FAIL — `user_datasource_impl.dart` does not exist (import error).

- [ ] **Step 4: Create the datasource impl**

`lib/features/user/data/datasources/user_datasource_impl.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/data/gateway/app_gateway.dart';
import 'user_datasource.dart';

@Injectable(as: UserDatasource)
class UserDatasourceImpl extends AppGateway implements UserDatasource {
  UserDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  }) =>
      safeCall(() => _db.into(_db.users).insert(
            UsersCompanion.insert(
              displayName: Value(displayName),
              dateOfBirth: Value(dateOfBirth),
              heightCm: Value(heightCm),
              weightKg: Value(weightKg),
            ),
          ));

  @override
  Future<void> updateById(
    int id, {
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  }) =>
      voidSafeCall(() async {
        await (_db.update(_db.users)..where((t) => t.id.equals(id))).write(
          UsersCompanion(
            displayName: Value(displayName),
            dateOfBirth: Value(dateOfBirth),
            heightCm: Value(heightCm),
            weightKg: Value(weightKg),
          ),
        );
      });

  @override
  Future<UsersData?> getById(int id) => safeCall(
        () => (_db.select(_db.users)..where((t) => t.id.equals(id)))
            .getSingleOrNull(),
      );

  @override
  Future<List<UsersData>> getAll() => safeCall(
        () => (_db.select(_db.users)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get(),
      );

  @override
  Future<void> deleteById(int id) => voidSafeCall(() async {
        await (_db.delete(_db.users)..where((t) => t.id.equals(id))).go();
      });
}
```

- [ ] **Step 5: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs && fvm flutter test test/features/user/data/datasources/user_datasource_impl_test.dart`
Expected: codegen exits 0 (`injection.config.dart` registers `UserDatasourceImpl as UserDatasource`); 7 datasource tests pass.

- [ ] **Step 6: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; full suite green.

- [ ] **Step 7: Commit**

```bash
git add lib/features/user/data/datasources/ \
        lib/core/di/injection.config.dart \
        test/features/user/data/datasources/
git commit -m "$(cat <<'EOF'
feat(wail-13): add UserDatasource interface and Drift impl

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: User feature — repository (mapper + impl + tests)

**Files:**
- Create: `lib/features/user/data/mappers/user_mappers.dart`
- Create: `lib/features/user/data/repositories/user_repository_impl.dart`
- Create: `test/features/user/mocks.dart` (`@GenerateMocks([UserDatasource])`)
- Test: `test/features/user/data/repositories/user_repository_impl_test.dart`
- Generated (gitignored): `test/features/user/mocks.mocks.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create the mapper**

`lib/features/user/data/mappers/user_mappers.dart`:

```dart
import '../../../../core/database/app_database.dart';
import '../../domain/entities/user.dart';

extension UserRowMapper on UsersData {
  User toEntity() => User(
        id: id,
        displayName: displayName,
        dateOfBirth: dateOfBirth,
        heightCm: heightCm,
        weightKg: weightKg,
      );
}
```

- [ ] **Step 2: Create the per-feature mocks file**

`test/features/user/mocks.dart`:

```dart
import 'package:mockito/annotations.dart';
import 'package:waily/features/user/data/datasources/user_datasource.dart';

@GenerateMocks([UserDatasource])
void main() {}
```

- [ ] **Step 3: Run codegen for mocks**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: creates `test/features/user/mocks.mocks.dart` containing `MockUserDatasource`.

- [ ] **Step 4: Write the failing repository test**

`test/features/user/data/repositories/user_repository_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/user/data/repositories/user_repository_impl.dart';
import 'package:waily/features/user/domain/entities/user.dart';

import '../../mocks.mocks.dart';

void main() {
  group('UserRepositoryImpl', () {
    late MockUserDatasource ds;
    late UserRepositoryImpl repo;

    setUp(() {
      ds = MockUserDatasource();
      repo = UserRepositoryImpl(ds);
    });

    test('add delegates to insert and returns entity with assigned id', () async {
      when(ds.insert(
        displayName: anyNamed('displayName'),
        dateOfBirth: anyNamed('dateOfBirth'),
        heightCm: anyNamed('heightCm'),
        weightKg: anyNamed('weightKg'),
      )).thenAnswer((_) async => 42);

      final user = await repo.add(displayName: 'Ana', dateOfBirth: null,
                                  heightCm: 170.0, weightKg: null);

      expect(user.id, 42);
      expect(user.displayName, 'Ana');
      expect(user.heightCm, 170.0);
      verify(ds.insert(
        displayName: 'Ana',
        dateOfBirth: null,
        heightCm: 170.0,
        weightKg: null,
      )).called(1);
    });

    test('update delegates write then re-reads via getById', () async {
      const targetId = 7;
      const updated = User(
        id: targetId, displayName: 'B', dateOfBirth: null,
        heightCm: 180.0, weightKg: null,
      );
      when(ds.updateById(any,
        displayName: anyNamed('displayName'),
        dateOfBirth: anyNamed('dateOfBirth'),
        heightCm: anyNamed('heightCm'),
        weightKg: anyNamed('weightKg'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(targetId)).thenAnswer((_) async => UsersData(
            id: targetId, displayName: 'B', dateOfBirth: null,
            heightCm: 180.0, weightKg: null,
          ));

      final result = await repo.update(updated);

      expect(result, equals(updated));
      verify(ds.updateById(targetId,
        displayName: 'B', dateOfBirth: null, heightCm: 180.0, weightKg: null,
      )).called(1);
    });

    test('update throws StateError if datasource returns null afterwards',
        () async {
      when(ds.updateById(any,
        displayName: anyNamed('displayName'),
        dateOfBirth: anyNamed('dateOfBirth'),
        heightCm: anyNamed('heightCm'),
        weightKg: anyNamed('weightKg'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(any)).thenAnswer((_) async => null);

      await expectLater(
        () => repo.update(const User(id: 1)),
        throwsA(isA<StateError>()),
      );
    });

    test('getById maps row to entity; null row → null entity', () async {
      when(ds.getById(1)).thenAnswer((_) async => UsersData(
            id: 1, displayName: 'X', dateOfBirth: null,
            heightCm: null, weightKg: null,
          ));
      when(ds.getById(2)).thenAnswer((_) async => null);

      expect((await repo.getById(1))!.displayName, 'X');
      expect(await repo.getById(2), isNull);
    });

    test('getAll maps rows in order', () async {
      when(ds.getAll()).thenAnswer((_) async => [
            UsersData(id: 1, displayName: 'A', dateOfBirth: null,
                      heightCm: null, weightKg: null),
            UsersData(id: 2, displayName: 'B', dateOfBirth: null,
                      heightCm: null, weightKg: null),
          ]);

      final all = await repo.getAll();

      expect(all.map((u) => u.id), [1, 2]);
      expect(all.map((u) => u.displayName), ['A', 'B']);
    });

    test('delete delegates verbatim', () async {
      when(ds.deleteById(any)).thenAnswer((_) async => Future.value());

      await repo.delete(5);

      verify(ds.deleteById(5)).called(1);
    });
  });
}
```

- [ ] **Step 5: Run the repo test (expect FAIL — impl missing)**

Run: `fvm flutter test test/features/user/data/repositories/user_repository_impl_test.dart`
Expected: FAIL with import error on `user_repository_impl.dart`.

- [ ] **Step 6: Create the repository impl**

`lib/features/user/data/repositories/user_repository_impl.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_datasource.dart';
import '../mappers/user_mappers.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._ds);

  final UserDatasource _ds;

  @override
  Future<User> add({
    String? displayName,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
  }) async {
    final id = await _ds.insert(
      displayName: displayName,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
    );
    return User(
      id: id,
      displayName: displayName,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
    );
  }

  @override
  Future<User> update(User user) async {
    await _ds.updateById(
      user.id,
      displayName: user.displayName,
      dateOfBirth: user.dateOfBirth,
      heightCm: user.heightCm,
      weightKg: user.weightKg,
    );
    final row = await _ds.getById(user.id);
    if (row == null) {
      throw StateError('User ${user.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<User?> getById(int id) async => (await _ds.getById(id))?.toEntity();

  @override
  Future<List<User>> getAll() async {
    final rows = await _ds.getAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _ds.deleteById(id);
}
```

- [ ] **Step 7: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs && fvm flutter test test/features/user/data/repositories/user_repository_impl_test.dart`
Expected: codegen exits 0 (`UserRepositoryImpl` registered as `@LazySingleton`); 6 repository tests pass.

- [ ] **Step 8: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; full suite green.

- [ ] **Step 9: Commit**

```bash
git add lib/features/user/data/ \
        lib/core/di/injection.config.dart \
        test/features/user/mocks.dart \
        test/features/user/data/repositories/
git commit -m "$(cat <<'EOF'
feat(wail-13): add UserRepository impl with mapper and mock-driven tests

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: Workout feature — domain (entity + repository interface)

**Files:**
- Create: `lib/features/workout/domain/entities/workout_entry.dart`
- Create: `lib/features/workout/domain/repositories/workout_repository.dart`

- [ ] **Step 1: Create the Freezed entity**

`lib/features/workout/domain/entities/workout_entry.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_entry.freezed.dart';

@freezed
abstract class WorkoutEntry with _$WorkoutEntry {
  const factory WorkoutEntry({
    required int id,
    required String kind,
    required DateTime startedAt,
    DateTime? finishedAt,
  }) = _WorkoutEntry;
}
```

- [ ] **Step 2: Run codegen**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: creates `workout_entry.freezed.dart`.

- [ ] **Step 3: Create the abstract repository**

`lib/features/workout/domain/repositories/workout_repository.dart`:

```dart
import '../entities/workout_entry.dart';

abstract class WorkoutRepository {
  Future<WorkoutEntry> add({
    required String kind,
    required DateTime startedAt,
    DateTime? finishedAt,
  });

  Future<WorkoutEntry> update(WorkoutEntry entry);
  Future<WorkoutEntry?> getById(int id);
  Future<List<WorkoutEntry>> getAll();
  Future<void> delete(int id);
}
```

- [ ] **Step 4: Verify analyze**

Run: `fvm flutter analyze lib/features/workout/`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/workout/domain/
git commit -m "$(cat <<'EOF'
feat(wail-13): add WorkoutEntry entity and WorkoutRepository interface

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 7: Workout feature — datasource (interface + impl + tests)

**Files:**
- Create: `lib/features/workout/data/datasources/workout_datasource.dart`
- Create: `lib/features/workout/data/datasources/workout_datasource_impl.dart`
- Test: `test/features/workout/data/datasources/workout_datasource_impl_test.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create the interface**

`lib/features/workout/data/datasources/workout_datasource.dart`:

```dart
import '../../../../core/database/app_database.dart';

abstract class WorkoutDatasource {
  Future<int> insert({
    required String kind,
    required DateTime startedAt,
    required DateTime? finishedAt,
  });

  Future<void> updateById(
    int id, {
    required String kind,
    required DateTime startedAt,
    required DateTime? finishedAt,
  });

  Future<WorkoutsData?> getById(int id);
  Future<List<WorkoutsData>> getAll();
  Future<void> deleteById(int id);
}
```

- [ ] **Step 2: Write the failing test FIRST**

`test/features/workout/data/datasources/workout_datasource_impl_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/workout/data/datasources/workout_datasource_impl.dart';

import '../../../core/mocks.mocks.dart';

void main() {
  group('WorkoutDatasourceImpl', () {
    late AppDatabase db;
    late MockTalker talker;
    late WorkoutDatasourceImpl ds;

    setUp(() {
      talker = MockTalker();
      db = AppDatabase(NativeDatabase.memory());
      ds = WorkoutDatasourceImpl(talker, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert returns assigned id', () async {
      final id = await ds.insert(
        kind: 'cardio',
        startedAt: DateTime(2026, 4, 27, 8, 0),
        finishedAt: null,
      );
      expect(id, greaterThan(0));
    });

    test('getById round-trips an inserted row', () async {
      final start = DateTime(2026, 4, 27, 8, 0);
      final finish = DateTime(2026, 4, 27, 8, 45);
      final id = await ds.insert(
        kind: 'strength', startedAt: start, finishedAt: finish,
      );
      final row = await ds.getById(id);
      expect(row, isNotNull);
      expect(row!.kind, 'strength');
      expect(row.startedAt, start);
      expect(row.finishedAt, finish);
    });

    test('updateById can transition finishedAt from null to non-null',
        () async {
      final start = DateTime(2026, 4, 27, 8, 0);
      final id = await ds.insert(
        kind: 'cardio', startedAt: start, finishedAt: null,
      );
      final finish = DateTime(2026, 4, 27, 8, 30);
      await ds.updateById(
        id, kind: 'cardio', startedAt: start, finishedAt: finish,
      );
      final row = await ds.getById(id);
      expect(row!.finishedAt, finish);
    });

    test('getAll returns rows in insertion order', () async {
      final id1 = await ds.insert(
        kind: 'rest', startedAt: DateTime(2026, 4, 27, 7, 0), finishedAt: null,
      );
      final id2 = await ds.insert(
        kind: 'hybrid', startedAt: DateTime(2026, 4, 27, 18, 0),
        finishedAt: null,
      );
      final all = await ds.getAll();
      expect(all.map((r) => r.id), [id1, id2]);
    });

    test('deleteById removes the row', () async {
      final id = await ds.insert(
        kind: 'cardio',
        startedAt: DateTime(2026, 4, 27, 8, 0),
        finishedAt: null,
      );
      await ds.deleteById(id);
      expect(await ds.getById(id), isNull);
    });
  });
}
```

- [ ] **Step 3: Run the test (expect FAIL)**

Run: `fvm flutter test test/features/workout/data/datasources/workout_datasource_impl_test.dart`
Expected: FAIL — impl missing.

- [ ] **Step 4: Create the impl**

`lib/features/workout/data/datasources/workout_datasource_impl.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/data/gateway/app_gateway.dart';
import 'workout_datasource.dart';

@Injectable(as: WorkoutDatasource)
class WorkoutDatasourceImpl extends AppGateway implements WorkoutDatasource {
  WorkoutDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({
    required String kind,
    required DateTime startedAt,
    required DateTime? finishedAt,
  }) =>
      safeCall(() => _db.into(_db.workouts).insert(
            WorkoutsCompanion.insert(
              kind: kind,
              startedAt: startedAt,
              finishedAt: Value(finishedAt),
            ),
          ));

  @override
  Future<void> updateById(
    int id, {
    required String kind,
    required DateTime startedAt,
    required DateTime? finishedAt,
  }) =>
      voidSafeCall(() async {
        await (_db.update(_db.workouts)..where((t) => t.id.equals(id))).write(
          WorkoutsCompanion(
            kind: Value(kind),
            startedAt: Value(startedAt),
            finishedAt: Value(finishedAt),
          ),
        );
      });

  @override
  Future<WorkoutsData?> getById(int id) => safeCall(
        () => (_db.select(_db.workouts)..where((t) => t.id.equals(id)))
            .getSingleOrNull(),
      );

  @override
  Future<List<WorkoutsData>> getAll() => safeCall(
        () => (_db.select(_db.workouts)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get(),
      );

  @override
  Future<void> deleteById(int id) => voidSafeCall(() async {
        await (_db.delete(_db.workouts)..where((t) => t.id.equals(id))).go();
      });
}
```

- [ ] **Step 5: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs && fvm flutter test test/features/workout/data/datasources/workout_datasource_impl_test.dart`
Expected: 5 tests pass; `WorkoutDatasourceImpl as WorkoutDatasource` registered.

- [ ] **Step 6: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; full suite green.

- [ ] **Step 7: Commit**

```bash
git add lib/features/workout/data/datasources/ \
        lib/core/di/injection.config.dart \
        test/features/workout/data/datasources/
git commit -m "$(cat <<'EOF'
feat(wail-13): add WorkoutDatasource interface and Drift impl

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 8: Workout feature — repository (mapper + impl + tests)

**Files:**
- Create: `lib/features/workout/data/mappers/workout_mappers.dart`
- Create: `lib/features/workout/data/repositories/workout_repository_impl.dart`
- Create: `test/features/workout/mocks.dart`
- Test: `test/features/workout/data/repositories/workout_repository_impl_test.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create the mapper**

`lib/features/workout/data/mappers/workout_mappers.dart`:

```dart
import '../../../../core/database/app_database.dart';
import '../../domain/entities/workout_entry.dart';

extension WorkoutRowMapper on WorkoutsData {
  WorkoutEntry toEntity() => WorkoutEntry(
        id: id,
        kind: kind,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );
}
```

- [ ] **Step 2: Create the per-feature mocks**

`test/features/workout/mocks.dart`:

```dart
import 'package:mockito/annotations.dart';
import 'package:waily/features/workout/data/datasources/workout_datasource.dart';

@GenerateMocks([WorkoutDatasource])
void main() {}
```

- [ ] **Step 3: Run codegen**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: creates `test/features/workout/mocks.mocks.dart`.

- [ ] **Step 4: Write the failing repo test**

`test/features/workout/data/repositories/workout_repository_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:waily/features/workout/domain/entities/workout_entry.dart';

import '../../mocks.mocks.dart';

void main() {
  group('WorkoutRepositoryImpl', () {
    late MockWorkoutDatasource ds;
    late WorkoutRepositoryImpl repo;

    setUp(() {
      ds = MockWorkoutDatasource();
      repo = WorkoutRepositoryImpl(ds);
    });

    test('add inserts and returns entity with assigned id', () async {
      final start = DateTime(2026, 4, 27, 8, 0);
      when(ds.insert(
        kind: anyNamed('kind'),
        startedAt: anyNamed('startedAt'),
        finishedAt: anyNamed('finishedAt'),
      )).thenAnswer((_) async => 11);

      final entry = await repo.add(kind: 'cardio', startedAt: start);

      expect(entry.id, 11);
      expect(entry.kind, 'cardio');
      expect(entry.startedAt, start);
      expect(entry.finishedAt, isNull);
      verify(ds.insert(kind: 'cardio', startedAt: start, finishedAt: null))
          .called(1);
    });

    test('update writes and re-reads', () async {
      const targetId = 3;
      final start = DateTime(2026, 4, 27, 9, 0);
      final finish = DateTime(2026, 4, 27, 9, 30);
      final updated = WorkoutEntry(
        id: targetId, kind: 'strength', startedAt: start, finishedAt: finish,
      );
      when(ds.updateById(any,
        kind: anyNamed('kind'),
        startedAt: anyNamed('startedAt'),
        finishedAt: anyNamed('finishedAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(targetId)).thenAnswer((_) async => WorkoutsData(
            id: targetId, kind: 'strength', startedAt: start,
            finishedAt: finish,
          ));

      final result = await repo.update(updated);

      expect(result, equals(updated));
    });

    test('getById maps row to entity', () async {
      final start = DateTime(2026, 4, 27, 7, 0);
      when(ds.getById(1)).thenAnswer((_) async => WorkoutsData(
            id: 1, kind: 'rest', startedAt: start, finishedAt: null,
          ));
      when(ds.getById(2)).thenAnswer((_) async => null);

      final result = await repo.getById(1);
      expect(result!.kind, 'rest');
      expect(await repo.getById(2), isNull);
    });

    test('getAll maps rows in order', () async {
      final t1 = DateTime(2026, 4, 27, 7, 0);
      final t2 = DateTime(2026, 4, 27, 18, 0);
      when(ds.getAll()).thenAnswer((_) async => [
            WorkoutsData(id: 1, kind: 'cardio', startedAt: t1, finishedAt: null),
            WorkoutsData(id: 2, kind: 'hybrid', startedAt: t2, finishedAt: null),
          ]);

      final all = await repo.getAll();

      expect(all.map((e) => e.kind), ['cardio', 'hybrid']);
    });

    test('delete delegates verbatim', () async {
      when(ds.deleteById(any)).thenAnswer((_) async => Future.value());
      await repo.delete(7);
      verify(ds.deleteById(7)).called(1);
    });
  });
}
```

- [ ] **Step 5: Run the test (expect FAIL — impl missing)**

Run: `fvm flutter test test/features/workout/data/repositories/workout_repository_impl_test.dart`
Expected: FAIL with import error.

- [ ] **Step 6: Create the repo impl**

`lib/features/workout/data/repositories/workout_repository_impl.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/workout_entry.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_datasource.dart';
import '../mappers/workout_mappers.dart';

@LazySingleton(as: WorkoutRepository)
class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._ds);

  final WorkoutDatasource _ds;

  @override
  Future<WorkoutEntry> add({
    required String kind,
    required DateTime startedAt,
    DateTime? finishedAt,
  }) async {
    final id = await _ds.insert(
      kind: kind, startedAt: startedAt, finishedAt: finishedAt,
    );
    return WorkoutEntry(
      id: id, kind: kind, startedAt: startedAt, finishedAt: finishedAt,
    );
  }

  @override
  Future<WorkoutEntry> update(WorkoutEntry entry) async {
    await _ds.updateById(
      entry.id,
      kind: entry.kind,
      startedAt: entry.startedAt,
      finishedAt: entry.finishedAt,
    );
    final row = await _ds.getById(entry.id);
    if (row == null) {
      throw StateError('WorkoutEntry ${entry.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<WorkoutEntry?> getById(int id) async =>
      (await _ds.getById(id))?.toEntity();

  @override
  Future<List<WorkoutEntry>> getAll() async {
    final rows = await _ds.getAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _ds.deleteById(id);
}
```

- [ ] **Step 7: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs && fvm flutter test test/features/workout/data/repositories/workout_repository_impl_test.dart`
Expected: 5 repo tests pass; `WorkoutRepositoryImpl` registered.

- [ ] **Step 8: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; full suite green.

- [ ] **Step 9: Commit**

```bash
git add lib/features/workout/data/ \
        lib/core/di/injection.config.dart \
        test/features/workout/mocks.dart \
        test/features/workout/data/repositories/
git commit -m "$(cat <<'EOF'
feat(wail-13): add WorkoutRepository impl with mapper and mock-driven tests

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 9: Meal feature — domain (entity + repository interface)

**Files:**
- Create: `lib/features/meal/domain/entities/meal_entry.dart`
- Create: `lib/features/meal/domain/repositories/meal_repository.dart`

- [ ] **Step 1: Create the Freezed entity**

`lib/features/meal/domain/entities/meal_entry.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_entry.freezed.dart';

@freezed
abstract class MealEntry with _$MealEntry {
  const factory MealEntry({
    required int id,
    required String name,
    int? calories,
    required DateTime eatenAt,
  }) = _MealEntry;
}
```

- [ ] **Step 2: Run codegen**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: creates `meal_entry.freezed.dart`.

- [ ] **Step 3: Create the abstract repository**

`lib/features/meal/domain/repositories/meal_repository.dart`:

```dart
import '../entities/meal_entry.dart';

abstract class MealRepository {
  Future<MealEntry> add({
    required String name,
    int? calories,
    required DateTime eatenAt,
  });

  Future<MealEntry> update(MealEntry entry);
  Future<MealEntry?> getById(int id);
  Future<List<MealEntry>> getAll();
  Future<void> delete(int id);
}
```

- [ ] **Step 4: Verify analyze**

Run: `fvm flutter analyze lib/features/meal/`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/meal/domain/
git commit -m "$(cat <<'EOF'
feat(wail-13): add MealEntry entity and MealRepository interface

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 10: Meal feature — datasource (interface + impl + tests)

**Files:**
- Create: `lib/features/meal/data/datasources/meal_datasource.dart`
- Create: `lib/features/meal/data/datasources/meal_datasource_impl.dart`
- Test: `test/features/meal/data/datasources/meal_datasource_impl_test.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create the interface**

`lib/features/meal/data/datasources/meal_datasource.dart`:

```dart
import '../../../../core/database/app_database.dart';

abstract class MealDatasource {
  Future<int> insert({
    required String name,
    required int? calories,
    required DateTime eatenAt,
  });

  Future<void> updateById(
    int id, {
    required String name,
    required int? calories,
    required DateTime eatenAt,
  });

  Future<MealsData?> getById(int id);
  Future<List<MealsData>> getAll();
  Future<void> deleteById(int id);
}
```

- [ ] **Step 2: Write the failing test**

`test/features/meal/data/datasources/meal_datasource_impl_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/meal/data/datasources/meal_datasource_impl.dart';

import '../../../core/mocks.mocks.dart';

void main() {
  group('MealDatasourceImpl', () {
    late AppDatabase db;
    late MockTalker talker;
    late MealDatasourceImpl ds;

    setUp(() {
      talker = MockTalker();
      db = AppDatabase(NativeDatabase.memory());
      ds = MealDatasourceImpl(talker, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert returns assigned id', () async {
      final id = await ds.insert(
        name: 'Oatmeal',
        calories: 300,
        eatenAt: DateTime(2026, 4, 27, 8, 0),
      );
      expect(id, greaterThan(0));
    });

    test('getById round-trips an inserted row', () async {
      final eaten = DateTime(2026, 4, 27, 12, 30);
      final id = await ds.insert(name: 'Salad', calories: 150, eatenAt: eaten);
      final row = await ds.getById(id);
      expect(row!.name, 'Salad');
      expect(row.calories, 150);
      expect(row.eatenAt, eaten);
    });

    test('insert with null calories succeeds', () async {
      final id = await ds.insert(
        name: 'Apple',
        calories: null,
        eatenAt: DateTime(2026, 4, 27, 10, 0),
      );
      final row = await ds.getById(id);
      expect(row!.calories, isNull);
    });

    test('updateById replaces fields', () async {
      final eaten = DateTime(2026, 4, 27, 12, 0);
      final id = await ds.insert(name: 'Soup', calories: 200, eatenAt: eaten);
      await ds.updateById(id, name: 'Pho', calories: 450, eatenAt: eaten);
      final row = await ds.getById(id);
      expect(row!.name, 'Pho');
      expect(row.calories, 450);
    });

    test('getAll returns rows in insertion order', () async {
      final id1 = await ds.insert(
        name: 'A', calories: null, eatenAt: DateTime(2026, 4, 27, 8, 0),
      );
      final id2 = await ds.insert(
        name: 'B', calories: null, eatenAt: DateTime(2026, 4, 27, 12, 0),
      );
      final all = await ds.getAll();
      expect(all.map((r) => r.id), [id1, id2]);
    });

    test('deleteById removes the row', () async {
      final id = await ds.insert(
        name: 'X', calories: null, eatenAt: DateTime(2026, 4, 27, 8, 0),
      );
      await ds.deleteById(id);
      expect(await ds.getById(id), isNull);
    });
  });
}
```

- [ ] **Step 3: Run the test (expect FAIL)**

Run: `fvm flutter test test/features/meal/data/datasources/meal_datasource_impl_test.dart`
Expected: FAIL — impl missing.

- [ ] **Step 4: Create the impl**

`lib/features/meal/data/datasources/meal_datasource_impl.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/data/gateway/app_gateway.dart';
import 'meal_datasource.dart';

@Injectable(as: MealDatasource)
class MealDatasourceImpl extends AppGateway implements MealDatasource {
  MealDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({
    required String name,
    required int? calories,
    required DateTime eatenAt,
  }) =>
      safeCall(() => _db.into(_db.meals).insert(
            MealsCompanion.insert(
              name: name,
              calories: Value(calories),
              eatenAt: eatenAt,
            ),
          ));

  @override
  Future<void> updateById(
    int id, {
    required String name,
    required int? calories,
    required DateTime eatenAt,
  }) =>
      voidSafeCall(() async {
        await (_db.update(_db.meals)..where((t) => t.id.equals(id))).write(
          MealsCompanion(
            name: Value(name),
            calories: Value(calories),
            eatenAt: Value(eatenAt),
          ),
        );
      });

  @override
  Future<MealsData?> getById(int id) => safeCall(
        () => (_db.select(_db.meals)..where((t) => t.id.equals(id)))
            .getSingleOrNull(),
      );

  @override
  Future<List<MealsData>> getAll() => safeCall(
        () => (_db.select(_db.meals)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get(),
      );

  @override
  Future<void> deleteById(int id) => voidSafeCall(() async {
        await (_db.delete(_db.meals)..where((t) => t.id.equals(id))).go();
      });
}
```

- [ ] **Step 5: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs && fvm flutter test test/features/meal/data/datasources/meal_datasource_impl_test.dart`
Expected: 6 datasource tests pass; `MealDatasourceImpl` registered.

- [ ] **Step 6: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; full suite green.

- [ ] **Step 7: Commit**

```bash
git add lib/features/meal/data/datasources/ \
        lib/core/di/injection.config.dart \
        test/features/meal/data/datasources/
git commit -m "$(cat <<'EOF'
feat(wail-13): add MealDatasource interface and Drift impl

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 11: Meal feature — repository (mapper + impl + tests)

**Files:**
- Create: `lib/features/meal/data/mappers/meal_mappers.dart`
- Create: `lib/features/meal/data/repositories/meal_repository_impl.dart`
- Create: `test/features/meal/mocks.dart`
- Test: `test/features/meal/data/repositories/meal_repository_impl_test.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create the mapper**

`lib/features/meal/data/mappers/meal_mappers.dart`:

```dart
import '../../../../core/database/app_database.dart';
import '../../domain/entities/meal_entry.dart';

extension MealRowMapper on MealsData {
  MealEntry toEntity() => MealEntry(
        id: id,
        name: name,
        calories: calories,
        eatenAt: eatenAt,
      );
}
```

- [ ] **Step 2: Create the per-feature mocks**

`test/features/meal/mocks.dart`:

```dart
import 'package:mockito/annotations.dart';
import 'package:waily/features/meal/data/datasources/meal_datasource.dart';

@GenerateMocks([MealDatasource])
void main() {}
```

- [ ] **Step 3: Run codegen**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: creates `test/features/meal/mocks.mocks.dart`.

- [ ] **Step 4: Write the failing repo test**

`test/features/meal/data/repositories/meal_repository_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/meal/data/repositories/meal_repository_impl.dart';
import 'package:waily/features/meal/domain/entities/meal_entry.dart';

import '../../mocks.mocks.dart';

void main() {
  group('MealRepositoryImpl', () {
    late MockMealDatasource ds;
    late MealRepositoryImpl repo;

    setUp(() {
      ds = MockMealDatasource();
      repo = MealRepositoryImpl(ds);
    });

    test('add inserts and returns entity with assigned id', () async {
      final eaten = DateTime(2026, 4, 27, 12, 0);
      when(ds.insert(
        name: anyNamed('name'),
        calories: anyNamed('calories'),
        eatenAt: anyNamed('eatenAt'),
      )).thenAnswer((_) async => 9);

      final entry = await repo.add(
        name: 'Pho', calories: 450, eatenAt: eaten,
      );

      expect(entry.id, 9);
      expect(entry.name, 'Pho');
      expect(entry.calories, 450);
      verify(ds.insert(name: 'Pho', calories: 450, eatenAt: eaten)).called(1);
    });

    test('update writes and re-reads', () async {
      const targetId = 4;
      final eaten = DateTime(2026, 4, 27, 12, 0);
      final updated = MealEntry(
        id: targetId, name: 'Salad', calories: 200, eatenAt: eaten,
      );
      when(ds.updateById(any,
        name: anyNamed('name'),
        calories: anyNamed('calories'),
        eatenAt: anyNamed('eatenAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(targetId)).thenAnswer((_) async => MealsData(
            id: targetId, name: 'Salad', calories: 200, eatenAt: eaten,
          ));

      final result = await repo.update(updated);

      expect(result, equals(updated));
    });

    test('update throws StateError if datasource returns null afterwards',
        () async {
      when(ds.updateById(any,
        name: anyNamed('name'),
        calories: anyNamed('calories'),
        eatenAt: anyNamed('eatenAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(any)).thenAnswer((_) async => null);

      await expectLater(
        () => repo.update(MealEntry(
          id: 1, name: 'X', eatenAt: DateTime(2026, 4, 27),
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('getById maps row to entity', () async {
      final eaten = DateTime(2026, 4, 27, 8, 0);
      when(ds.getById(1)).thenAnswer((_) async => MealsData(
            id: 1, name: 'Toast', calories: 250, eatenAt: eaten,
          ));
      when(ds.getById(2)).thenAnswer((_) async => null);

      expect((await repo.getById(1))!.name, 'Toast');
      expect(await repo.getById(2), isNull);
    });

    test('getAll maps rows in order', () async {
      final t = DateTime(2026, 4, 27, 8, 0);
      when(ds.getAll()).thenAnswer((_) async => [
            MealsData(id: 1, name: 'A', calories: null, eatenAt: t),
            MealsData(id: 2, name: 'B', calories: null, eatenAt: t),
          ]);
      final all = await repo.getAll();
      expect(all.map((m) => m.name), ['A', 'B']);
    });

    test('delete delegates verbatim', () async {
      when(ds.deleteById(any)).thenAnswer((_) async => Future.value());
      await repo.delete(7);
      verify(ds.deleteById(7)).called(1);
    });
  });
}
```

- [ ] **Step 5: Run the test (expect FAIL)**

Run: `fvm flutter test test/features/meal/data/repositories/meal_repository_impl_test.dart`
Expected: FAIL — impl missing.

- [ ] **Step 6: Create the repo impl**

`lib/features/meal/data/repositories/meal_repository_impl.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/meal_entry.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_datasource.dart';
import '../mappers/meal_mappers.dart';

@LazySingleton(as: MealRepository)
class MealRepositoryImpl implements MealRepository {
  MealRepositoryImpl(this._ds);

  final MealDatasource _ds;

  @override
  Future<MealEntry> add({
    required String name,
    int? calories,
    required DateTime eatenAt,
  }) async {
    final id = await _ds.insert(
      name: name, calories: calories, eatenAt: eatenAt,
    );
    return MealEntry(
      id: id, name: name, calories: calories, eatenAt: eatenAt,
    );
  }

  @override
  Future<MealEntry> update(MealEntry entry) async {
    await _ds.updateById(
      entry.id,
      name: entry.name,
      calories: entry.calories,
      eatenAt: entry.eatenAt,
    );
    final row = await _ds.getById(entry.id);
    if (row == null) {
      throw StateError('MealEntry ${entry.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<MealEntry?> getById(int id) async =>
      (await _ds.getById(id))?.toEntity();

  @override
  Future<List<MealEntry>> getAll() async {
    final rows = await _ds.getAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _ds.deleteById(id);
}
```

- [ ] **Step 7: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs && fvm flutter test test/features/meal/data/repositories/meal_repository_impl_test.dart`
Expected: 5 repo tests pass.

- [ ] **Step 8: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; full suite green.

- [ ] **Step 9: Commit**

```bash
git add lib/features/meal/data/ \
        lib/core/di/injection.config.dart \
        test/features/meal/mocks.dart \
        test/features/meal/data/repositories/
git commit -m "$(cat <<'EOF'
feat(wail-13): add MealRepository impl with mapper and mock-driven tests

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 12: Hydration feature — domain (entity + repository interface)

**Files:**
- Create: `lib/features/hydration/domain/entities/hydration_entry.dart`
- Create: `lib/features/hydration/domain/repositories/hydration_repository.dart`

- [ ] **Step 1: Create the Freezed entity**

`lib/features/hydration/domain/entities/hydration_entry.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hydration_entry.freezed.dart';

@freezed
abstract class HydrationEntry with _$HydrationEntry {
  const factory HydrationEntry({
    required int id,
    required int amountMl,
    required DateTime createdAt,
  }) = _HydrationEntry;
}
```

- [ ] **Step 2: Run codegen**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: creates `hydration_entry.freezed.dart`.

- [ ] **Step 3: Create the abstract repository**

`lib/features/hydration/domain/repositories/hydration_repository.dart`:

```dart
import '../entities/hydration_entry.dart';

abstract class HydrationRepository {
  Future<HydrationEntry> add(int amountMl);
  Future<HydrationEntry> update(HydrationEntry entry);
  Future<HydrationEntry?> getById(int id);
  Future<List<HydrationEntry>> getAll();
  Future<void> delete(int id);

  /// Total ml drunk today (local start-of-day). Demonstrates aggregation.
  Future<int> sumToday();
}
```

- [ ] **Step 4: Verify analyze**

Run: `fvm flutter analyze lib/features/hydration/`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/hydration/domain/
git commit -m "$(cat <<'EOF'
feat(wail-13): add HydrationEntry entity and HydrationRepository interface

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 13: Hydration feature — datasource (interface + impl + tests)

**Files:**
- Create: `lib/features/hydration/data/datasources/hydration_datasource.dart`
- Create: `lib/features/hydration/data/datasources/hydration_datasource_impl.dart`
- Test: `test/features/hydration/data/datasources/hydration_datasource_impl_test.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create the interface**

`lib/features/hydration/data/datasources/hydration_datasource.dart`:

```dart
import '../../../../core/database/app_database.dart';

abstract class HydrationDatasource {
  Future<int> insert({required int amountMl, required DateTime createdAt});

  Future<void> updateById(
    int id, {
    required int amountMl,
    required DateTime createdAt,
  });

  Future<HydrationsData?> getById(int id);

  Future<List<HydrationsData>> getAllOrderedByCreatedAtDesc();

  Future<void> deleteById(int id);

  /// SUM of amount_ml for createdAt >= [since].
  Future<int> sumSince(DateTime since);
}
```

- [ ] **Step 2: Write the failing test**

`test/features/hydration/data/datasources/hydration_datasource_impl_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/hydration/data/datasources/hydration_datasource_impl.dart';

import '../../../core/mocks.mocks.dart';

void main() {
  group('HydrationDatasourceImpl', () {
    late AppDatabase db;
    late MockTalker talker;
    late HydrationDatasourceImpl ds;

    setUp(() {
      talker = MockTalker();
      db = AppDatabase(NativeDatabase.memory());
      ds = HydrationDatasourceImpl(talker, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert returns assigned id', () async {
      final id = await ds.insert(
        amountMl: 250, createdAt: DateTime(2026, 4, 27, 9, 0),
      );
      expect(id, greaterThan(0));
    });

    test('getById round-trips an inserted row', () async {
      final created = DateTime(2026, 4, 27, 10, 0);
      final id = await ds.insert(amountMl: 500, createdAt: created);
      final row = await ds.getById(id);
      expect(row!.amountMl, 500);
      expect(row.createdAt, created);
    });

    test('getAllOrderedByCreatedAtDesc orders most-recent first', () async {
      final earlier = DateTime(2026, 4, 27, 8, 0);
      final later = DateTime(2026, 4, 27, 18, 0);
      await ds.insert(amountMl: 100, createdAt: earlier);
      await ds.insert(amountMl: 200, createdAt: later);

      final all = await ds.getAllOrderedByCreatedAtDesc();

      expect(all.map((r) => r.createdAt), [later, earlier]);
    });

    test('updateById replaces fields by id', () async {
      final created = DateTime(2026, 4, 27, 9, 0);
      final id = await ds.insert(amountMl: 250, createdAt: created);
      final newCreated = DateTime(2026, 4, 27, 10, 0);
      await ds.updateById(id, amountMl: 333, createdAt: newCreated);
      final row = await ds.getById(id);
      expect(row!.amountMl, 333);
      expect(row.createdAt, newCreated);
    });

    test('deleteById removes the row', () async {
      final id = await ds.insert(
        amountMl: 100, createdAt: DateTime(2026, 4, 27, 9, 0),
      );
      await ds.deleteById(id);
      expect(await ds.getById(id), isNull);
    });

    test('sumSince aggregates only rows where createdAt >= since', () async {
      final cutoff = DateTime(2026, 4, 27, 0, 0);
      // Two rows AT/AFTER cutoff:
      await ds.insert(amountMl: 250, createdAt: DateTime(2026, 4, 27, 9, 0));
      await ds.insert(amountMl: 500, createdAt: DateTime(2026, 4, 27, 18, 0));
      // One row BEFORE cutoff:
      await ds.insert(amountMl: 999, createdAt: DateTime(2026, 4, 26, 23, 30));

      final sum = await ds.sumSince(cutoff);

      expect(sum, 750);
    });

    test('sumSince returns 0 when no rows match', () async {
      final cutoff = DateTime(2026, 4, 27, 0, 0);
      await ds.insert(
        amountMl: 100, createdAt: DateTime(2026, 4, 26, 23, 0),
      );
      final sum = await ds.sumSince(cutoff);
      expect(sum, 0);
    });
  });
}
```

- [ ] **Step 3: Run the test (expect FAIL)**

Run: `fvm flutter test test/features/hydration/data/datasources/hydration_datasource_impl_test.dart`
Expected: FAIL — impl missing.

- [ ] **Step 4: Create the impl**

`lib/features/hydration/data/datasources/hydration_datasource_impl.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/data/gateway/app_gateway.dart';
import 'hydration_datasource.dart';

@Injectable(as: HydrationDatasource)
class HydrationDatasourceImpl extends AppGateway
    implements HydrationDatasource {
  HydrationDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({
    required int amountMl,
    required DateTime createdAt,
  }) =>
      safeCall(() => _db.into(_db.hydrations).insert(
            HydrationsCompanion.insert(
              amountMl: amountMl, createdAt: createdAt,
            ),
          ));

  @override
  Future<void> updateById(
    int id, {
    required int amountMl,
    required DateTime createdAt,
  }) =>
      voidSafeCall(() async {
        await (_db.update(_db.hydrations)..where((t) => t.id.equals(id)))
            .write(HydrationsCompanion(
          amountMl: Value(amountMl),
          createdAt: Value(createdAt),
        ));
      });

  @override
  Future<HydrationsData?> getById(int id) => safeCall(
        () => (_db.select(_db.hydrations)..where((t) => t.id.equals(id)))
            .getSingleOrNull(),
      );

  @override
  Future<List<HydrationsData>> getAllOrderedByCreatedAtDesc() => safeCall(
        () => (_db.select(_db.hydrations)
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get(),
      );

  @override
  Future<void> deleteById(int id) => voidSafeCall(() async {
        await (_db.delete(_db.hydrations)..where((t) => t.id.equals(id))).go();
      });

  @override
  Future<int> sumSince(DateTime since) => safeCall(() async {
        final sumExpr = _db.hydrations.amountMl.sum();
        final query = _db.selectOnly(_db.hydrations)
          ..addColumns([sumExpr])
          ..where(_db.hydrations.createdAt.isBiggerOrEqualValue(since));
        final row = await query.getSingle();
        return row.read(sumExpr) ?? 0;
      });
}
```

- [ ] **Step 5: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs && fvm flutter test test/features/hydration/data/datasources/hydration_datasource_impl_test.dart`
Expected: 7 datasource tests pass; `HydrationDatasourceImpl` registered.

- [ ] **Step 6: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; full suite green.

- [ ] **Step 7: Commit**

```bash
git add lib/features/hydration/data/datasources/ \
        lib/core/di/injection.config.dart \
        test/features/hydration/data/datasources/
git commit -m "$(cat <<'EOF'
feat(wail-13): add HydrationDatasource interface and Drift impl with sumSince

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 14: Hydration feature — repository (mapper + impl + tests)

**Files:**
- Create: `lib/features/hydration/data/mappers/hydration_mappers.dart`
- Create: `lib/features/hydration/data/repositories/hydration_repository_impl.dart`
- Create: `test/features/hydration/mocks.dart`
- Test: `test/features/hydration/data/repositories/hydration_repository_impl_test.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`

- [ ] **Step 1: Create the mapper**

`lib/features/hydration/data/mappers/hydration_mappers.dart`:

```dart
import '../../../../core/database/app_database.dart';
import '../../domain/entities/hydration_entry.dart';

extension HydrationRowMapper on HydrationsData {
  HydrationEntry toEntity() => HydrationEntry(
        id: id,
        amountMl: amountMl,
        createdAt: createdAt,
      );
}
```

- [ ] **Step 2: Create the per-feature mocks**

`test/features/hydration/mocks.dart`:

```dart
import 'package:mockito/annotations.dart';
import 'package:waily/features/hydration/data/datasources/hydration_datasource.dart';

@GenerateMocks([HydrationDatasource])
void main() {}
```

- [ ] **Step 3: Run codegen**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: creates `test/features/hydration/mocks.mocks.dart`.

- [ ] **Step 4: Write the failing repo test**

`test/features/hydration/data/repositories/hydration_repository_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/hydration/data/repositories/hydration_repository_impl.dart';
import 'package:waily/features/hydration/domain/entities/hydration_entry.dart';

import '../../mocks.mocks.dart';

void main() {
  group('HydrationRepositoryImpl', () {
    late MockHydrationDatasource ds;
    late HydrationRepositoryImpl repo;

    setUp(() {
      ds = MockHydrationDatasource();
      repo = HydrationRepositoryImpl(ds);
    });

    test('add inserts and returns entity with assigned id and now timestamp',
        () async {
      when(ds.insert(
        amountMl: anyNamed('amountMl'),
        createdAt: anyNamed('createdAt'),
      )).thenAnswer((_) async => 13);

      final before = DateTime.now();
      final entry = await repo.add(250);
      final after = DateTime.now();

      expect(entry.id, 13);
      expect(entry.amountMl, 250);
      expect(entry.createdAt.isBefore(before.subtract(const Duration(seconds: 1))),
          isFalse);
      expect(entry.createdAt.isAfter(after.add(const Duration(seconds: 1))),
          isFalse);
      verify(ds.insert(
        amountMl: 250,
        createdAt: argThat(isA<DateTime>(), named: 'createdAt'),
      )).called(1);
    });

    test('update writes and re-reads', () async {
      const targetId = 5;
      final ts = DateTime(2026, 4, 27, 9, 0);
      final updated = HydrationEntry(
        id: targetId, amountMl: 333, createdAt: ts,
      );
      when(ds.updateById(any,
        amountMl: anyNamed('amountMl'),
        createdAt: anyNamed('createdAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(targetId)).thenAnswer((_) async => HydrationsData(
            id: targetId, amountMl: 333, createdAt: ts,
          ));

      final result = await repo.update(updated);

      expect(result, equals(updated));
    });

    test('update throws StateError if datasource returns null afterwards',
        () async {
      when(ds.updateById(any,
        amountMl: anyNamed('amountMl'),
        createdAt: anyNamed('createdAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(any)).thenAnswer((_) async => null);

      await expectLater(
        () => repo.update(HydrationEntry(
          id: 1, amountMl: 250, createdAt: DateTime(2026, 4, 27),
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('getById maps row to entity', () async {
      final ts = DateTime(2026, 4, 27, 9, 0);
      when(ds.getById(1)).thenAnswer(
        (_) async => HydrationsData(id: 1, amountMl: 250, createdAt: ts),
      );
      when(ds.getById(2)).thenAnswer((_) async => null);

      expect((await repo.getById(1))!.amountMl, 250);
      expect(await repo.getById(2), isNull);
    });

    test('getAll maps rows in datasource-provided order', () async {
      final t1 = DateTime(2026, 4, 27, 18, 0);
      final t2 = DateTime(2026, 4, 27, 8, 0);
      when(ds.getAllOrderedByCreatedAtDesc()).thenAnswer((_) async => [
            HydrationsData(id: 1, amountMl: 500, createdAt: t1),
            HydrationsData(id: 2, amountMl: 100, createdAt: t2),
          ]);

      final all = await repo.getAll();

      expect(all.map((e) => e.amountMl), [500, 100]);
    });

    test('delete delegates verbatim', () async {
      when(ds.deleteById(any)).thenAnswer((_) async => Future.value());
      await repo.delete(7);
      verify(ds.deleteById(7)).called(1);
    });

    test('sumToday calls sumSince with start-of-today (local)', () async {
      when(ds.sumSince(any)).thenAnswer((_) async => 750);

      final result = await repo.sumToday();

      expect(result, 750);
      final captured = verify(ds.sumSince(captureAny)).captured.single
          as DateTime;
      final now = DateTime.now();
      final expectedStart = DateTime(now.year, now.month, now.day);
      expect(captured, expectedStart);
    });
  });
}
```

- [ ] **Step 5: Run the test (expect FAIL — impl missing)**

Run: `fvm flutter test test/features/hydration/data/repositories/hydration_repository_impl_test.dart`
Expected: FAIL with import error.

- [ ] **Step 6: Create the repo impl**

`lib/features/hydration/data/repositories/hydration_repository_impl.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/hydration_entry.dart';
import '../../domain/repositories/hydration_repository.dart';
import '../datasources/hydration_datasource.dart';
import '../mappers/hydration_mappers.dart';

@LazySingleton(as: HydrationRepository)
class HydrationRepositoryImpl implements HydrationRepository {
  HydrationRepositoryImpl(this._ds);

  final HydrationDatasource _ds;

  @override
  Future<HydrationEntry> add(int amountMl) async {
    final now = DateTime.now();
    final id = await _ds.insert(amountMl: amountMl, createdAt: now);
    return HydrationEntry(id: id, amountMl: amountMl, createdAt: now);
  }

  @override
  Future<HydrationEntry> update(HydrationEntry entry) async {
    await _ds.updateById(
      entry.id,
      amountMl: entry.amountMl,
      createdAt: entry.createdAt,
    );
    final row = await _ds.getById(entry.id);
    if (row == null) {
      throw StateError('HydrationEntry ${entry.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<HydrationEntry?> getById(int id) async =>
      (await _ds.getById(id))?.toEntity();

  @override
  Future<List<HydrationEntry>> getAll() async {
    final rows = await _ds.getAllOrderedByCreatedAtDesc();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _ds.deleteById(id);

  @override
  Future<int> sumToday() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _ds.sumSince(startOfToday);
  }
}
```

- [ ] **Step 7: Run codegen + tests**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs && fvm flutter test test/features/hydration/data/repositories/hydration_repository_impl_test.dart`
Expected: 6 repo tests pass.

- [ ] **Step 8: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; full suite green.

- [ ] **Step 9: Commit**

```bash
git add lib/features/hydration/data/ \
        lib/core/di/injection.config.dart \
        test/features/hydration/mocks.dart \
        test/features/hydration/data/repositories/
git commit -m "$(cat <<'EOF'
feat(wail-13): add HydrationRepository impl with sumToday and mock-driven tests

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 15: Migrate WAIL-12 `data/sources/` → `data/datasources/`

**Files:**
- Move: `lib/features/core/data/sources/local_storage_impl.dart` → `lib/features/core/data/datasources/local_storage_impl.dart`
- Move: `lib/features/core/data/sources/secure_storage_impl.dart` → `lib/features/core/data/datasources/secure_storage_impl.dart`
- Modify (regenerated): `lib/core/di/injection.config.dart`
- Modify: `docs/state-management.md` (one path reference)

- [ ] **Step 1: Move the two impl files**

```bash
mkdir -p lib/features/core/data/datasources
git mv lib/features/core/data/sources/local_storage_impl.dart \
       lib/features/core/data/datasources/local_storage_impl.dart
git mv lib/features/core/data/sources/secure_storage_impl.dart \
       lib/features/core/data/datasources/secure_storage_impl.dart
rmdir lib/features/core/data/sources
```

`rmdir` is non-destructive — it fails if the directory is non-empty, which would surface any stray files we didn't migrate.

- [ ] **Step 2: Update the doc reference**

Open `docs/state-management.md`. On line 19 (the "Layers" section), replace the path:

```diff
-- **Datasource** (`lib/features/<name>/data/sources/`) — extends `AppGateway`; ...
+- **Datasource** (`lib/features/<name>/data/datasources/`) — extends `AppGateway`; ...
```

Leave line 34 (`lib/features/core/domain/sources/`) unchanged — `domain/sources/` is not renamed.

- [ ] **Step 3: Regenerate DI config**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: exits 0; `lib/core/di/injection.config.dart` now imports from `package:waily/features/core/data/datasources/local_storage_impl.dart` (and same for secure_storage). The two old paths must NOT appear anywhere in the generated file.

Verify:
```bash
grep -n "data/sources/local_storage\|data/sources/secure_storage" lib/core/di/injection.config.dart
```
Expected: no matches.

- [ ] **Step 4: Verify analyze + full suite**

Run: `fvm flutter analyze && fvm flutter test`
Expected: 0 issues; all tests still pass (this is a pure rename, no behaviour change).

- [ ] **Step 5: Commit**

```bash
git add lib/features/core/data/datasources/ \
        lib/core/di/injection.config.dart \
        docs/state-management.md
# Drift schema lives elsewhere; only stage what we changed:
git status --short  # confirm no stray paths
git commit -m "$(cat <<'EOF'
refactor(wail-13): rename features/core/data/sources/ to data/datasources/

CLAUDE.md "Project Structure" section uses the plural form `data/datasources/`.
This ticket also introduces per-feature `data/datasources/` folders for the
new entities, so unify on the same name.

local_storage_impl.dart and secure_storage_impl.dart are moved verbatim;
no behaviour change. injection.config.dart regenerates with new import
paths. docs/state-management.md updated to match.

domain/sources/ (where the abstract LocalStorage / SecureStorage live)
is intentionally NOT renamed — those are domain interfaces, not data sources,
and CLAUDE.md project structure does not have a domain/datasources/ folder.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 16: Add "Local database" section to `docs/state-management.md`

**Files:**
- Modify: `docs/state-management.md`

- [ ] **Step 1: Append the new section**

Append at the end of `docs/state-management.md`, after the existing "Reference implementation" section:

```markdown

## Local database (Drift)

Structured local data lives in an [`AppDatabase`](../lib/core/database/app_database.dart) defined under `lib/core/database/`.

- Schema lives in `lib/core/database/tables.dart` — one Drift `Table` per entity. `@DataClassName` overrides keep Drift row classes (e.g. `HydrationsData`) distinct from domain entities (e.g. `HydrationEntry`).
- Each entity has a per-feature data layer: `lib/features/<entity>/data/{datasources,repositories,mappers}/`. Datasources extend `AppGateway` and wrap Drift queries in `safeCall`/`voidSafeCall`. Repositories consume datasources, apply mappers, return Freezed entities.
- DI: `AppDatabase` is registered as a `@Singleton` in `lib/core/database/database_module.dart` with a `closeDatabase` dispose hook so `getIt.reset()` cleanly closes the SQLite handle (important for tests).
- Tests: datasource tests run against `AppDatabase(NativeDatabase.memory())` — no platform channels, fast, isolated. Repository tests stub the datasource via mockito.
- Codegen: `drift_dev` plugs into the existing `build_runner` pipeline. `app_database.g.dart` is generated alongside the source and gitignored (`*.g.dart` rule).

Migration strategy is intentionally not in place yet — the schema is at `version 1` and a real change to a table will own the first migration.
```

- [ ] **Step 2: Verify the doc renders**

Run: `grep -n "## Local database (Drift)" docs/state-management.md`
Expected: exactly one match.

- [ ] **Step 3: Commit**

```bash
git add docs/state-management.md
git commit -m "$(cat <<'EOF'
docs(wail-13): add Local database (Drift) section to state management guide

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 17: Final verification

**Files:** none (verification only)

- [ ] **Step 1: Clean rebuild of generated files**

Run: `fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs`
Expected: exits 0; all generated files refreshed.

- [ ] **Step 2: Static analysis**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Full test suite**

Run: `fvm flutter test`
Expected: every test passes. New tests added by this ticket:
- `app_database_test.dart` (1)
- `user_datasource_impl_test.dart` (7)
- `user_repository_impl_test.dart` (6)
- `workout_datasource_impl_test.dart` (5)
- `workout_repository_impl_test.dart` (5)
- `meal_datasource_impl_test.dart` (6)
- `meal_repository_impl_test.dart` (5)
- `hydration_datasource_impl_test.dart` (7)
- `hydration_repository_impl_test.dart` (6)

= 48 new tests on top of the existing baseline (count baseline once before starting, expect baseline + 48 after).

- [ ] **Step 4: AC verification matrix**

| AC | Manual check |
|----|--------------|
| Local DB configured | `grep "@DriftDatabase" lib/core/database/app_database.dart` matches; `app_database_test` passes |
| Schema for 4 entities | `grep -lE "class (Users\|Workouts\|Meals\|Hydrations) extends Table" lib/core/database/tables.dart` finds the file; `app_database_test` confirms `sqlite_master` reports all four |
| Repository pattern | All 4 features have `domain/repositories/<entity>_repository.dart` (interface) and `data/repositories/<entity>_repository_impl.dart` (impl); `injection.config.dart` registers all 8 (4 datasources + 4 repositories) |
| CRUD works | All 4 datasource tests + all 4 repository tests pass |
| SharedPreferences | `lib/features/core/data/datasources/local_storage_impl.dart` exists; the equivalent path under `data/sources/` is gone |

- [ ] **Step 5: Branch state**

Run: `git status && git log --oneline develop..HEAD`
Expected: clean working tree; commits land sequentially per task.

If everything passes, WAIL-13 is implementation-complete and ready for `/improvs:review` → `/improvs:finish`.
