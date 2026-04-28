import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/env/env.dart';
import 'package:waily/core/network/interceptors/logging_interceptor.dart';

import '../mocks.mocks.dart';

void main() {
  setUp(resetEnvForTesting);
  tearDown(resetEnvForTesting);

  Future<void> loadEnv({required bool enableLogging}) async {
    dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.test
ENABLE_LOGGING=$enableLogging
''');
  }

  test('onRequest logs via Talker.debug when ENABLE_LOGGING=true', () async {
    await loadEnv(enableLogging: true);
    final talker = MockTalker();
    final interceptor = LoggingInterceptor(talker);
    final handler = MockRequestInterceptorHandler();
    final options = RequestOptions(
      path: '/x',
      method: 'GET',
      headers: const {'Authorization': 'Bearer secret', 'X': '1'},
    );

    interceptor.onRequest(options, handler);

    final captured = verify(talker.debug(captureAny)).captured;
    expect(captured.length, 1);
    final log = captured.first as String;
    expect(log, contains('GET'));
    expect(log, contains('/x'));
    expect(log, contains('***'));
    expect(log, isNot(contains('secret')));
    verify(handler.next(options)).called(1);
  });

  test('onResponse logs via Talker.debug when enabled', () async {
    await loadEnv(enableLogging: true);
    final talker = MockTalker();
    final interceptor = LoggingInterceptor(talker);
    final handler = MockResponseInterceptorHandler();
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: '/y'),
      statusCode: 200,
      data: const {'ok': true},
    );

    interceptor.onResponse(response, handler);

    verify(talker.debug(argThat(contains('200')))).called(1);
    verify(handler.next(response)).called(1);
  });

  test('onError logs via Talker.error when enabled', () async {
    await loadEnv(enableLogging: true);
    final talker = MockTalker();
    final interceptor = LoggingInterceptor(talker);
    final handler = MockErrorInterceptorHandler();
    final err = DioException(
      requestOptions: RequestOptions(path: '/z'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/z'),
        statusCode: 500,
      ),
      message: 'boom',
    );

    interceptor.onError(err, handler);

    verify(talker.error(argThat(contains('500')))).called(1);
    verify(handler.next(err)).called(1);
  });

  test('does not log anything when ENABLE_LOGGING=false', () async {
    await loadEnv(enableLogging: false);
    final talker = MockTalker();
    final interceptor = LoggingInterceptor(talker);
    final reqHandler = MockRequestInterceptorHandler();
    final resHandler = MockResponseInterceptorHandler();
    final errHandler = MockErrorInterceptorHandler();
    final reqOpts = RequestOptions(path: '/q');

    interceptor.onRequest(reqOpts, reqHandler);
    interceptor.onResponse(
      Response<dynamic>(requestOptions: reqOpts, statusCode: 200),
      resHandler,
    );
    interceptor.onError(
      DioException(requestOptions: reqOpts, type: DioExceptionType.unknown),
      errHandler,
    );

    verifyNever(talker.debug(any));
    verifyNever(talker.error(any));
    verify(reqHandler.next(reqOpts)).called(1);
    verify(resHandler.next(argThat(isA<Response>()))).called(1);
    verify(errHandler.next(argThat(isA<DioException>()))).called(1);
  });
}
