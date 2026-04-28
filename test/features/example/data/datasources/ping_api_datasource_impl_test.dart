import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/network/exceptions/api_exception.dart';
import 'package:waily/features/example/data/datasources/ping_api_datasource_impl.dart';

import '../../mocks.mocks.dart';

void main() {
  late MockApiClient apiClient;
  late MockTalker talker;
  late PingApiDatasourceImpl datasource;

  setUp(() {
    apiClient = MockApiClient();
    talker = MockTalker();
    datasource = PingApiDatasourceImpl(talker, apiClient);
  });

  test('getPing calls ApiClient.get("/ping") and decodes response', () async {
    when(apiClient.get<Map<String, dynamic>>('/ping')).thenAnswer((_) async =>
        Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/ping'),
          statusCode: 200,
          data: const {
            'status': 'ok',
            'server_time': '2026-04-28T10:30:00.000Z',
          },
        ));

    final result = await datasource.getPing();

    expect(result.status, 'ok');
    expect(result.serverTime, '2026-04-28T10:30:00.000Z');
    verify(apiClient.get<Map<String, dynamic>>('/ping')).called(1);
  });

  test('connection error -> NetworkException via safeCall mapping', () async {
    when(apiClient.get<Map<String, dynamic>>('/ping')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/ping'),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(
      () => datasource.getPing(),
      throwsA(isA<NetworkException>()),
    );
  });

  test('500 response -> ServerException with statusCode 500', () async {
    when(apiClient.get<Map<String, dynamic>>('/ping')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/ping'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/ping'),
          statusCode: 500,
        ),
      ),
    );

    expect(
      () => datasource.getPing(),
      throwsA(isA<ServerException>()
          .having((e) => e.statusCode, 'statusCode', 500)),
    );
  });
}
