import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/meal/data/repositories/meal_repository_impl.dart';
import 'package:waily/features/meal/domain/entities/meal_entry.dart';

import '../../mocks.mocks.dart';

void main() {
  group('MealRepositoryImpl', () {
    late MockMealDatasource ds;
    late MealRepositoryImpl repo;

    setUp(() {
      ds = MockMealDatasource();
      repo = MealRepositoryImpl(ds);
    });

    test('add inserts and returns entity with assigned id', () async {
      final eaten = DateTime(2026, 4, 27, 12, 0);
      when(ds.insert(
        name: anyNamed('name'),
        calories: anyNamed('calories'),
        eatenAt: anyNamed('eatenAt'),
      )).thenAnswer((_) async => 9);

      final entry = await repo.add(
        name: 'Pho', calories: 450, eatenAt: eaten,
      );

      expect(entry.id, 9);
      expect(entry.name, 'Pho');
      expect(entry.calories, 450);
      verify(ds.insert(name: 'Pho', calories: 450, eatenAt: eaten)).called(1);
    });

    test('update writes and re-reads', () async {
      const targetId = 4;
      final eaten = DateTime(2026, 4, 27, 12, 0);
      final updated = MealEntry(
        id: targetId, name: 'Salad', calories: 200, eatenAt: eaten,
      );
      when(ds.updateById(any,
        name: anyNamed('name'),
        calories: anyNamed('calories'),
        eatenAt: anyNamed('eatenAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(targetId)).thenAnswer((_) async => MealsData(
            id: targetId, name: 'Salad', calories: 200, eatenAt: eaten,
          ));

      final result = await repo.update(updated);

      expect(result, equals(updated));
    });

    test('update throws StateError if datasource returns null afterwards',
        () async {
      when(ds.updateById(any,
        name: anyNamed('name'),
        calories: anyNamed('calories'),
        eatenAt: anyNamed('eatenAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(any)).thenAnswer((_) async => null);

      await expectLater(
        () => repo.update(MealEntry(
          id: 1, name: 'X', eatenAt: DateTime(2026, 4, 27),
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('getById maps row to entity', () async {
      final eaten = DateTime(2026, 4, 27, 8, 0);
      when(ds.getById(1)).thenAnswer((_) async => MealsData(
            id: 1, name: 'Toast', calories: 250, eatenAt: eaten,
          ));
      when(ds.getById(2)).thenAnswer((_) async => null);

      expect((await repo.getById(1))!.name, 'Toast');
      expect(await repo.getById(2), isNull);
    });

    test('getAll maps rows in order', () async {
      final t = DateTime(2026, 4, 27, 8, 0);
      when(ds.getAll()).thenAnswer((_) async => [
            MealsData(id: 1, name: 'A', calories: null, eatenAt: t),
            MealsData(id: 2, name: 'B', calories: null, eatenAt: t),
          ]);
      final all = await repo.getAll();
      expect(all.map((m) => m.name), ['A', 'B']);
    });

    test('delete delegates verbatim', () async {
      when(ds.deleteById(any)).thenAnswer((_) async => Future.value());
      await repo.delete(7);
      verify(ds.deleteById(7)).called(1);
    });
  });
}
