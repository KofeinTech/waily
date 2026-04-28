import 'package:freezed_annotation/freezed_annotation.dart';

part 'ping_status.freezed.dart';

@freezed
abstract class PingStatus with _$PingStatus {
  const factory PingStatus({
    required String status,
    required DateTime serverTime,
  }) = _PingStatus;
}
