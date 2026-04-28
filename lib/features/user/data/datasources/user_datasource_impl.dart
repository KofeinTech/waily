import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/data/gateway/app_gateway.dart';
import 'user_datasource.dart';

@Injectable(as: UserDatasource)
class UserDatasourceImpl extends AppGateway implements UserDatasource {
  UserDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  }) =>
      safeCall(() => _db.into(_db.users).insert(
            UsersCompanion.insert(
              displayName: Value(displayName),
              dateOfBirth: Value(dateOfBirth),
              heightCm: Value(heightCm),
              weightKg: Value(weightKg),
            ),
          ));

  @override
  Future<void> updateById(
    int id, {
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  }) =>
      voidSafeCall(() async {
        await (_db.update(_db.users)..where((t) => t.id.equals(id))).write(
          UsersCompanion(
            displayName: Value(displayName),
            dateOfBirth: Value(dateOfBirth),
            heightCm: Value(heightCm),
            weightKg: Value(weightKg),
          ),
        );
      });

  @override
  Future<UsersData?> getById(int id) => safeCall(
        () => (_db.select(_db.users)..where((t) => t.id.equals(id)))
            .getSingleOrNull(),
      );

  @override
  Future<List<UsersData>> getAll() =>
      safeCall(() => (_db.select(_db.users)).get());

  @override
  Future<void> deleteById(int id) => voidSafeCall(() async {
        await (_db.delete(_db.users)..where((t) => t.id.equals(id))).go();
      });
}
