import '../../../../core/database/app_database.dart';

abstract class MealDatasource {
  Future<int> insert({
    required String name,
    required int? calories,
    required DateTime eatenAt,
  });

  Future<void> updateById(
    int id, {
    required String name,
    required int? calories,
    required DateTime eatenAt,
  });

  Future<MealsData?> getById(int id);
  Future<List<MealsData>> getAll();
  Future<void> deleteById(int id);
}
