# WAIL-15 — API client and HTTP service layer

**Status:** Design
**Date:** 2026-04-28
**Author:** Claude (with kolyamriy)
**Jira:** https://improvs.atlassian.net/browse/WAIL-15

## What

Centralized network stack for the Waily mobile app: a thin Dio-wrapping `ApiClient`, two Dio interceptors (auth, logging), a sealed `ApiException` hierarchy, exception mapping centralized in `AppGateway.safeCall`, a stub `AuthTokenRefresher` so 401-refresh-flow infrastructure ships without coupling to the (not-yet-built) auth feature, and a removable example feature (`features/example/`) demonstrating the full datasource → repository → entity slice end-to-end.

## Why

Every future feature talks to the backend the same way: datasource extends `AppGateway`, calls `_apiClient.get/post/...` inside `safeCall`, gets back a typed entity through a mapper. WAIL-15 builds that one-and-only path so the team never has to think about Dio, interceptors, or HTTP error mapping in feature code.

## Acceptance Criteria

1. HTTP client is configured (Dio).
2. Base API service class with common configurations is created.
3. Request/response interceptors are set up for auth tokens and logging.
4. Error handling and exception mapping is implemented.
5. Example API service is created and tested with mock endpoint.

## Scope decisions

The following decisions narrow the scope vs. the original Jira technical notes:

1. **`lib/core/services/` (from ticket Technical Notes) is intentionally NOT used.** The project convention (per CLAUDE.md and existing `features/core/`) is `data/datasources/` + `data/repositories/`. The example service lives as a full feature slice in `features/example/`, not as a free-standing service class.
2. **Retry logic is deferred.** The ticket mentions retry; we ship only Dio's built-in timeouts in WAIL-15. Retry policy depends on the real backend's idempotency contracts and rate-limit behavior, which we don't have yet. A follow-up ticket will add `RetryInterceptor` once we know what to retry.
3. **`connectivity_plus` package is NOT added.** Connectivity is detected reactively via `DioExceptionType.connectionError` → `NetworkException`. Proactive offline detection (banner, queueing) can be added when there's a real UX requirement.
4. **Refresh-flow ships as infrastructure (interceptor + mutex + post-refresh request retry) but with a stub `AuthTokenRefresher` returning `null`.** "Post-refresh request retry" here means re-issuing the original failing request once after a successful token refresh — not the general retry-on-transient-error policy deferred in #2. The auth feature ticket replaces the `@LazySingleton(as: AuthTokenRefresher)` binding with a real implementation; nothing else changes.
5. **`TokenStore` is introduced as a facade over `SecureStorage` for the auth-token slot.** `AuthInterceptor` and the future real `AuthSessionGate` both depend on `TokenStore`, not on `SecureStorage` directly. Other secrets keep using `SecureStorage`.
6. **Bundled refactor: storage datasource abstractions move from `domain/sources/` to `data/datasources/`.** The existing `lib/features/core/domain/sources/local_storage.dart` and `secure_storage.dart` violate the project convention that *all* datasource code (abstract + impl) lives under `data/datasources/`. They were created before the `data/sources/ -> data/datasources/` rename in WAIL-13. Since WAIL-15 introduces a new datasource abstraction (`PingApiDatasource`) and a new layer over `SecureStorage` (`TokenStore`), aligning the existing abstractions in the same change keeps the convention consistent. See "Bundled refactor" below.

## Bundled refactor: storage abstractions move to `data/datasources/`

Move (no logic change):
- `lib/features/core/domain/sources/local_storage.dart` → `lib/features/core/data/datasources/local_storage.dart`
- `lib/features/core/domain/sources/secure_storage.dart` → `lib/features/core/data/datasources/secure_storage.dart`
- Delete the now-empty `lib/features/core/domain/sources/` directory.

Update imports in 5 files:
- `lib/features/core/data/datasources/local_storage_impl.dart`
- `lib/features/core/data/datasources/secure_storage_impl.dart`
- `lib/core/router/auth_session_gate.dart`
- `test/features/core/mocks.dart`
- `test/independent_ac_tests/ac4_persistence_strategy_documented_test.dart` (file-existence assertions, 2 path strings each for LocalStorage/SecureStorage)

