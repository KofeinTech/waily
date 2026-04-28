import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:waily/core/database/app_database.dart';
import 'package:waily/features/profile/data/datasources/profile_datasource_impl.dart';

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

  group('ProfileDatasourceImpl', () {
    late AppDatabase db;
    late MockTalker talker;
    late ProfileDatasourceImpl ds;

    setUp(() {
      talker = MockTalker();
      db = AppDatabase(NativeDatabase.memory());
      ds = ProfileDatasourceImpl(talker, db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert with all-null optional fields returns assigned id', () async {
      final id = await ds.insert(
        displayName: null,
        dateOfBirth: null,
        heightCm: null,
        weightKg: null,
      );
      expect(id, greaterThan(0));
    });

    test('getById round-trips an inserted row', () async {
      final id = await ds.insert(
        displayName: 'Ana',
        dateOfBirth: DateTime(1990, 1, 1),
        heightCm: 170.5,
        weightKg: 65.0,
      );
      final row = await ds.getById(id);
      expect(row, isNotNull);
      expect(row!.displayName, 'Ana');
      expect(row.dateOfBirth, DateTime(1990, 1, 1));
      expect(row.heightCm, 170.5);
      expect(row.weightKg, 65.0);
    });

    test('getById returns null for non-existent id', () async {
      final row = await ds.getById(999);
      expect(row, isNull);
    });

    test('updateById replaces fields by id', () async {
      final id = await ds.insert(
        displayName: 'A', dateOfBirth: null, heightCm: null, weightKg: null,
      );
      await ds.updateById(
        id,
        displayName: 'B',
        dateOfBirth: DateTime(2000),
        heightCm: 180.0,
        weightKg: null,
      );
      final row = await ds.getById(id);
      expect(row!.displayName, 'B');
      expect(row.dateOfBirth, DateTime(2000));
      expect(row.heightCm, 180.0);
      expect(row.weightKg, isNull);
    });

    test('getAll returns rows in insertion order', () async {
      final id1 = await ds.insert(
        displayName: 'X', dateOfBirth: null, heightCm: null, weightKg: null,
      );
      final id2 = await ds.insert(
        displayName: 'Y', dateOfBirth: null, heightCm: null, weightKg: null,
      );
      final all = await ds.getAll();
      expect(all.map((r) => r.id), [id1, id2]);
    });

    test('deleteById removes the row; subsequent getAll is empty', () async {
      final id = await ds.insert(
        displayName: 'Z', dateOfBirth: null, heightCm: null, weightKg: null,
      );
      await ds.deleteById(id);
      final all = await ds.getAll();
      expect(all, isEmpty);
    });

    test('deleteById on non-existent id is a no-op (no throw)', () async {
      await ds.deleteById(999);
    });
  });
}
