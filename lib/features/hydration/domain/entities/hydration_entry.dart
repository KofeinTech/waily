import 'package:freezed_annotation/freezed_annotation.dart';

part 'hydration_entry.freezed.dart';

@freezed
abstract class HydrationEntry with _$HydrationEntry {
  const factory HydrationEntry({
    required int id,
    required int amountMl,
    required DateTime createdAt,
  }) = _HydrationEntry;
}
