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
