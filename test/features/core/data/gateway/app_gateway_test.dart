import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker/talker.dart';
import 'package:waily/core/network/exceptions/api_exception.dart';
import 'package:waily/features/core/data/gateway/app_gateway.dart';

class _TestGateway extends AppGateway {
  _TestGateway(super.talker);
  Future<T> run<T>(Future<T> Function() op) => safeCall<T>(op);
  Future<void> runVoid(Future<void> Function() op) => voidSafeCall(op);
}

DioException _dio(DioExceptionType type, {int? status, dynamic body}) {
  final reqOpts = RequestOptions(path: '/x');
  return DioException(
    requestOptions: reqOpts,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: reqOpts, statusCode: status, data: body),
  );
}

void main() {
  late _TestGateway gateway;
  late Talker talker;

  setUp(() {
    talker = Talker();
    gateway = _TestGateway(talker);
  });

  group('safeCall maps DioException', () {
    test('connectionError -> NetworkException', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.connectionError)),
        throwsA(isA<NetworkException>()),
      );
    });

    test('connectionTimeout -> TimeoutApiException', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.connectionTimeout)),
        throwsA(isA<TimeoutApiException>()),
      );
    });

    test('sendTimeout -> TimeoutApiException', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.sendTimeout)),
        throwsA(isA<TimeoutApiException>()),
      );
    });

    test('receiveTimeout -> TimeoutApiException', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.receiveTimeout)),
        throwsA(isA<TimeoutApiException>()),
      );
    });

    test('badResponse 401 -> UnauthorizedException', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.badResponse, status: 401)),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('badResponse 403 -> ForbiddenException', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.badResponse, status: 403)),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('badResponse 404 -> NotFoundException', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.badResponse, status: 404)),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('badResponse 422 -> BadRequestException(422)', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.badResponse, status: 422)),
        throwsA(isA<BadRequestException>()
            .having((e) => e.statusCode, 'statusCode', 422)),
      );
    });

    test('badResponse 500 -> ServerException(500)', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.badResponse, status: 500)),
        throwsA(isA<ServerException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('badResponse with body.message uses body message', () async {
      await expectLater(
        gateway.run(() async => throw _dio(
              DioExceptionType.badResponse,
              status: 400,
              body: {'message': 'invalid email'},
            )),
        throwsA(isA<BadRequestException>()
            .having((e) => e.message, 'message', 'invalid email')),
      );
    });

    test('cancel -> UnknownApiException("Request cancelled")', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.cancel)),
        throwsA(isA<UnknownApiException>()
            .having((e) => e.message, 'message', 'Request cancelled')),
      );
    });

    test('unknown -> UnknownApiException', () async {
      await expectLater(
        gateway.run(() async => throw _dio(DioExceptionType.unknown)),
        throwsA(isA<UnknownApiException>()),
      );
    });
  });

  test('non-Dio Exception is rethrown unchanged', () async {
    const original = FormatException('bad json');
    await expectLater(
      gateway.run(() async => throw original),
      throwsA(same(original)),
    );
  });

  test('badCertificate -> UnknownApiException("Invalid or untrusted certificate")', () async {
    await expectLater(
      gateway.run(() async => throw _dio(DioExceptionType.badCertificate)),
      throwsA(isA<UnknownApiException>()
          .having((e) => e.message, 'message', 'Invalid or untrusted certificate')),
    );
  });

  test('pre-existing ApiException is rethrown unchanged', () async {
    const original = NotFoundException('cached');
    await expectLater(
      gateway.run<void>(() async => throw original),
      throwsA(same(original)),
    );
  });

  test('voidSafeCall delegates to safeCall', () async {
    await expectLater(
      gateway.runVoid(() async => throw _dio(DioExceptionType.connectionError)),
      throwsA(isA<NetworkException>()),
    );
  });
}
