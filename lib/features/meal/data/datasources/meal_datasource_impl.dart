import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/data/gateway/app_gateway.dart';
import 'meal_datasource.dart';

@Injectable(as: MealDatasource)
class MealDatasourceImpl extends AppGateway implements MealDatasource {
  MealDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({
    required String name,
    required int? calories,
    required DateTime eatenAt,
  }) =>
      safeCall(() => _db.into(_db.meals).insert(
            MealsCompanion.insert(
              name: name,
              calories: Value(calories),
              eatenAt: eatenAt,
            ),
          ));

  @override
  Future<void> updateById(
    int id, {
    required String name,
    required int? calories,
    required DateTime eatenAt,
  }) =>
      voidSafeCall(() async {
        await (_db.update(_db.meals)..where((t) => t.id.equals(id))).write(
          MealsCompanion(
            name: Value(name),
            calories: Value(calories),
            eatenAt: Value(eatenAt),
          ),
        );
      });

  @override
  Future<MealsData?> getById(int id) => safeCall(
        () => (_db.select(_db.meals)..where((t) => t.id.equals(id)))
            .getSingleOrNull(),
      );

  @override
  Future<List<MealsData>> getAll() => safeCall(
        () => (_db.select(_db.meals)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get(),
      );

  @override
  Future<void> deleteById(int id) => voidSafeCall(() async {
        await (_db.delete(_db.meals)..where((t) => t.id.equals(id))).go();
      });
}
