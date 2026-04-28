import '../entities/user.dart';

abstract class UserRepository {
  Future<User> add({
    String? displayName,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
  });

  /// Replaces all fields by [user.id].
  Future<User> update(User user);

  Future<User?> getById(int id);
  Future<List<User>> getAll();
  Future<void> delete(int id);
}
