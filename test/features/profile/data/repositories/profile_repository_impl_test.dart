import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:waily/features/profile/domain/entities/profile.dart';

import '../../mocks.mocks.dart';

void main() {
  group('ProfileRepositoryImpl', () {
    late MockProfileDatasource ds;
    late ProfileRepositoryImpl repo;

    setUp(() {
      ds = MockProfileDatasource();
      repo = ProfileRepositoryImpl(ds);
    });

    test('add delegates to insert and returns entity with assigned id', () async {
      when(ds.insert(
        displayName: anyNamed('displayName'),
        dateOfBirth: anyNamed('dateOfBirth'),
        heightCm: anyNamed('heightCm'),
        weightKg: anyNamed('weightKg'),
      )).thenAnswer((_) async => 42);

      final profile = await repo.add(displayName: 'Ana', dateOfBirth: null,
                                  heightCm: 170.0, weightKg: null);

      expect(profile.id, 42);
      expect(profile.displayName, 'Ana');
      expect(profile.heightCm, 170.0);
      verify(ds.insert(
        displayName: 'Ana',
        dateOfBirth: null,
        heightCm: 170.0,
        weightKg: null,
      )).called(1);
    });

    test('update delegates write then re-reads via getById', () async {
      const targetId = 7;
      const updated = Profile(
        id: targetId, displayName: 'B', dateOfBirth: null,
        heightCm: 180.0, weightKg: null,
      );
      when(ds.updateById(any,
        displayName: anyNamed('displayName'),
        dateOfBirth: anyNamed('dateOfBirth'),
        heightCm: anyNamed('heightCm'),
        weightKg: anyNamed('weightKg'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(targetId)).thenAnswer((_) async => ProfilesData(
            id: targetId, displayName: 'B', dateOfBirth: null,
            heightCm: 180.0, weightKg: null,
          ));

      final result = await repo.update(updated);

      expect(result, equals(updated));
      verify(ds.updateById(targetId,
        displayName: 'B', dateOfBirth: null, heightCm: 180.0, weightKg: null,
      )).called(1);
    });

    test('update throws StateError if datasource returns null afterwards',
        () async {
      when(ds.updateById(any,
        displayName: anyNamed('displayName'),
        dateOfBirth: anyNamed('dateOfBirth'),
        heightCm: anyNamed('heightCm'),
        weightKg: anyNamed('weightKg'),
      )).thenAnswer((_) async => Future.value());
      when(ds.getById(any)).thenAnswer((_) async => null);

      await expectLater(
        () => repo.update(const Profile(id: 1)),
        throwsA(isA<StateError>()),
      );
    });

    test('getById maps row to entity; null row → null entity', () async {
      when(ds.getById(1)).thenAnswer((_) async => ProfilesData(
            id: 1, displayName: 'X', dateOfBirth: null,
            heightCm: null, weightKg: null,
          ));
      when(ds.getById(2)).thenAnswer((_) async => null);

      expect((await repo.getById(1))!.displayName, 'X');
      expect(await repo.getById(2), isNull);
    });

    test('getAll maps rows in order', () async {
      when(ds.getAll()).thenAnswer((_) async => [
            ProfilesData(id: 1, displayName: 'A', dateOfBirth: null,
                      heightCm: null, weightKg: null),
            ProfilesData(id: 2, displayName: 'B', dateOfBirth: null,
                      heightCm: null, weightKg: null),
          ]);

      final all = await repo.getAll();

      expect(all.map((u) => u.id), [1, 2]);
      expect(all.map((u) => u.displayName), ['A', 'B']);
    });

    test('delete delegates verbatim', () async {
      when(ds.deleteById(any)).thenAnswer((_) async => Future.value());

      await repo.delete(5);

      verify(ds.deleteById(5)).called(1);
    });
  });
}
