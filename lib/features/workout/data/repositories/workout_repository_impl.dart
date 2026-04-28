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
