import 'package:injectable/injectable.dart';

import '../../domain/entities/meal_entry.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_datasource.dart';
import '../mappers/meal_mappers.dart';

@LazySingleton(as: MealRepository)
class MealRepositoryImpl implements MealRepository {
  MealRepositoryImpl(this._ds);

  final MealDatasource _ds;

  @override
  Future<MealEntry> add({
    required String name,
    int? calories,
    required DateTime eatenAt,
  }) async {
    final id = await _ds.insert(
      name: name, calories: calories, eatenAt: eatenAt,
    );
    return MealEntry(
      id: id, name: name, calories: calories, eatenAt: eatenAt,
    );
  }

  @override
  Future<MealEntry> update(MealEntry entry) async {
    await _ds.updateById(
      entry.id,
      name: entry.name,
      calories: entry.calories,
      eatenAt: entry.eatenAt,
    );
    final row = await _ds.getById(entry.id);
    if (row == null) {
      throw StateError('MealEntry ${entry.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<MealEntry?> getById(int id) async =>
      (await _ds.getById(id))?.toEntity();

  @override
  Future<List<MealEntry>> getAll() async {
    final rows = await _ds.getAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _ds.deleteById(id);
}
