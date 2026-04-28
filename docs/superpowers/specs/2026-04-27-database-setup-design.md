# WAIL-13 — Local database and data persistence

**Ticket:** [WAIL-13](https://improvs.atlassian.net/browse/WAIL-13) — Set up local database and data persistence
**Branch:** `WAIL-13-database-setup`
**Status:** Design approved 2026-04-27

## 1. Summary

Configure a local Drift (SQLite) database for the Waily app and ship the production scaffolding for all four core entities — `User`, `WorkoutEntry`, `MealEntry`, `HydrationEntry` — each with a Freezed domain model, an abstract repository interface, a Drift-backed implementation, a row-to-entity mapper, and CRUD tests. AC5 ("SharedPreferences for simple key-value") is already satisfied through WAIL-12's `LocalStorage` abstraction; this ticket completes the missing structured-storage layer next to it.

## 2. Acceptance criteria → deliverables

| AC | How it is satisfied |
|----|---------------------|
| Local database is configured (sqflite/Hive/Isar) | Drift on top of `sqlite3_flutter_libs`. `AppDatabase` boots via `drift_flutter`'s `driftDatabase()` helper into the application documents directory. |
| Schema for core entities (user, workout, meal, hydration) | Four `Table` classes in `lib/core/database/tables.dart`. Initial fields documented below; future fields land via migrations. |
| Data access layer with repository pattern | Per entity: abstract `*Repository` in `domain/repositories/`, abstract `*Datasource` in `data/datasources/`, `*DatasourceImpl extends AppGateway` in `data/datasources/`, `*RepositoryImpl` in `data/repositories/` calling the datasource and applying a Dart-extension mapper. All datasource impls register `@Injectable(as: ...)`; all repository impls register `@LazySingleton(as: ...)`. |
| Basic CRUD operations work for at least one entity | Full `add` / `update` / `getById` / `getAll` / `delete` on all four entities, plus `sumToday` on hydration as a bonus aggregation example. |
| SharedPreferences for simple key-value (settings, prefs) | Already provided by WAIL-12 `LocalStorage` (SharedPreferences-backed). PR description points reviewers to that. |

## 3. Folder structure

```
lib/
  core/
    database/
      app_database.dart            # @DriftDatabase(tables:[Users,Workouts,Meals,Hydrations])
      app_database.g.dart          # GENERATED, gitignored (*.g.dart rule)
      tables.dart                  # 4 Drift Table classes (full initial fields)
      database_module.dart         # @module: AppDatabase singleton + dispose hook
  features/
    user/                                 # NEW feature folder
      domain/
        entities/user.dart                # Freezed User
        repositories/user_repository.dart # abstract
      data/
        datasources/
          user_datasource.dart            # abstract: returns UsersData
          user_datasource_impl.dart       # @Injectable(as: ...) extends AppGateway
        repositories/
          user_repository_impl.dart       # consumes UserDatasource
        mappers/
          user_mappers.dart
    workout/                              # NEW feature folder
      domain/
        entities/workout_entry.dart       # Freezed WorkoutEntry
        repositories/workout_repository.dart
      data/
        datasources/{workout_datasource.dart, workout_datasource_impl.dart}
        repositories/workout_repository_impl.dart
        mappers/workout_mappers.dart
    meal/                                 # NEW feature folder
      domain/
        entities/meal_entry.dart          # Freezed MealEntry
        repositories/meal_repository.dart
      data/
        datasources/{meal_datasource.dart, meal_datasource_impl.dart}
        repositories/meal_repository_impl.dart
        mappers/meal_mappers.dart
    hydration/                            # NEW feature folder
      domain/
        entities/hydration_entry.dart     # Freezed HydrationEntry
        repositories/hydration_repository.dart  # abstract (+ sumToday)
      data/
        datasources/
          hydration_datasource.dart
          hydration_datasource_impl.dart  # +sumSince
        repositories/
          hydration_repository_impl.dart  # +sumToday calls datasource.sumSince(start_of_day)
        mappers/hydration_mappers.dart
    core/                                 # WAIL-12 cross-cutting only
      data/
        datasources/                      # NB: renamed from data/sources/ in this ticket
          local_storage_impl.dart         # MOVED here from data/sources/ (WAIL-12 file)
          secure_storage_impl.dart        # MOVED here from data/sources/ (WAIL-12 file)
        # gateway/, managers/, etc. — unchanged from WAIL-12
      domain/
        # sources/, managers/, entities/, use_cases/ — unchanged from WAIL-12
      presentation/
        # bloc/, widgets/, screens/ — unchanged from WAIL-12

test/
  core/database/
    app_database_test.dart                                    # smoke + 4 tables exist
  features/user/data/datasources/user_datasource_impl_test.dart       # in-memory DB
  features/user/data/repositories/user_repository_impl_test.dart      # mock datasource
  features/workout/data/datasources/workout_datasource_impl_test.dart
  features/workout/data/repositories/workout_repository_impl_test.dart
  features/meal/data/datasources/meal_datasource_impl_test.dart
  features/meal/data/repositories/meal_repository_impl_test.dart
  features/hydration/data/datasources/hydration_datasource_impl_test.dart  # +sumSince
  features/hydration/data/repositories/hydration_repository_impl_test.dart # +sumToday

pubspec.yaml                                                  # +drift, +drift_flutter,
                                                              # +sqlite3_flutter_libs,
                                                              # +path_provider, +drift_dev (dev)
docs/state-management.md                                      # +Local database section
```

## 4. Drift schema (`lib/core/database/tables.dart`)

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
  /// Stored as TEXT now; promoted to a typed enum in a feature ticket via migration.
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

`@DataClassName` keeps Drift row classes (`UsersData`, `WorkoutsData`, ...) distinct from our domain entities (`User`, `WorkoutEntry`, ...). No name collision in either direction.

No indexes, no foreign keys yet — they land with feature tickets that have the actual query shapes. No `@PrimaryKey` overrides — `autoIncrement()` is enough for v1.

## 5. `AppDatabase` and DI module

`lib/core/database/app_database.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Hydrations, Users, Workouts, Meals])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'waily_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // onUpgrade is intentionally absent — schema migrations are out of
        // scope for WAIL-13 and will land per-feature with their own tickets.
      );
}
```

The optional `executor` argument lets tests pass `NativeDatabase.memory()` and skip platform channels.

`lib/core/database/database_module.dart`:

```dart
import 'package:injectable/injectable.dart';

import 'app_database.dart';

@module
abstract class DatabaseModule {
  @Singleton(dispose: closeDatabase)
  AppDatabase appDatabase() => AppDatabase();
}

/// Public top-level so `injectable_generator` can reference it without an
/// extra import in the generated config.
Future<void> closeDatabase(AppDatabase db) => db.close();
```

`@Singleton` (eager, not `@LazySingleton`) — opens the connection at app start, eliminates a first-query race. `dispose: closeDatabase` ensures `getIt.reset()` (tests + warm-shutdown paths) closes the SQLite handle.

## 6. Domain layer (entities + repository contracts)

Each entity lives in its own feature folder under `lib/features/<entity>/domain/`. Following CLAUDE.md's feature-based clean architecture: every domain object that belongs to a future user/workout/meal/hydration feature lives in that feature, not in `lib/features/core/`. (`features/core/` keeps WAIL-12's cross-cutting infrastructure: `NotificationManager`, `AppGateway`, `LocalStorage`, etc.)

