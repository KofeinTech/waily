import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

import '../../../../core/network/exceptions/api_exception.dart';

abstract class AppGateway {
  AppGateway(this._talker);

  final Talker _talker;

  @protected
  Future<T> safeCall<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on ApiException {
      rethrow;
    } on DioException catch (e, st) {
      _talker.handle(e, st, 'AppGateway DioException');
      throw _mapDioException(e);
    } catch (e, st) {
      _talker.handle(e, st, 'AppGateway error');
      throw UnknownApiException(e.toString());
    }
  }

  @protected
  Future<void> voidSafeCall(Future<void> Function() operation) =>
      safeCall<void>(operation);

  ApiException _mapDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutApiException(),
      DioExceptionType.badResponse => _mapStatus(e),
      DioExceptionType.cancel =>
        const UnknownApiException('Request cancelled'),
      _ => const UnknownApiException(),
    };
  }

  ApiException _mapStatus(DioException e) {
    final code = e.response?.statusCode ?? 0;
    final msg = _extractMessage(e.response?.data);
    return switch (code) {
      401 => UnauthorizedException(msg ?? 'Unauthorized'),
      403 => ForbiddenException(msg ?? 'Forbidden'),
      404 => NotFoundException(msg ?? 'Not found'),
      >= 500 => ServerException(code, msg),
      >= 400 => BadRequestException(code, msg),
      _ => const UnknownApiException(),
    };
  }

  String? _extractMessage(dynamic body) {
    if (body is Map && body['message'] is String) {
      return body['message'] as String;
    }
    return null;
  }
}
