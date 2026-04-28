import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/workout/data/datasources/workout_datasource_impl.dart';

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

  group('WorkoutDatasourceImpl', () {
    late AppDatabase db;
    late MockTalker talker;
    late WorkoutDatasourceImpl ds;

    setUp(() {
      talker = MockTalker();
      db = AppDatabase(NativeDatabase.memory());
      ds = WorkoutDatasourceImpl(talker, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert returns assigned id', () async {
      final id = await ds.insert(
        kind: 'cardio',
        startedAt: DateTime(2026, 4, 27, 8, 0),
        finishedAt: null,
      );
      expect(id, greaterThan(0));
    });

    test('getById round-trips an inserted row', () async {
      final start = DateTime(2026, 4, 27, 8, 0);
      final finish = DateTime(2026, 4, 27, 8, 45);
      final id = await ds.insert(
        kind: 'strength', startedAt: start, finishedAt: finish,
      );
      final row = await ds.getById(id);
      expect(row, isNotNull);
      expect(row!.kind, 'strength');
      expect(row.startedAt, start);
      expect(row.finishedAt, finish);
    });

    test('updateById can transition finishedAt from null to non-null',
        () async {
      final start = DateTime(2026, 4, 27, 8, 0);
      final id = await ds.insert(
        kind: 'cardio', startedAt: start, finishedAt: null,
      );
      final finish = DateTime(2026, 4, 27, 8, 30);
      await ds.updateById(
        id, kind: 'cardio', startedAt: start, finishedAt: finish,
      );
      final row = await ds.getById(id);
      expect(row!.finishedAt, finish);
    });

    test('getAll returns rows ordered by id ascending', () async {
      final id1 = await ds.insert(
        kind: 'rest', startedAt: DateTime(2026, 4, 27, 7, 0), finishedAt: null,
      );
      final id2 = await ds.insert(
        kind: 'hybrid', startedAt: DateTime(2026, 4, 27, 18, 0),
        finishedAt: null,
      );
      final all = await ds.getAll();
      expect(all.map((r) => r.id), [id1, id2]);
    });

    test('deleteById removes the row', () async {
      final id = await ds.insert(
        kind: 'cardio',
        startedAt: DateTime(2026, 4, 27, 8, 0),
        finishedAt: null,
      );
      await ds.deleteById(id);
      expect(await ds.getById(id), isNull);
    });
  });
}
