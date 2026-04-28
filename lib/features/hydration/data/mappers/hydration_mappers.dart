import '../../../../core/database/app_database.dart';
import '../../domain/entities/hydration_entry.dart';

extension HydrationRowMapper on HydrationsData {
  HydrationEntry toEntity() => HydrationEntry(
        id: id,
        amountMl: amountMl,
        createdAt: createdAt,
      );
}
