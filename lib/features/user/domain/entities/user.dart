import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    String? displayName,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
  }) = _User;
}
