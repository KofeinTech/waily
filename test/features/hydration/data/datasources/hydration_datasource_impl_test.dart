import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/hydration/data/datasources/hydration_datasource_impl.dart';

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

  group('HydrationDatasourceImpl', () {
    late AppDatabase db;
    late MockTalker talker;
    late HydrationDatasourceImpl ds;

    setUp(() {
      talker = MockTalker();
      db = AppDatabase(NativeDatabase.memory());
      ds = HydrationDatasourceImpl(talker, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert returns assigned id', () async {
      final id = await ds.insert(
        amountMl: 250, createdAt: DateTime(2026, 4, 27, 9, 0),
      );
      expect(id, greaterThan(0));
    });

    test('getById round-trips an inserted row', () async {
      final created = DateTime(2026, 4, 27, 10, 0);
      final id = await ds.insert(amountMl: 500, createdAt: created);
      final row = await ds.getById(id);
      expect(row!.amountMl, 500);
      expect(row.createdAt, created);
    });

    test('getAllOrderedByCreatedAtDesc orders most-recent first', () async {
      final earlier = DateTime(2026, 4, 27, 8, 0);
      final later = DateTime(2026, 4, 27, 18, 0);
      await ds.insert(amountMl: 100, createdAt: earlier);
      await ds.insert(amountMl: 200, createdAt: later);

      final all = await ds.getAllOrderedByCreatedAtDesc();

      expect(all.map((r) => r.createdAt), [later, earlier]);
    });

    test('updateById replaces fields by id', () async {
      final created = DateTime(2026, 4, 27, 9, 0);
      final id = await ds.insert(amountMl: 250, createdAt: created);
      final newCreated = DateTime(2026, 4, 27, 10, 0);
      await ds.updateById(id, amountMl: 333, createdAt: newCreated);
      final row = await ds.getById(id);
      expect(row!.amountMl, 333);
      expect(row.createdAt, newCreated);
    });

    test('deleteById removes the row', () async {
      final id = await ds.insert(
        amountMl: 100, createdAt: DateTime(2026, 4, 27, 9, 0),
      );
      await ds.deleteById(id);
      expect(await ds.getById(id), isNull);
    });

    test('sumSince aggregates only rows where createdAt >= since', () async {
      final cutoff = DateTime(2026, 4, 27, 0, 0);
      // Two rows AT/AFTER cutoff:
      await ds.insert(amountMl: 250, createdAt: DateTime(2026, 4, 27, 9, 0));
      await ds.insert(amountMl: 500, createdAt: DateTime(2026, 4, 27, 18, 0));
      // One row BEFORE cutoff:
      await ds.insert(amountMl: 999, createdAt: DateTime(2026, 4, 26, 23, 30));

      final sum = await ds.sumSince(cutoff);

      expect(sum, 750);
    });

    test('sumSince returns 0 when no rows match', () async {
      final cutoff = DateTime(2026, 4, 27, 0, 0);
      await ds.insert(
        amountMl: 100, createdAt: DateTime(2026, 4, 26, 23, 0),
      );
      final sum = await ds.sumSince(cutoff);
      expect(sum, 0);
    });
  });
}
