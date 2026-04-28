import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/di/injection.dart';
import 'package:waily/core/network/interceptors/auth_interceptor.dart';

import '../mocks.mocks.dart';

Future<void> _pumpEventQueue() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

DioException _err401({Map<String, dynamic>? extra}) {
  final reqOpts = RequestOptions(
    path: '/x',
    method: 'GET',
    extra: extra ?? <String, dynamic>{},
  );
  return DioException(
    requestOptions: reqOpts,
    type: DioExceptionType.badResponse,
    response: Response<void>(requestOptions: reqOpts, statusCode: 401),
  );
}

void main() {
  late MockTokenStore tokenStore;
  late MockAuthTokenRefresher refresher;
  late MockAuthSessionGate sessionGate;
  late MockDio dio;
  late AuthInterceptor interceptor;

  setUp(() {
    tokenStore = MockTokenStore();
    refresher = MockAuthTokenRefresher();
    sessionGate = MockAuthSessionGate();
    dio = MockDio();
    interceptor = AuthInterceptor(tokenStore, refresher, sessionGate);
    if (!getIt.isRegistered<Dio>()) {
      getIt.registerSingleton<Dio>(dio);
    }
  });

  tearDown(() {
    if (getIt.isRegistered<Dio>()) {
      getIt.unregister<Dio>();
    }
  });

  group('onRequest', () {
    test('attaches Bearer header when TokenStore has a token', () async {
      when(tokenStore.getToken()).thenAnswer((_) async => 'abc');
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/x');

      interceptor.onRequest(options, handler);
      await _pumpEventQueue();

      expect(options.headers['Authorization'], 'Bearer abc');
      verify(handler.next(options)).called(1);
    });

    test('omits Authorization header when token is null', () async {
      when(tokenStore.getToken()).thenAnswer((_) async => null);
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/x');

      interceptor.onRequest(options, handler);
      await _pumpEventQueue();

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(handler.next(options)).called(1);
    });

    test('omits Authorization header when token is empty string', () async {
      when(tokenStore.getToken()).thenAnswer((_) async => '');
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/x');

      interceptor.onRequest(options, handler);
      await _pumpEventQueue();

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('onError', () {
    test('non-401 status passes through unchanged', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 500,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);
      await _pumpEventQueue();

      verify(handler.next(err)).called(1);
      verifyNever(refresher.refresh());
    });

    test('401 with skip_auth_retry passes through', () async {
      final err = _err401(extra: <String, dynamic>{'skip_auth_retry': true});
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);
      await _pumpEventQueue();

      verify(handler.next(err)).called(1);
      verifyNever(refresher.refresh());
    });

    test('401 + refresher returns null -> delete token + session refresh + next(err)',
        () async {
      when(refresher.refresh()).thenAnswer((_) async => null);
      when(tokenStore.deleteToken()).thenAnswer((_) async {});
      when(sessionGate.refresh()).thenAnswer((_) async {});
      final err = _err401();
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);
      await _pumpEventQueue();

      verify(refresher.refresh()).called(1);
      verify(tokenStore.deleteToken()).called(1);
      verify(sessionGate.refresh()).called(1);
      verify(handler.next(err)).called(1);
    });

    test('401 + refresher returns new token -> setToken + retry + resolve',
        () async {
      when(refresher.refresh()).thenAnswer((_) async => 'new_token');
      when(tokenStore.setToken('new_token')).thenAnswer((_) async {});

      final retryResponse = Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 200,
        data: 'ok',
      );
      when(dio.fetch<dynamic>(any)).thenAnswer((_) async => retryResponse);

      final err = _err401();
      final handler = MockErrorInterceptorHandler();

      interceptor.onError(err, handler);
      await _pumpEventQueue();

      verify(refresher.refresh()).called(1);
      verify(tokenStore.setToken('new_token')).called(1);
      verify(handler.resolve(retryResponse)).called(1);

      final captured = verify(dio.fetch<dynamic>(captureAny)).captured;
      final retryOptions = captured.single as RequestOptions;
      expect(retryOptions.headers['Authorization'], 'Bearer new_token');
      expect(retryOptions.extra['skip_auth_retry'], isTrue);
    });

    test('refresh-mutex: concurrent 401s call refresher exactly once',
        () async {
      final completer = Completer<String?>();
      when(refresher.refresh()).thenAnswer((_) => completer.future);
      when(tokenStore.setToken('new_token')).thenAnswer((_) async {});

      final retryResponse = Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 200,
      );
      when(dio.fetch<dynamic>(any)).thenAnswer((_) async => retryResponse);

      final h1 = MockErrorInterceptorHandler();
      final h2 = MockErrorInterceptorHandler();

      interceptor.onError(_err401(), h1);
      interceptor.onError(_err401(), h2);

      // Let both onError calls reach _refreshOnce.
      await _pumpEventQueue();

      // Now release the refresh.
      completer.complete('new_token');
      await _pumpEventQueue();

      verify(refresher.refresh()).called(1);
      verify(dio.fetch<dynamic>(any)).called(2);
      verify(h1.resolve(any)).called(1);
      verify(h2.resolve(any)).called(1);
    });

    test('retry that throws DioException -> handler.next(retryErr)', () async {
      when(refresher.refresh()).thenAnswer((_) async => 'new_token');
      when(tokenStore.setToken('new_token')).thenAnswer((_) async {});
      final retryErr = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 500,
        ),
      );
      when(dio.fetch<dynamic>(any)).thenThrow(retryErr);

      final handler = MockErrorInterceptorHandler();
      interceptor.onError(_err401(), handler);
      await _pumpEventQueue();

      verify(handler.next(retryErr)).called(1);
      verifyNever(handler.resolve(any));
    });
  });
}
