import 'package:freezed_annotation/freezed_annotation.dart';

part 'ping_response.freezed.dart';
part 'ping_response.g.dart';

@freezed
abstract class PingResponse with _$PingResponse {
  const factory PingResponse({
    required String status,
    @JsonKey(name: 'server_time') required String serverTime,
  }) = _PingResponse;

  factory PingResponse.fromJson(Map<String, dynamic> json) =>
      _$PingResponseFromJson(json);
}