Auto-regenerate via `build_runner build --delete-conflicting-outputs`:
- `lib/core/di/injection.config.dart`
- `test/features/core/mocks.mocks.dart`

Documentation updates:
- `docs/state-management.md` line 34: `lib/features/core/domain/sources/` → `lib/features/core/data/datasources/`
- `CLAUDE.md` "Layer responsibilities" → `data/`: change `sources/` to `datasources/` so prose matches the directory tree shown above it (existing inconsistency, fixed in passing).

The refactor does NOT touch `LocalStorage` / `SecureStorage` interfaces themselves, their implementations, or any of their consumers' usage.

## Architecture

### Folder layout

```
lib/core/network/
  api_client.dart                       # abstract ApiClient
  api_client_impl.dart                  # @LazySingleton(as: ApiClient) — thin Dio wrapper
  network_module.dart                   # @module — provides Dio with interceptors
  exceptions/
    api_exception.dart                  # sealed ApiException + variants
  interceptors/
    auth_interceptor.dart               # attaches Bearer + handles 401 refresh-flow
    logging_interceptor.dart            # request/response/error logging via Talker
  auth/
    auth_token_refresher.dart           # abstract AuthTokenRefresher
    stub_auth_token_refresher.dart      # @LazySingleton(as: AuthTokenRefresher) — returns null
    token_store.dart                    # abstract TokenStore (get/set/delete auth token)
    token_store_impl.dart               # @LazySingleton(as: TokenStore) — wraps SecureStorage

lib/features/core/data/gateway/app_gateway.dart   # MODIFIED — DioException -> ApiException mapping

lib/features/example/                             # NEW — demo only, removable in one rm -rf
  domain/
    entities/ping_status.dart                     # Freezed
    repositories/ping_repository.dart             # abstract
  data/
    models/ping_response.dart                     # Freezed + fromJson
    mappers/ping_response_mapper.dart             # extension toEntity()
    datasources/ping_api_datasource.dart          # abstract
    datasources/ping_api_datasource_impl.dart     # extends AppGateway
    repositories/ping_repository_impl.dart        # @LazySingleton(as: PingRepository)
  README.md                                       # "demo only — remove when real features land"

test/core/network/
  api_client_impl_test.dart
  interceptors/auth_interceptor_test.dart
  interceptors/logging_interceptor_test.dart
  mocks.dart + mocks.mocks.dart
test/features/core/data/gateway/app_gateway_test.dart
test/features/example/
  data/datasources/ping_api_datasource_impl_test.dart
  data/repositories/ping_repository_impl_test.dart
  data/mappers/ping_response_mapper_test.dart
  mocks.dart + mocks.mocks.dart
```

### `ApiClient` (abstract)

```dart
abstract class ApiClient {
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<Response<T>> post<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<Response<T>> put<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<Response<T>> patch<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<Response<T>> delete<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
}
```

`ApiClientImpl` is a transparent delegate — no `safeCall` inside (datasources own that). Returns Dio's `Response<T>` so callers can inspect status / headers if needed.

### `NetworkModule`

```dart
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AuthInterceptor auth, LoggingInterceptor logging) {
    final dio = Dio(BaseOptions(
      baseUrl: kEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));
    dio.interceptors.addAll([auth, logging]);
    return dio;
  }
}
```

Order: `auth` first (attaches token on request, handles 401 on error), `logging` second (logs the final request with redacted Authorization, logs response/error). On `onError`, `logging` runs before `auth` so the 401 is logged as it actually came from the wire — before any refresh-retry mutates state.

### `TokenStore`

```dart
abstract class TokenStore {
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> deleteToken();
}

@LazySingleton(as: TokenStore)
class TokenStoreImpl implements TokenStore {
  TokenStoreImpl(this._secureStorage);
  final SecureStorage _secureStorage;
  static const _key = 'auth_token';

  @override Future<String?> getToken() => _secureStorage.read(_key);
  @override Future<void> setToken(String token) => _secureStorage.write(_key, token);
  @override Future<void> deleteToken() => _secureStorage.delete(_key);
}
```

### `AuthTokenRefresher` + stub

