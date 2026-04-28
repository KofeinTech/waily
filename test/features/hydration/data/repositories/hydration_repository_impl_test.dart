import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/hydration/data/repositories/hydration_repository_impl.dart';
import 'package:waily/features/hydration/domain/entities/hydration_entry.dart';

import '../../mocks.mocks.dart';

void main() {
  group('HydrationRepositoryImpl', () {
    late MockHydrationDatasource ds;
    late HydrationRepositoryImpl repo;

    setUp(() {
      ds = MockHydrationDatasource();
      repo = HydrationRepositoryImpl(ds);
    });

    test('add inserts and returns entity with assigned id and now timestamp',
        () async {
      when(ds.insert(
        amountMl: anyNamed('amountMl'),
        createdAt: anyNamed('createdAt'),
      )).thenAnswer((_) async => 13);

      final before = DateTime.now();
      final entry = await repo.add(250);
      final after = DateTime.now();

      expect(entry.id, 13);
      expect(entry.amountMl, 250);
      expect(entry.createdAt.isBefore(before.subtract(const Duration(seconds: 1))),
          isFalse);
      expect(entry.createdAt.isAfter(after.add(const Duration(seconds: 1))),
          isFalse);
      verify(ds.insert(
        amountMl: 250,
        createdAt: argThat(isA<DateTime>(), named: 'createdAt'),
      )).called(1);
    });

    test('update writes and re-reads', () async {
      const targetId = 5;
      final ts = DateTime(2026, 4, 27, 9, 0);
      final updated = HydrationEntry(
        id: targetId, amountMl: 333, createdAt: ts,
      );
      when(ds.updateById(any,
        amountMl: anyNamed('amountMl'),
        createdAt: anyNamed('createdAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(targetId)).thenAnswer((_) async => HydrationsData(
            id: targetId, amountMl: 333, createdAt: ts,
          ));

      final result = await repo.update(updated);

      expect(result, equals(updated));
    });

    test('update throws StateError if datasource returns null afterwards',
        () async {
      when(ds.updateById(any,
        amountMl: anyNamed('amountMl'),
        createdAt: anyNamed('createdAt'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(any)).thenAnswer((_) async => null);

      await expectLater(
        () => repo.update(HydrationEntry(
          id: 1, amountMl: 250, createdAt: DateTime(2026, 4, 27),
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('getById maps row to entity', () async {
      final ts = DateTime(2026, 4, 27, 9, 0);
      when(ds.getById(1)).thenAnswer(
        (_) async => HydrationsData(id: 1, amountMl: 250, createdAt: ts),
      );
      when(ds.getById(2)).thenAnswer((_) async => null);

      expect((await repo.getById(1))!.amountMl, 250);
      expect(await repo.getById(2), isNull);
    });

    test('getAll maps rows in datasource-provided order', () async {
      final t1 = DateTime(2026, 4, 27, 18, 0);
      final t2 = DateTime(2026, 4, 27, 8, 0);
      when(ds.getAllOrderedByCreatedAtDesc()).thenAnswer((_) async => [
            HydrationsData(id: 1, amountMl: 500, createdAt: t1),
            HydrationsData(id: 2, amountMl: 100, createdAt: t2),
          ]);

      final all = await repo.getAll();

      expect(all.map((e) => e.amountMl), [500, 100]);
    });

    test('delete delegates verbatim', () async {
      when(ds.deleteById(any)).thenAnswer((_) async => Future.value());
      await repo.delete(7);
      verify(ds.deleteById(7)).called(1);
    });

    test('sumToday calls sumSince with start-of-today (local)', () async {
      when(ds.sumSince(any)).thenAnswer((_) async => 750);

      final result = await repo.sumToday();

      expect(result, 750);
      final captured = verify(ds.sumSince(captureAny)).captured.single
          as DateTime;
      final now = DateTime.now();
      final expectedStart = DateTime(now.year, now.month, now.day);
      expect(captured, expectedStart);
    });
  });
}
