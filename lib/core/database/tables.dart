import 'package:drift/drift.dart';

@DataClassName('UsersData')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().withLength(min: 1, max: 100).nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
}

@DataClassName('WorkoutsData')
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// One of: 'cardio' | 'strength' | 'rest' | 'hybrid'.
  /// Stored as TEXT; promoted to typed enum in a later migration.
  TextColumn get kind => text()();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
}

@DataClassName('MealsData')
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get calories => integer().nullable()();
  DateTimeColumn get eatenAt => dateTime()();
}

@DataClassName('HydrationsData')
class Hydrations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountMl => integer()();
  DateTimeColumn get createdAt => dateTime()();
}