```dart
abstract class AuthTokenRefresher {
  /// Returns the new access token, or null if refresh failed/unsupported.
  Future<String?> refresh();
}

@LazySingleton(as: AuthTokenRefresher)
class StubAuthTokenRefresher implements AuthTokenRefresher {
  @override
  Future<String?> refresh() async => null;
}
```

The auth feature ticket replaces the `@LazySingleton(as: AuthTokenRefresher)` binding. The real implementation MUST avoid recursive 401-loops on the refresh request itself — either by setting `extra['skip_auth_retry'] = true` on the refresh `RequestOptions`, or by using a separate Dio instance that does not include `AuthInterceptor`.

### `AuthInterceptor`

```dart
@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStore, this._refresher, this._sessionGate);

  final TokenStore _tokenStore;
  final AuthTokenRefresher _refresher;
  final AuthSessionGate _sessionGate;

  Completer<String?>? _ongoingRefresh; // refresh-mutex

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStore.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);
    if (err.requestOptions.extra['skip_auth_retry'] == true) return handler.next(err);

    final newToken = await _refreshOnce();
    if (newToken == null) {
      await _tokenStore.deleteToken();
      await _sessionGate.refresh();
      return handler.next(err);
    }

    final retry = err.requestOptions.copyWith();
    retry.headers['Authorization'] = 'Bearer $newToken';
    retry.extra['skip_auth_retry'] = true;
    try {
      final response = await getIt<Dio>().fetch(retry);
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
```

**Refresh-mutex:** concurrent 401s converge on the same in-flight `Completer.future`, so `AuthTokenRefresher.refresh()` is invoked at most once per burst.

**Cyclic-dependency break:** `AuthInterceptor` is constructed before `Dio` (Dio depends on it). The retry path resolves `Dio` lazily through `getIt<Dio>()` — at the moment 401 arrives, the graph is fully wired.

**`extra['skip_auth_retry']`:** marker that prevents recursive refresh on the retry attempt itself, and gives the future real `AuthTokenRefresherImpl` a hook to opt its own refresh request out of the interceptor.

### `LoggingInterceptor`

```dart
@injectable
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._talker);
  final Talker _talker;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kEnv.enableLogging) {
      _talker.debug('-> ${options.method} ${options.uri}\nheaders: ${_redact(options.headers)}\nbody: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kEnv.enableLogging) {
      _talker.debug('<- ${response.statusCode} ${response.requestOptions.uri}\nbody: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kEnv.enableLogging) {
      _talker.error('xx ${err.requestOptions.method} ${err.requestOptions.uri} -> ${err.response?.statusCode}\n${err.message}');
    }
    handler.next(err);
  }

  Map<String, dynamic> _redact(Map<String, dynamic> headers) {
    final result = Map<String, dynamic>.from(headers);
    if (result.containsKey('Authorization')) result['Authorization'] = '***';
    return result;
  }
}
```

Gated entirely by `kEnv.enableLogging` (set per environment via `.env`). Authorization header is always redacted in logs.

### `ApiException` (sealed)

```dart
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class NetworkException extends ApiException {
  const NetworkException([String message = 'No internet connection']) : super(message);
}
class TimeoutApiException extends ApiException {
  const TimeoutApiException([String message = 'Request timed out']) : super(message);
}
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Unauthorized']) : super(message, statusCode: 401);
}
class ForbiddenException extends ApiException {
  const ForbiddenException([String message = 'Forbidden']) : super(message, statusCode: 403);
}
class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Not found']) : super(message, statusCode: 404);
}
class BadRequestException extends ApiException {
  const BadRequestException(int statusCode, [String? message])
      : super(message ?? 'Bad request', statusCode: statusCode);
}
class ServerException extends ApiException {
  const ServerException(int statusCode, [String? message])
      : super(message ?? 'Server error', statusCode: statusCode);
}
class UnknownApiException extends ApiException {
  const UnknownApiException([String message = 'Unknown error']) : super(message);
}
```

`sealed` (Dart 3) gives exhaustive `switch` without freezed; `ApiException` must be a real `Exception`, so freezed is the wrong tool here.

### `AppGateway` — exception mapping

