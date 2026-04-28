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
