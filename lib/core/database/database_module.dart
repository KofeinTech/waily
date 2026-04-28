import 'package:injectable/injectable.dart';

import 'app_database.dart';

@module
abstract class DatabaseModule {
  @LazySingleton(dispose: closeDatabase)
  AppDatabase appDatabase() => AppDatabase();
}

/// Public top-level so injectable_generator can reference it from the
/// generated config without an extra import.
Future<void> closeDatabase(AppDatabase db) => db.close();