```dart
abstract class AppGateway {
  AppGateway(this._talker);
  final Talker _talker;

  @protected
  Future<T> safeCall<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (e, st) {
      _talker.handle(e, st, 'AppGateway DioException');
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
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
      DioExceptionType.receiveTimeout => const TimeoutApiException(),
      DioExceptionType.badResponse => _mapStatus(e),
      DioExceptionType.cancel => const UnknownApiException('Request cancelled'),
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
    if (body is Map && body['message'] is String) return body['message'] as String;
    return null;
  }
}
```

### Example feature (`lib/features/example/`)

Full feature slice exercising the network stack end-to-end. Removable in one `rm -rf` when real features land.

```dart
// domain/entities/ping_status.dart
@freezed
abstract class PingStatus with _$PingStatus {
  const factory PingStatus({required String status, required DateTime serverTime}) = _PingStatus;
}

// domain/repositories/ping_repository.dart
abstract class PingRepository {
  Future<PingStatus> ping();
}

// data/datasources/ping_api_datasource.dart
abstract class PingApiDatasource {
  Future<PingResponse> getPing();
}

// data/models/ping_response.dart
@freezed
abstract class PingResponse with _$PingResponse {
  const factory PingResponse({
    required String status,
    @JsonKey(name: 'server_time') required String serverTime,
  }) = _PingResponse;
  factory PingResponse.fromJson(Map<String, dynamic> json) => _$PingResponseFromJson(json);
}

// data/mappers/ping_response_mapper.dart
extension PingResponseMapper on PingResponse {
  PingStatus toEntity() => PingStatus(status: status, serverTime: DateTime.parse(serverTime));
}

// data/datasources/ping_api_datasource_impl.dart
@Injectable(as: PingApiDatasource)
class PingApiDatasourceImpl extends AppGateway implements PingApiDatasource {
  PingApiDatasourceImpl(super.talker, this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<PingResponse> getPing() => safeCall<PingResponse>(() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/ping');
    return PingResponse.fromJson(response.data!);
  });
}

// data/repositories/ping_repository_impl.dart
@LazySingleton(as: PingRepository)
class PingRepositoryImpl implements PingRepository {
  PingRepositoryImpl(this._datasource);
  final PingApiDatasource _datasource;

  @override
  Future<PingStatus> ping() async => (await _datasource.getPing()).toEntity();
}
```

No use cases, cubits, or screens in `features/example/` — only `data/` + `domain/`. The README in the folder explains: "demo only — delete when real auth/user features land".

## Boot sequence

`main.dart` is unchanged. The DI graph picks up the new bindings on `configureDependencies()`:

```
Talker (singleton, existing)
SecureStorage / LocalStorage (existing)
TokenStore (NEW) -> SecureStorage
AuthTokenRefresher = StubAuthTokenRefresher (NEW)
AuthSessionGate = StubAuthSessionGate (existing)
LoggingInterceptor (NEW) -> Talker
AuthInterceptor (NEW) -> TokenStore, AuthTokenRefresher, AuthSessionGate
Dio (NEW, NetworkModule) -> AuthInterceptor, LoggingInterceptor
ApiClient = ApiClientImpl (NEW) -> Dio
PingApiDatasource = PingApiDatasourceImpl (NEW, example) -> Talker, ApiClient
PingRepository = PingRepositoryImpl (NEW, example) -> PingApiDatasource
```

The existing `await getIt<AuthSessionGate>().refresh()` before `runApp` (WAIL-12/13) still runs — unchanged.

## Data flow

### Successful request

```
Cubit -> UseCase -> Repository -> Datasource (extends AppGateway)
   -> safeCall(() => ApiClient.get(...))
   -> Dio.get -> [AuthInterceptor.onRequest: attach Bearer]
              -> [LoggingInterceptor.onRequest: log redacted]
              -> HTTP 200
              -> [LoggingInterceptor.onResponse: log]
   -> Response<Map<String,dynamic>>
   -> Datasource: PingResponse.fromJson(...)
   -> Repository: response.toEntity()
   -> PingStatus
```

### Error: server 5xx

```
Dio -> 500 -> [LoggingInterceptor.onError]
           -> [AuthInterceptor.onError: status != 401, next(err)]
           -> DioException
   -> AppGateway.safeCall: _mapDioException -> ServerException(500)
   -> Datasource throws ServerException
   -> UseCase wraps in Left(ServerException)
   -> Cubit emits failure state
```

