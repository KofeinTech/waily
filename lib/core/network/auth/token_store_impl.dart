import 'package:injectable/injectable.dart';

import '../../../features/core/data/datasources/secure_storage.dart';
import 'token_store.dart';

/// SecureStorage key under which the access token lives.
///
/// Shared between [TokenStoreImpl] (writes/reads) and the future real
/// `AuthSessionGate` implementation (reads on app start to compute
/// `isAuthenticated`).
const String authTokenStorageKey = 'auth_token';

@LazySingleton(as: TokenStore)
class TokenStoreImpl implements TokenStore {
  TokenStoreImpl(this._secureStorage);

  final SecureStorage _secureStorage;

  @override
  Future<String?> getToken() => _secureStorage.read(authTokenStorageKey);

  @override
  Future<void> setToken(String token) =>
      _secureStorage.write(authTokenStorageKey, token);

  @override
  Future<void> deleteToken() => _secureStorage.delete(authTokenStorageKey);
}
