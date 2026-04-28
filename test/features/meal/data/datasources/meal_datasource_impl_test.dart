import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/meal/data/datasources/meal_datasource_impl.dart';

import '../../../core/mocks.mocks.dart';

void main() {
  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(OperatingSystem.linux, () {
        for (final path in ['libsqlite3.so', 'libsqlite3.so.0']) {
          try {
            return DynamicLibrary.open(path);
            // ignore: avoid_catching_errors
          } on ArgumentError catch (_) {}
        }
        throw UnsupportedError('Cannot find libsqlite3 on this system');
      });
    }
  });

  group('MealDatasourceImpl', () {
    late AppDatabase db;
    late MockTalker talker;
    late MealDatasourceImpl ds;

    setUp(() {
      talker = MockTalker();
      db = AppDatabase(NativeDatabase.memory());
      ds = MealDatasourceImpl(talker, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert returns assigned id', () async {
      final id = await ds.insert(
        name: 'Oatmeal',
        calories: 300,
        eatenAt: DateTime(2026, 4, 27, 8, 0),
      );
      expect(id, greaterThan(0));
    });

    test('getById round-trips an inserted row', () async {
      final eaten = DateTime(2026, 4, 27, 12, 30);
      final id = await ds.insert(name: 'Salad', calories: 150, eatenAt: eaten);
      final row = await ds.getById(id);
      expect(row!.name, 'Salad');
      expect(row.calories, 150);
      expect(row.eatenAt, eaten);
    });

    test('insert with null calories succeeds', () async {
      final id = await ds.insert(
        name: 'Apple',
        calories: null,
        eatenAt: DateTime(2026, 4, 27, 10, 0),
      );
      final row = await ds.getById(id);
      expect(row!.calories, isNull);
    });

    test('updateById replaces fields', () async {
      final eaten = DateTime(2026, 4, 27, 12, 0);
      final id = await ds.insert(name: 'Soup', calories: 200, eatenAt: eaten);
      await ds.updateById(id, name: 'Pho', calories: 450, eatenAt: eaten);
      final row = await ds.getById(id);
      expect(row!.name, 'Pho');
      expect(row.calories, 450);
    });

    test('getAll returns rows ordered by id ascending', () async {
      final id1 = await ds.insert(
        name: 'A', calories: null, eatenAt: DateTime(2026, 4, 27, 8, 0),
      );
      final id2 = await ds.insert(
        name: 'B', calories: null, eatenAt: DateTime(2026, 4, 27, 12, 0),
      );
      final all = await ds.getAll();
      expect(all.map((r) => r.id), [id1, id2]);
    });

    test('deleteById removes the row', () async {
      final id = await ds.insert(
        name: 'X', calories: null, eatenAt: DateTime(2026, 4, 27, 8, 0),
      );
      await ds.deleteById(id);
      expect(await ds.getById(id), isNull);
    });
  });
}