Four Freezed entities, one per feature:

- `lib/features/user/domain/entities/user.dart`
- `lib/features/workout/domain/entities/workout_entry.dart`
- `lib/features/meal/domain/entities/meal_entry.dart`
- `lib/features/hydration/domain/entities/hydration_entry.dart`

Bodies:

```dart
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

@freezed
abstract class WorkoutEntry with _$WorkoutEntry {
  const factory WorkoutEntry({
    required int id,
    required String kind,
    required DateTime startedAt,
    DateTime? finishedAt,
  }) = _WorkoutEntry;
}

@freezed
abstract class MealEntry with _$MealEntry {
  const factory MealEntry({
    required int id,
    required String name,
    int? calories,
    required DateTime eatenAt,
  }) = _MealEntry;
}

@freezed
abstract class HydrationEntry with _$HydrationEntry {
  const factory HydrationEntry({
    required int id,
    required int amountMl,
    required DateTime createdAt,
  }) = _HydrationEntry;
}
```

Naming: `User` (profile, singleton-ish) without suffix; the other three carry an `Entry` suffix because they are log-style records (one row per drink/meal/workout occurrence), not the abstract concept.

Four repository interfaces, one per feature folder (`lib/features/<entity>/domain/repositories/`). All share the same shape:

```dart
abstract class UserRepository {
  Future<User> add({String? displayName, DateTime? dateOfBirth,
                    double? heightCm, double? weightKg});
  Future<User> update(User user);          // full replace by user.id
  Future<User?> getById(int id);
  Future<List<User>> getAll();
  Future<void> delete(int id);
}

abstract class WorkoutRepository {
  Future<WorkoutEntry> add({required String kind, required DateTime startedAt,
                             DateTime? finishedAt});
  Future<WorkoutEntry> update(WorkoutEntry entry);
  Future<WorkoutEntry?> getById(int id);
  Future<List<WorkoutEntry>> getAll();
  Future<void> delete(int id);
}

abstract class MealRepository {
  Future<MealEntry> add({required String name, int? calories,
                          required DateTime eatenAt});
  Future<MealEntry> update(MealEntry entry);
  Future<MealEntry?> getById(int id);
  Future<List<MealEntry>> getAll();
  Future<void> delete(int id);
}

abstract class HydrationRepository {
  Future<HydrationEntry> add(int amountMl);
  Future<HydrationEntry> update(HydrationEntry entry);
  Future<HydrationEntry?> getById(int id);
  Future<List<HydrationEntry>> getAll();
  Future<void> delete(int id);

  /// Total ml drunk today (UTC start-of-day). Demonstrates aggregation queries.
  Future<int> sumToday();
}
```

