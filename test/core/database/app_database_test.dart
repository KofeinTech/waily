import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:waily/core/database/app_database.dart';

void main() {
  setUpAll(() {
    // On Linux CI/dev machines the unversioned libsqlite3.so symlink is often
    // absent; fall back to the versioned .so.0 that is always present.
    if (Platform.isLinux) {
      open.overrideFor(OperatingSystem.linux, () {
        for (final path in [
          'libsqlite3.so',
          'libsqlite3.so.0',
        ]) {
          try {
            return DynamicLibrary.open(path);
            // ignore: avoid_catching_errors
          } on ArgumentError catch (_) {}
        }
        throw UnsupportedError('Cannot find libsqlite3 on this system');
      });
    }
  });

  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('boots and creates the four core tables', () async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type='table' AND name NOT LIKE 'sqlite_%'",
          )
          .get();

      final tables = rows.map((r) => r.read<String>('name')).toSet();
      expect(
        tables,
        containsAll(<String>['users', 'workouts', 'meals', 'hydrations']),
      );
    });
  });
}
