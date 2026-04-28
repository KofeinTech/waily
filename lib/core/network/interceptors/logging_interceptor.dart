import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';

import '../../env/env.dart';

@lazySingleton
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._talker);

  final Talker _talker;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kEnv.enableLogging) {
      _talker.debug(
        '-> ${options.method} ${options.uri}\n'
        'headers: ${_redact(options.headers)}\n'
        'body: ${options.data}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kEnv.enableLogging) {
      _talker.debug(
        '<- ${response.statusCode} ${response.requestOptions.uri}\n'
        'body: ${response.data}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kEnv.enableLogging) {
      _talker.error(
        'xx ${err.requestOptions.method} ${err.requestOptions.uri} '
        '-> ${err.response?.statusCode}\n${err.message}',
      );
    }
    handler.next(err);
  }

  Map<String, dynamic> _redact(Map<String, dynamic> headers) {
    final result = Map<String, dynamic>.from(headers);
    if (result.containsKey('Authorization')) {
      result['Authorization'] = '***';
    }
    return result;
  }
}
