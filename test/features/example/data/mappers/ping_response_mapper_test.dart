import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/example/data/mappers/ping_response_mapper.dart';
import 'package:waily/features/example/data/models/ping_response.dart';

void main() {
  test('toEntity copies status and parses serverTime', () {
    final response = PingResponse(
      status: 'ok',
      serverTime: '2026-04-28T10:30:00.000Z',
    );

    final entity = response.toEntity();

    expect(entity.status, 'ok');
    expect(entity.serverTime, DateTime.parse('2026-04-28T10:30:00.000Z'));
  });

  test('PingResponse.fromJson decodes server_time as snake_case key', () {
    final response = PingResponse.fromJson(const {
      'status': 'ok',
      'server_time': '2026-04-28T11:00:00.000Z',
    });

    expect(response.status, 'ok');
    expect(response.serverTime, '2026-04-28T11:00:00.000Z');
  });
}
