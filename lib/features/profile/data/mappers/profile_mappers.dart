import '../../../../core/database/app_database.dart';
import '../../domain/entities/profile.dart';

extension ProfileRowMapper on ProfilesData {
  Profile toEntity() => Profile(
        id: id,
        displayName: displayName,
        dateOfBirth: dateOfBirth,
        heightCm: heightCm,
        weightKg: weightKg,
      );
}
