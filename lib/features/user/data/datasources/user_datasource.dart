import '../../../../core/database/app_database.dart';

abstract class UserDatasource {
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

  Future<UsersData?> getById(int id);
  Future<List<UsersData>> getAll();
  Future<void> deleteById(int id);
}
