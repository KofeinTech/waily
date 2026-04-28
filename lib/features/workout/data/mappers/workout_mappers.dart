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
