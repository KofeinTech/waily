import '../../../../core/database/app_database.dart';
import '../../domain/entities/user.dart';

extension UserRowMapper on UsersData {
  User toEntity() => User(
        id: id,
        displayName: displayName,
        dateOfBirth: dateOfBirth,
        heightCm: heightCm,
        weightKg: weightKg,
      );
}