### Error: 401 + successful refresh

```
Dio -> 401 -> [LoggingInterceptor.onError]
           -> [AuthInterceptor.onError]:
                _refreshOnce(): refresher.refresh() -> "new_token"
                                TokenStore.setToken("new_token")
                                completer.complete("new_token")
                retry = err.requestOptions.copyWith()
                retry.headers['Authorization'] = 'Bearer new_token'
                retry.extra['skip_auth_retry'] = true
                getIt<Dio>().fetch(retry) -> 200 -> handler.resolve(response)
   -> ApiClient returns Response (caller never sees the 401)
```

Concurrent 401s during an in-flight refresh wait on the same `Completer.future` and retry once each.

### Error: 401 + failed refresh (current stub)

```
Dio -> 401 -> [AuthInterceptor.onError]:
                _refreshOnce(): StubAuthTokenRefresher.refresh() -> null
                newToken == null
                TokenStore.deleteToken()
                AuthSessionGate.refresh()  // notifyListeners() once real
                handler.next(err)
   -> AppGateway.safeCall: UnauthorizedException
   -> UseCase: Left(UnauthorizedException)
   -> GoRouter recomputes redirect via AuthSessionGate ChangeNotifier
```

### Error: no internet

```
Dio -> SocketException -> DioException(connectionError)
   -> [AuthInterceptor.onError: response==null, next(err)]
   -> AppGateway.safeCall: NetworkException
   -> UseCase: Left(NetworkException)
```

## Error handling

### Layer responsibility

| Layer | Sees | Throws / propagates |
|---|---|---|
| Dio + interceptors | Raw HTTP, `DioException` | `DioException` (interceptors may `handler.resolve()` after a successful 401-retry) |
| `ApiClient` | `DioException` | `DioException` (transparent delegate) |
| `AppGateway.safeCall` | `DioException`, `ApiException`, any `Exception` | Only `ApiException` (single mapping point) |
| Datasource | `ApiException` | `ApiException` |
| Repository | `ApiException` | `ApiException` |
| UseCase | `ApiException`, `NotificationException` | `Either<Exception, R>` |
| Cubit | `Left(Exception)` / `Right(R)` | failure / success state |

### DioException → ApiException mapping

| Source | Maps to |
|---|---|
| `connectionError` | `NetworkException` |
| `connectionTimeout` / `sendTimeout` / `receiveTimeout` | `TimeoutApiException` |
| `badResponse` 401 | `UnauthorizedException` |
| `badResponse` 403 | `ForbiddenException` |
| `badResponse` 404 | `NotFoundException` |
| `badResponse` 400-499 (other) | `BadRequestException(code)` |
| `badResponse` 500-599 | `ServerException(code)` |
| `cancel` | `UnknownApiException('Request cancelled')` |
| Other / unknown | `UnknownApiException` |
| Non-Dio `Exception` inside `safeCall` | `UnknownApiException(e.toString())` |

Response message extraction reads `response.data['message']` if present; otherwise falls back to the default per type.

### What network layer does NOT handle

- **Business errors in 200 OK responses** (e.g. `{"success": false, "error": "..."}`) — datasource decides and throws.
- **JSON parsing errors** — caught by `safeCall` as generic `Exception` → `UnknownApiException`. Adding `ParsingException` is out of scope.
- **Notifications** — network layer never calls `NotificationManager`. UseCases wrap `ApiException` in `NotificationException` if a UX surface is required.

## Testing strategy

Conventions inherited from WAIL-13/14: mockito + `@GenerateMocks`, no `bloc_test`, `@visibleForTesting` reset hooks for singletons, `dotenv.testLoad` + `resetEnvForTesting()` for env-dependent tests.

### Coverage by AC

| AC | Test file(s) |
|---|---|
| AC1 HTTP client configured | `test/core/network/api_client_impl_test.dart` |
| AC2 Base API service class | `test/features/example/data/datasources/ping_api_datasource_impl_test.dart`, `test/features/example/data/repositories/ping_repository_impl_test.dart`, `test/features/example/data/mappers/ping_response_mapper_test.dart` |
| AC3 Interceptors auth & logging | `test/core/network/interceptors/auth_interceptor_test.dart`, `test/core/network/interceptors/logging_interceptor_test.dart` |
| AC4 Error handling & exception mapping | `test/features/core/data/gateway/app_gateway_test.dart` + integration check inside `ping_api_datasource_impl_test.dart` |
| AC5 Example service tested | `ping_api_datasource_impl_test.dart` (full mock-ApiClient → response → entity path) |