Methods return `Future<...>` (not `Future<Either<Exception, ...>>`). Following the `LoginUseCase` example in CLAUDE.md, repositories may throw and the calling `AsyncUseCase` (in a future feature ticket) wraps the throw into `Either`. Repositories themselves stay close to the data source.

`update` takes a full entity (replace-by-id) rather than a partial map. Simpler contract, no null-as-sentinel ambiguity. Granular partial updates can be added per-feature when a real query justifies them.

## 6.5 Folder rename: `features/core/data/sources/` → `features/core/data/datasources/`

WAIL-12 placed `local_storage_impl.dart` and `secure_storage_impl.dart` under `lib/features/core/data/sources/`. CLAUDE.md's "Project Structure" section uses the plural form `data/datasources/`. To align the project on a single folder name across `features/core/` AND the new feature folders this ticket introduces, this ticket:

1. Renames the directory `lib/features/core/data/sources/` → `lib/features/core/data/datasources/`.
2. Moves `local_storage_impl.dart` and `secure_storage_impl.dart` into the new location.
3. Updates all imports of these two files (every consumer that has `import '../sources/local_storage_impl.dart';` or similar — should be a small handful, mostly within `features/core/`).
4. New feature folders (`features/user/`, `features/workout/`, `features/meal/`, `features/hydration/`) use `data/datasources/` from the start, so no rename needed there.

`domain/sources/` (where the abstract `LocalStorage` and `SecureStorage` live) is **not** renamed — those are cross-cutting infrastructure abstractions, and `domain/datasources/` is not part of CLAUDE.md's project structure.

The DI module / `injection.config.dart` regenerates without manual edits — `injectable_generator` re-scans annotations.

`docs/state-management.md` line 19 references `lib/features/<name>/data/sources/`. Update to `data/datasources/` in the same commit so docs stay in sync with code. Line 34 (`domain/sources/`) is unchanged because `domain/sources/` itself is not renamed.

## 7. Data layer (datasources + repositories + mappers)

Per CLAUDE.md, datasources own raw data access and extend `AppGateway`; repositories orchestrate datasources and convert via mappers. Each entity gets the same four-piece set.

### 7.1 Datasource interfaces

Placed in each feature's `data/datasources/` (e.g. `lib/features/hydration/data/datasources/hydration_datasource.dart`), not `domain/`, because their signatures expose Drift row classes (`HydrationsData`, etc.) and Drift companions — coupling those into `domain/` would violate the "domain is pure Dart" rule.

```dart
// hydration_datasource.dart
abstract class HydrationDatasource {
  Future<int> insert({required int amountMl, required DateTime createdAt});
  Future<void> updateById(int id, {required int amountMl, required DateTime createdAt});
  Future<HydrationsData?> getById(int id);
  Future<List<HydrationsData>> getAllOrderedByCreatedAtDesc();
  Future<void> deleteById(int id);

  /// Returns the SUM of amount_ml for createdAt >= [since].
  Future<int> sumSince(DateTime since);
}

// user_datasource.dart — same shape minus sumSince:
abstract class UserDatasource {
  Future<int> insert({String? displayName, DateTime? dateOfBirth,
                       double? heightCm, double? weightKg});
  Future<void> updateById(int id, {required String? displayName,
                                    required DateTime? dateOfBirth,
                                    required double? heightCm,
                                    required double? weightKg});
  Future<UsersData?> getById(int id);
  Future<List<UsersData>> getAll();
  Future<void> deleteById(int id);
}

// workout_datasource.dart, meal_datasource.dart — same shape, fields per entity
```

