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