### Notable test cases

**`api_client_impl_test.dart`** — verifies each method delegates to `Dio` with the right named args (path, queryParameters, options, cancelToken). Uses `MockDio` from `test/core/network/mocks.dart`.

**`auth_interceptor_test.dart`**
- onRequest with token in `TokenStore` → `Authorization: Bearer <token>` is added
- onRequest without token → no `Authorization` header
- onError, status != 401 → `handler.next(err)`, no refresher call
- onError, 401, `extra['skip_auth_retry'] == true` → `handler.next(err)`, no refresher call
- onError, 401, refresher returns `null` → `TokenStore.deleteToken()`, `AuthSessionGate.refresh()`, `handler.next(err)`
- onError, 401, refresher returns `'new_token'` → `TokenStore.setToken('new_token')`, retry via `getIt<Dio>().fetch`, `handler.resolve(retry response)`
- **Refresh-mutex:** two concurrent 401 onError calls trigger `refresher.refresh()` exactly once (verified via `verify(...).called(1)` after both completers resolve)

**`logging_interceptor_test.dart`**
- `kEnv.enableLogging == true` → `Talker.debug` on request/response, `Talker.error` on error
- `kEnv.enableLogging == false` → no Talker calls
- `Authorization: Bearer secret` → log message contains `'***'`, never the actual token
- Setup uses `dotenv.testLoad` + `resetEnvForTesting()`

**`app_gateway_test.dart`** — table-driven: each `DioException` shape from the mapping table → expected `ApiException` subtype + statusCode. Plus: non-Dio `Exception` → `UnknownApiException`; rethrow of pre-existing `ApiException` without re-wrapping; `Talker.handle` called for each error. Uses a private `_TestGateway` subclass exposing `safeCall` publicly.

