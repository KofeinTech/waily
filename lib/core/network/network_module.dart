import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../env/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AuthInterceptor auth, LoggingInterceptor logging) {
    final dio = Dio(
      BaseOptions(
        baseUrl: kEnv.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.addAll([auth, logging]);
    return dio;
  }
}
