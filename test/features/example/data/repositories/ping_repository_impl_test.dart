import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/example/data/models/ping_response.dart';
import 'package:waily/features/example/data/repositories/ping_repository_impl.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockPingApiDatasource datasource;
  late PingRepositoryImpl repository;

  setUp(() {
    datasource = MockPingApiDatasource();
    repository = PingRepositoryImpl(datasource);
  });

  test('ping returns mapped PingStatus from datasource response', () async {
    when(datasource.getPing()).thenAnswer((_) async => PingResponse(
          status: 'ok',
          serverTime: '2026-04-28T12:00:00.000Z',
        ));

    final result = await repository.ping();

    expect(result.status, 'ok');
    expect(result.serverTime, DateTime.parse('2026-04-28T12:00:00.000Z'));
    verify(datasource.getPing()).called(1);
  });

  test('ping propagates datasource exception', () async {
    when(datasource.getPing()).thenThrow(Exception('boom'));

    expect(() => repository.ping(), throwsA(isA<Exception>()));
  });
}
