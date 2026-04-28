import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../di/injection.dart';
import '../../router/auth_session_gate.dart';
import '../auth/auth_token_refresher.dart';
import '../auth/token_store.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStore, this._refresher, this._sessionGate);

  final TokenStore _tokenStore;
  final AuthTokenRefresher _refresher;
  final AuthSessionGate _sessionGate;

  Completer<String?>? _ongoingRefresh;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _attachToken(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _handleError(err, handler);
  }

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStore.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    if (err.requestOptions.extra['skip_auth_retry'] == true) {
      handler.next(err);
      return;
    }

    final newToken = await _refreshOnce();
    if (newToken == null) {
      await _tokenStore.deleteToken();
      await _sessionGate.refresh();
      handler.next(err);
      return;
    }

    final retry = err.requestOptions.copyWith();
    retry.headers['Authorization'] = 'Bearer $newToken';
    retry.extra['skip_auth_retry'] = true;
    try {
      final response = await getIt<Dio>().fetch<dynamic>(retry);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  Future<String?> _refreshOnce() {
    final existing = _ongoingRefresh;
    if (existing != null) return existing.future;
    final completer = Completer<String?>();
    _ongoingRefresh = completer;
    _doRefresh(completer);
    return completer.future;
  }

  Future<void> _doRefresh(Completer<String?> completer) async {
    try {
      final token = await _refresher.refresh();
      if (token != null) await _tokenStore.setToken(token);
      completer.complete(token);
    } catch (_) {
      completer.complete(null);
    } finally {
      _ongoingRefresh = null;
    }
  }
}
