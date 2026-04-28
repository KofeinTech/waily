import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:waily/features/workout/domain/entities/workout_entry.dart';

import '../../mocks.mocks.dart';

void main() {
  group('WorkoutRepositoryImpl', () {
    late MockWorkoutDatasource ds;
    late WorkoutRepositoryImpl repo;

    setUp(() {
      ds = MockWorkoutDatasource();
      repo = WorkoutRepositoryImpl(ds);
    });

    test('add inserts and returns entity with assigned id', () async {
      final start = DateTime(2026, 4, 27, 8, 0);
      when(ds.insert(
        kind: anyNamed('kind'),
        startedAt: anyNamed('startedAt'),
        finishedAt: anyNamed('finishedAt'),
      )).thenAnswer((_) async => 11);

      final entry = await repo.add(kind: 'cardio', startedAt: start);

      expect(entry.id, 11);
      expect(entry.kind, 'cardio');
      expect(entry.startedAt, start);
      expect(entry.finishedAt, isNull);
      verify(ds.insert(kind: 'cardio', startedAt: start, finishedAt: null))
          .called(1);
    });

    test('update writes and re-reads', () async {
      const targetId = 3;
      final start = DateTime(2026, 4, 27, 9, 0);
      final finish = DateTime(2026, 4, 27, 9, 30);
      final updated = WorkoutEntry(
        id: targetId, kind: 'strength', startedAt: start, finishedAt: finish,
      );
      when(ds.updateById(any,
        kind: anyNamed('kind'),
        startedAt: anyNamed('startedAt'),
        finishedAt: anyNamed('finishedAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(targetId)).thenAnswer((_) async => WorkoutsData(
            id: targetId, kind: 'strength', startedAt: start,
            finishedAt: finish,
          ));

      final result = await repo.update(updated);

      expect(result, equals(updated));
    });

    test('update throws StateError if datasource returns null afterwards',
        () async {
      when(ds.updateById(any,
        kind: anyNamed('kind'),
        startedAt: anyNamed('startedAt'),
        finishedAt: anyNamed('finishedAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(any)).thenAnswer((_) async => null);

      await expectLater(
        () => repo.update(WorkoutEntry(
          id: 1, kind: 'cardio', startedAt: DateTime(2026, 4, 27),
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('getById maps row to entity', () async {
      final start = DateTime(2026, 4, 27, 7, 0);
      when(ds.getById(1)).thenAnswer((_) async => WorkoutsData(
            id: 1, kind: 'rest', startedAt: start, finishedAt: null,
          ));
      when(ds.getById(2)).thenAnswer((_) async => null);

      final result = await repo.getById(1);
      expect(result!.kind, 'rest');
      expect(await repo.getById(2), isNull);
    });

    test('getAll maps rows in order', () async {
      final t1 = DateTime(2026, 4, 27, 7, 0);
      final t2 = DateTime(2026, 4, 27, 18, 0);
      when(ds.getAll()).thenAnswer((_) async => [
            WorkoutsData(id: 1, kind: 'cardio', startedAt: t1, finishedAt: null),
            WorkoutsData(id: 2, kind: 'hybrid', startedAt: t2, finishedAt: null),
          ]);

      final all = await repo.getAll();

      expect(all.map((e) => e.kind), ['cardio', 'hybrid']);
    });

    test('delete delegates verbatim', () async {
      when(ds.deleteById(any)).thenAnswer((_) async => Future.value());
      await repo.delete(7);
      verify(ds.deleteById(7)).called(1);
    });
  });
}
