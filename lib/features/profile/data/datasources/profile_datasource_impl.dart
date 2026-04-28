import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../core/data/gateway/app_gateway.dart';
import 'profile_datasource.dart';

@Injectable(as: ProfileDatasource)
class ProfileDatasourceImpl extends AppGateway implements ProfileDatasource {
  ProfileDatasourceImpl(super.talker, this._db);

  final AppDatabase _db;

  @override
  Future<int> insert({
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  }) =>
      safeCall(() => _db.into(_db.profiles).insert(
            ProfilesCompanion.insert(
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
        await (_db.update(_db.profiles)..where((t) => t.id.equals(id))).write(
          ProfilesCompanion(
            displayName: Value(displayName),
            dateOfBirth: Value(dateOfBirth),
            heightCm: Value(heightCm),
            weightKg: Value(weightKg),
          ),
        );
      });

  @override
  Future<ProfilesData?> getById(int id) => safeCall(
        () => (_db.select(_db.profiles)..where((t) => t.id.equals(id)))
            .getSingleOrNull(),
      );

  @override
  Future<List<ProfilesData>> getAll() => safeCall(
        () => (_db.select(_db.profiles)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get(),
      );

  @override
  Future<void> deleteById(int id) => voidSafeCall(() async {
        await (_db.delete(_db.profiles)..where((t) => t.id.equals(id))).go();
      });
}
