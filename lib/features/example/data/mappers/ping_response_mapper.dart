import '../../domain/entities/ping_status.dart';
import '../models/ping_response.dart';

extension PingResponseMapper on PingResponse {
  PingStatus toEntity() => PingStatus(
        status: status,
        serverTime: DateTime.parse(serverTime),
      );
}