`update` parameters are `required T?` (so the caller is forced to pass `null` when they want to clear a field) — full-replace semantics. No partial-update sentinel ambiguity.

### 7.2 Datasource implementations

```dart
@Injectable(as: HydrationDatasource)
class HydrationDatasourceImpl extends AppGateway implements HydrationDatasource {
  HydrationDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({required int amountMl, required DateTime createdAt}) =>
      safeCall(() => _db.into(_db.hydrations).insert(
            HydrationsCompanion.insert(amountMl: amountMl, createdAt: createdAt),
          ));

  @override
  Future<void> updateById(
    int id, {
    required int amountMl,
    required DateTime createdAt,
  }) => voidSafeCall(() async {
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

`safeCall` / `voidSafeCall` route any thrown error (`SqliteException`, `DatabaseException`, etc.) through Talker before rethrowing — unified logging entry point per CLAUDE.md. The `on DioException` branch in `AppGateway` does not fire for DB calls; the bare-`catch` branch catches everything else.

The other three datasources (`User`, `Workout`, `Meal`) follow the exact same shape, swapping table accessor and column set.

### 7.3 Mappers

One extension mapper per feature: `lib/features/<entity>/data/mappers/<entity>_mappers.dart`. Each mapper imports `lib/core/database/app_database.dart` to reference the Drift row class:

```dart
extension HydrationRowMapper on HydrationsData {
  HydrationEntry toEntity() => HydrationEntry(
        id: id, amountMl: amountMl, createdAt: createdAt,
      );
}

extension UserRowMapper on UsersData {
  User toEntity() => User(
        id: id,
        displayName: displayName,
        dateOfBirth: dateOfBirth,
        heightCm: heightCm,
        weightKg: weightKg,
      );
}

// workout / meal mappers in the same shape
```

### 7.4 Repository implementations

Repositories now hold a datasource and a clock-style "now" responsibility. They never see Drift types.

```dart
@LazySingleton(as: HydrationRepository)
class HydrationRepositoryImpl implements HydrationRepository {
  HydrationRepositoryImpl(this._datasource);

  final HydrationDatasource _datasource;

  @override
  Future<HydrationEntry> add(int amountMl) async {
    final now = DateTime.now();
    final id = await _datasource.insert(amountMl: amountMl, createdAt: now);
    return HydrationEntry(id: id, amountMl: amountMl, createdAt: now);
  }

