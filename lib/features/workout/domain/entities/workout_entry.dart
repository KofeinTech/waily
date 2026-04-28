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