**`ping_api_datasource_impl_test.dart`** — happy path (mock `ApiClient.get('/ping')` returns `Response(data: ...)` → `PingResponse` is fromJson'd correctly) plus integration: `MockApiClient.get` throws `DioException(connectionError)` → `getPing()` throws `NetworkException` (proves `safeCall` mapping is wired at the datasource level).

### DI in tests

Tests don't run `configureDependencies()`. For tests that need `getIt<Dio>()` (only `auth_interceptor_test.dart` retry path):
```dart
setUp(() { getIt.registerSingleton<Dio>(mockDio); });
tearDown(() { getIt.reset(); });
```

### Mocks files

```
test/core/network/mocks.dart                   # @GenerateMocks([Dio, ApiClient, TokenStore, AuthTokenRefresher, AuthSessionGate, Talker])
test/features/example/mocks.dart               # @GenerateMocks([ApiClient, PingApiDatasource, Talker])
```

`test/features/core/mocks.dart` exists from WAIL-13; we may add `@GenerateMocks` entries there if `app_gateway_test.dart` needs them, otherwise build a fresh file under `test/features/core/data/gateway/`.

## Files added / modified

**New:**
- `lib/core/network/api_client.dart`
- `lib/core/network/api_client_impl.dart`
- `lib/core/network/network_module.dart`
- `lib/core/network/exceptions/api_exception.dart`
- `lib/core/network/interceptors/auth_interceptor.dart`
- `lib/core/network/interceptors/logging_interceptor.dart`
- `lib/core/network/auth/auth_token_refresher.dart`
- `lib/core/network/auth/stub_auth_token_refresher.dart`
- `lib/core/network/auth/token_store.dart`
- `lib/core/network/auth/token_store_impl.dart`
- `lib/features/example/domain/entities/ping_status.dart`
- `lib/features/example/domain/repositories/ping_repository.dart`
- `lib/features/example/data/models/ping_response.dart`
- `lib/features/example/data/mappers/ping_response_mapper.dart`
- `lib/features/example/data/datasources/ping_api_datasource.dart`
- `lib/features/example/data/datasources/ping_api_datasource_impl.dart`
- `lib/features/example/data/repositories/ping_repository_impl.dart`
- `lib/features/example/README.md`
- `test/core/network/api_client_impl_test.dart`
- `test/core/network/interceptors/auth_interceptor_test.dart`
- `test/core/network/interceptors/logging_interceptor_test.dart`
- `test/core/network/mocks.dart` (+ generated)
- `test/features/core/data/gateway/app_gateway_test.dart`
- `test/features/example/data/datasources/ping_api_datasource_impl_test.dart`
- `test/features/example/data/repositories/ping_repository_impl_test.dart`
- `test/features/example/data/mappers/ping_response_mapper_test.dart`
- `test/features/example/mocks.dart` (+ generated)

**Modified:**
- `lib/features/core/data/gateway/app_gateway.dart` — adds `_mapDioException` + `_mapStatus`, throws `ApiException` from `safeCall`
- `lib/features/core/data/datasources/local_storage_impl.dart` — import path updated for the moved abstract
- `lib/features/core/data/datasources/secure_storage_impl.dart` — import path updated for the moved abstract
- `lib/core/router/auth_session_gate.dart` — import path for `SecureStorage` updated; `authTokenStorageKey` constant stays
- `test/features/core/mocks.dart` — import path updated
- `test/independent_ac_tests/ac4_persistence_strategy_documented_test.dart` — 4 path strings updated to point at `data/datasources/`
- `docs/state-management.md` — one path reference updated
- `CLAUDE.md` — "Layer responsibilities" prose: `data/sources/` → `data/datasources/` (existing inconsistency cleaned up in passing)
- `pubspec.yaml` — no new packages; `dio`, `retrofit`, `json_serializable` already present (Retrofit not used in WAIL-15)

**Moved (no content change):**
- `lib/features/core/domain/sources/local_storage.dart` → `lib/features/core/data/datasources/local_storage.dart`
- `lib/features/core/domain/sources/secure_storage.dart` → `lib/features/core/data/datasources/secure_storage.dart`
- `lib/features/core/domain/sources/` directory removed (now empty)

**Auto-regenerated (build_runner):**
- `lib/core/di/injection.config.dart`
- `test/features/core/mocks.mocks.dart`

**Untouched but worth noting:**
- `lib/main.dart` — boot sequence stays as-is

## Risks

1. **Cyclic dependency between `Dio` and `AuthInterceptor`.** Resolved by lazy `getIt<Dio>()` lookup inside `onError` retry path; in tests, register `MockDio` in `setUp` before invoking `onError`.
2. **Refresh-mutex race in tests.** The two-concurrent-401 test must keep the refresher's `Future` pending until both interceptor calls have entered `_refreshOnce`. We control completion via a `Completer<String?>` returned by `MockAuthTokenRefresher.refresh()`.
3. **Future real `AuthTokenRefresherImpl` causing 401 recursion.** Mitigated by the `extra['skip_auth_retry']` mechanism documented above. Spec for the auth feature ticket must reference this contract.
4. **`@JsonKey(name: 'server_time')` requires `json_serializable` codegen.** Already in `dev_dependencies`; `build_runner build --delete-conflicting-outputs` will be required after implementation.
5. **Talker noise in dev with `ENABLE_LOGGING=true`.** Acceptable for now — Talker has its own filter UI. If verbose, follow-up can add a per-route allowlist.
6. **Bundled refactor regenerates `injection.config.dart` and `mocks.mocks.dart`.** `build_runner build --delete-conflicting-outputs` is required after the move; otherwise the generated files reference deleted import paths and the build fails. The implementation plan must run codegen as a discrete step right after the move and before any compile-dependent assertions.

## Out of scope

- Retry logic (deferred to a follow-up ticket; rationale documented above)
- `connectivity_plus` package and proactive offline detection
- Real auth feature (login, logout, refresh implementation)
- Real backend API endpoints implementation
- GraphQL client setup
- WebSocket / real-time communication
- Retrofit-generated services (Retrofit stays in `pubspec.yaml` but unused; can be re-evaluated when the team has a feature with many endpoints)

## Open questions

None — all open decisions resolved during brainstorming.
