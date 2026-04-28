import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:talker/talker.dart';
import 'package:waily/core/network/api_client.dart';
import 'package:waily/core/network/auth/auth_token_refresher.dart';
import 'package:waily/core/network/auth/token_store.dart';
import 'package:waily/core/router/auth_session_gate.dart';

@GenerateMocks([
  Dio,
  ApiClient,
  TokenStore,
  AuthTokenRefresher,
  AuthSessionGate,
  Talker,
  RequestInterceptorHandler,
  ResponseInterceptorHandler,
  ErrorInterceptorHandler,
])
void main() {}
