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
