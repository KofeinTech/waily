import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/network/api_client_impl.dart';

import 'mocks.mocks.dart';

void main() {
  late MockDio dio;
  late ApiClientImpl client;

  setUp(() {
    dio = MockDio();
    client = ApiClientImpl(dio);
  });

  test('get delegates to Dio.get with all named arguments', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/x'),
      data: {'k': 'v'},
    );
    when(dio.get<Map<String, dynamic>>(
      '/x',
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) async => response);

    final cancel = CancelToken();
    final result = await client.get<Map<String, dynamic>>(
      '/x',
      queryParameters: const {'a': 1},
      options: Options(headers: const {'X': '1'}),
      cancelToken: cancel,
    );

    expect(result, same(response));
    verify(dio.get<Map<String, dynamic>>(
      '/x',
      queryParameters: const {'a': 1},
      options: argThat(
        isA<Options>().having((o) => o.headers?['X'], 'headers[X]', '1'),
        named: 'options',
      ),
      cancelToken: cancel,
    )).called(1);
  });

  test('post delegates to Dio.post with data + named args', () async {
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: '/p'),
      data: 'ok',
    );
    when(dio.post<dynamic>(
      '/p',
      data: anyNamed('data'),
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) async => response);

    await client.post<dynamic>('/p', data: const {'b': 2});

    verify(dio.post<dynamic>(
      '/p',
      data: const {'b': 2},
      queryParameters: null,
      options: null,
      cancelToken: null,
    )).called(1);
  });

  test('put delegates to Dio.put', () async {
    final response = Response<void>(requestOptions: RequestOptions(path: '/u'));
    when(dio.put<void>(any,
            data: anyNamed('data'),
            queryParameters: anyNamed('queryParameters'),
            options: anyNamed('options'),
            cancelToken: anyNamed('cancelToken')))
        .thenAnswer((_) async => response);

    await client.put<void>('/u', data: const {'c': 3});

    verify(dio.put<void>('/u',
            data: const {'c': 3},
            queryParameters: null,
            options: null,
            cancelToken: null))
        .called(1);
  });

  test('patch delegates to Dio.patch', () async {
    final response = Response<void>(requestOptions: RequestOptions(path: '/h'));
    when(dio.patch<void>(any,
            data: anyNamed('data'),
            queryParameters: anyNamed('queryParameters'),
            options: anyNamed('options'),
            cancelToken: anyNamed('cancelToken')))
        .thenAnswer((_) async => response);

    await client.patch<void>('/h', data: const {'d': 4});

    verify(dio.patch<void>('/h',
            data: const {'d': 4},
            queryParameters: null,
            options: null,
            cancelToken: null))
        .called(1);
  });

  test('delete delegates to Dio.delete', () async {
    final response = Response<void>(requestOptions: RequestOptions(path: '/d'));
    when(dio.delete<void>(any,
            data: anyNamed('data'),
            queryParameters: anyNamed('queryParameters'),
            options: anyNamed('options'),
            cancelToken: anyNamed('cancelToken')))
        .thenAnswer((_) async => response);

    await client.delete<void>('/d');

    verify(dio.delete<void>('/d',
            data: null,
            queryParameters: null,
            options: null,
            cancelToken: null))
        .called(1);
  });
}
