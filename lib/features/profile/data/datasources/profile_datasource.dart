import '../../../../core/database/app_database.dart';

abstract class ProfileDatasource {
  Future<int> insert({
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  });

  Future<void> updateById(
    int id, {
    required String? displayName,
    required DateTime? dateOfBirth,
    required double? heightCm,
    required double? weightKg,
  });

  Future<ProfilesData?> getById(int id);
  Future<List<ProfilesData>> getAll();
  Future<void> deleteById(int id);
}
