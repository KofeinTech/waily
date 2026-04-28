import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> add({
    String? displayName,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
  });

  /// Replaces all fields by [profile.id].
  Future<Profile> update(Profile profile);

  Future<Profile?> getById(int id);
  Future<List<Profile>> getAll();
  Future<void> delete(int id);
}