  @override
  Future<HydrationEntry> update(HydrationEntry entry) async {
    await _datasource.updateById(
      entry.id,
      amountMl: entry.amountMl,
      createdAt: entry.createdAt,
    );
    final row = await _datasource.getById(entry.id);
    if (row == null) {
      throw StateError('HydrationEntry ${entry.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<HydrationEntry?> getById(int id) async =>
      (await _datasource.getById(id))?.toEntity();

  @override
  Future<List<HydrationEntry>> getAll() async {
    final rows = await _datasource.getAllOrderedByCreatedAtDesc();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _datasource.deleteById(id);

  @override
  Future<int> sumToday() {
    final startOfToday = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0,
    );
    return _datasource.sumSince(startOfToday);
  }
}
```

`update` does a re-select instead of `RETURNING *` — `RETURNING` requires SQLite ≥ 3.35, which older `sqlite3_flutter_libs` shipped Android versions may not guarantee universally. Two SQL calls keeps the contract portable.

The `StateError` after `update` guards against a logic bug (caller passed an id that doesn't exist), not an external failure. Datasource exceptions are surfaced via `AppGateway.safeCall`'s rethrow.

The other three repositories (`User`, `Workout`, `Meal`) follow the same template — calling their datasource, mapping rows, no Drift dependency.

## 8. Tests

Two-layer testing strategy aligned with the data layer split:

- **Datasource tests** run against a real `AppDatabase(NativeDatabase.memory())`. They exercise actual SQL — that is the value of having datasource impls. Real schema, real queries, no platform channels.
- **Repository tests** stub the datasource via `mockito` and focus on row→entity mapping, orchestration (e.g. `add` synthesizing `now`), and pass-through delegation. Light weight, no DB.
- **AppDatabase smoke test** verifies the schema boots and all four tables exist.

| Test file | Coverage | Approach |
|---|---|---|
| `test/core/database/app_database_test.dart` | `AppDatabase` boots on `NativeDatabase.memory()`; `migration.onCreate` runs without error; SQLite reports four user tables (`users`, `workouts`, `meals`, `hydrations`) via `customSelect("SELECT name FROM sqlite_master WHERE type='table'")`. | in-memory DB |
| `hydration_datasource_impl_test.dart` | `insert` returns id; `getById` round-trips; `getAllOrderedByCreatedAtDesc` orders correctly; `updateById` writes new values; `deleteById` removes row; `sumSince` aggregates only matching rows. | in-memory DB |
| `user_datasource_impl_test.dart` | `insert` with all-null optional fields succeeds; `getById` returns null for non-existent id; `updateById` with mixed null/non-null fields writes correctly; `getAll` returns insertion order; `deleteById` no-throws on non-existent id. | in-memory DB |
| `workout_datasource_impl_test.dart` | Same shape exercising `kind`/`startedAt`/`finishedAt` (incl. transition from null to non-null `finishedAt` via `updateById`). | in-memory DB |
| `meal_datasource_impl_test.dart` | Same shape exercising `name`/`calories`/`eatenAt`. | in-memory DB |
| `hydration_repository_impl_test.dart` | `add` calls `datasource.insert` with current timestamp and returns entity with returned id; `update` calls `updateById` then `getById` and maps the result; `getById(null-row)` returns null; `getAll` maps rows in order; `delete` delegates verbatim; `sumToday` calls `sumSince(start_of_today)`. | mock datasource |
| `user_repository_impl_test.dart` | `add` propagates optional fields; `update` orchestrates write + re-read; mapping verified. | mock datasource |
| `workout_repository_impl_test.dart` | Same shape exercising workout fields. | mock datasource |
| `meal_repository_impl_test.dart` | Same shape exercising meal fields. | mock datasource |

### Datasource fixture pattern (real DB)

```dart
late AppDatabase db;
late HydrationDatasourceImpl datasource;
late MockTalker talker;

setUp(() {
  talker = MockTalker();
  db = AppDatabase(NativeDatabase.memory());
  datasource = HydrationDatasourceImpl(talker, db);
});

tearDown(() async {
  await db.close();
});
```

`MockTalker` comes from `test/features/core/mocks.mocks.dart` (added in WAIL-12). No `notificationManager` is needed for datasources — `AppGateway` only requires Talker.

### Repository fixture pattern (mock datasource)

Add the four datasource interfaces to the existing `test/features/core/mocks.dart` `@GenerateMocks([...])` list so `MockHydrationDatasource` etc. become available.

```dart
late MockHydrationDatasource datasource;
late HydrationRepositoryImpl repo;

setUp(() {
  datasource = MockHydrationDatasource();
  repo = HydrationRepositoryImpl(datasource);
});
```

Tests use mockito's `when(...).thenAnswer(...)` to stage row classes (or `null`) and `verify(...)` to assert the right datasource methods are called with the right arguments.

The two-layer split means a typo in raw SQL is caught by datasource tests; a typo in the row→entity mapping or in repo orchestration is caught by repository tests. Neither layer's failure mode masks the other's.

## 9. pubspec changes

`dependencies:`

```yaml
drift: ^2.21.0
drift_flutter: ^0.2.4
sqlite3_flutter_libs: ^0.5.27
path_provider: ^2.1.5
```

`dev_dependencies:`

```yaml
drift_dev: ^2.21.0
```

Versions are starting points; the implementer pins to the latest stable that resolves against `sdk: ^3.10.7` and Flutter 3.38.6.

`drift_dev` plugs into the existing `build_runner` pipeline. Codegen command unchanged:
```
fvm flutter pub run build_runner build --force-jit --delete-conflicting-outputs
```
`app_database.g.dart` is the only new generator output; it falls under the existing `*.g.dart` gitignore rule.

## 10. Documentation

`docs/state-management.md` — append a "Local database (Drift)" section pointing at `lib/core/database/`, the entity/repository pattern, and the in-memory testing strategy. One short block; no duplication of CLAUDE.md.

No new top-level docs.

## 11. Verification

| AC | Verification step |
|----|-------------------|
| Local database configured | `fvm flutter analyze` exits 0; `fvm flutter test test/core/database/` passes the smoke test |
| Schema for 4 entities | `app_database_test` confirms `sqlite_master` lists all four; the four `*_repository_impl_test.dart` files exist |
| Repository pattern | Each `lib/features/<entity>/data/repositories/<entity>_repository_impl.dart` implements its abstract interface and consumes a `<entity>Datasource`; each `<entity>_datasource_impl.dart` extends `AppGateway` and implements `<entity>Datasource`; `injection.config.dart` registers four `@Injectable(as: *Datasource)` and four `@LazySingleton(as: *Repository)` |
| CRUD works | `fvm flutter test test/features/<entity>/` for each of user/workout/meal/hydration — every datasource SQL suite and every repo orchestration suite passes |
| SharedPreferences | `lib/features/core/data/datasources/local_storage_impl.dart` (moved from `data/sources/` in this ticket) registered as before |

`fvm flutter analyze` and `fvm flutter test` are the gating commands; both must pass before `/improvs:finish`.

## 12. Out of scope

- Encryption at rest. Separate security ticket.
- Migration strategy (`onUpgrade`). `schemaVersion: 1`; the first real schema change owns the first migration.
- Backend sync. Separate ticket.
- Hydration / Meal / Workout / User feature tickets (cubits, screens, use cases). Each owns its own ticket and refines the schema/repo.
- Indexes and foreign-key constraints. Added with the feature ticket whose query shape demands them.
- Platform-channel-backed unit tests for `LocalStorageImpl` / `SecureStorageImpl` (WAIL-12 already deferred these).

## 13. Isolation and clarity

Each new unit reviews independently:

- **`tables.dart`** — pure schema. No imports beyond `drift`. Reviewable as plain SQL DDL.
- **`AppDatabase`** — connects tables to the SQLite executor. Independent of repositories.
- **`DatabaseModule`** — pure DI plumbing. Depends on `AppDatabase` only.
- **Domain entities** — Freezed value objects. No DB knowledge. Each lives in its own feature's `domain/entities/`.
- **Repository interfaces** — depend on entities only. Each lives in its own feature's `domain/repositories/`.
- **Datasource interfaces** — depend on Drift row classes only. Live in each feature's `data/datasources/`, kept out of `domain/`.
- **Datasource impls** — depend on `AppDatabase` + Talker (via `AppGateway`). Reviewable per entity.
- **Mappers** — depend on Drift row class + domain entity. Trivial single-purpose extensions.
- **Repository impls** — depend on a single `*Datasource` and the relevant mapper. No `AppDatabase` import. One repo's bugs do not cascade into others.
- **Tests** — datasource tests own their own `AppDatabase(NativeDatabase.memory())`; repository tests own a `Mock*Datasource`. Neither shares state with another test.

Cross-unit contracts: `AppDatabase` exposes `_db.hydrations` / `_db.users` / etc. accessors used only by datasource impls. Mappers convert one direction (row → entity); the inverse (entity → companion) lives inside datasource impls because the company-shape diverges per entity.

## 14. Open risks

- **`drift_flutter` package version pin.** `drift_flutter` is a thin helper; its API has churned. If `^0.2.4` does not resolve against the chosen `drift ^2.21`, fall back to writing the `LazyDatabase`/`NativeDatabase` boot logic directly in `app_database.dart` (no `drift_flutter` dependency). Decision deferred to implementer.
- **`sqlite3_flutter_libs` Android NDK requirement.** The package ships prebuilt SQLite via Flutter native libraries; Android Gradle Plugin must support it. With `minSdk = 23` (set in WAIL-12) we should be fine, but if the build flags Gradle issues, document them in the PR.
- **`drift_dev` resolves against `analyzer` ≥ 6.** The project already has `analyzer` indirectly via `freezed`/`json_serializable`. If Pub solver complains, the implementer either bumps the analyzer-related dev deps or pins `drift_dev` to a compatible version.
- **`update`'s read-after-write pattern doubles SQL traffic.** Acceptable for the v1 demo of CRUD; if profiling shows it's a hotspot, swap to `RETURNING` once we drop SQLite < 3.35 support.
- **`AppGateway.safeCall` over Drift.** `AppGateway` was designed around `DioException`. Wrapping Drift calls re-uses only the Talker logging branch — fine, but the abstraction now serves two transport categories. If a future ticket adds proper Dio-to-domain mapping, double-check it does not degrade DB error handling.
- **`@GenerateMocks` for four new datasource interfaces.** Adding them to `test/features/core/mocks.dart` triggers a mocks regeneration. Verify `mocks.mocks.dart` rebuilds cleanly under `--force-jit` and that no other generated mocks regress.
