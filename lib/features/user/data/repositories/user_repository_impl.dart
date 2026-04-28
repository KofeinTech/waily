import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_datasource.dart';
import '../mappers/user_mappers.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._ds);

  final UserDatasource _ds;

  @override
  Future<User> add({
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
    return User(
      id: id,
      displayName: displayName,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
    );
  }

  @override
  Future<User> update(User user) async {
    await _ds.updateById(
      user.id,
      displayName: user.displayName,
      dateOfBirth: user.dateOfBirth,
      heightCm: user.heightCm,
      weightKg: user.weightKg,
    );
    final row = await _ds.getById(user.id);
    if (row == null) {
      throw StateError('User ${user.id} disappeared after update');
    }
    return row.toEntity();
  }

  @override
  Future<User?> getById(int id) async => (await _ds.getById(id))?.toEntity();

  @override
  Future<List<User>> getAll() async {
    final rows = await _ds.getAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) => _ds.deleteById(id);
}
