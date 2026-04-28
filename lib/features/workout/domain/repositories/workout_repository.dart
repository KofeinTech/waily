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
