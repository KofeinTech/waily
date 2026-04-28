import 'package:injectable/injectable.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';
import '../mappers/profile_mappers.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._ds);

  final ProfileDatasource _ds;

  @override
  Future<Profile> add({
    String? displayName,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
  }) async {
    final id = await _ds.insert(
      displayName: displayName,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
    );
    return Profile(
      id: id,
      displayName: displayName,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
    );
  }

  @override
  Future<Profile> update(Profile profile) async {
    await _ds.updateById(
      profile.id,
      displayName: profile.displayName,
      dateOfBirth: profile.dateOfBirth,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
    );
    final row = await _ds.getById(profile.id);
    if (row == null) {
      throw StateError('Profile ${profile.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<Profile?> getById(int id) async => (await _ds.getById(id))?.toEntity();

  @override
  Future<List<Profile>> getAll() async {
    final rows = await _ds.getAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _ds.deleteById(id);
}
