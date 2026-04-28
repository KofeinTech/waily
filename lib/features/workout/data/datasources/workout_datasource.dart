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
