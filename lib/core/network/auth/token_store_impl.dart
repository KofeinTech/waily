import 'package:injectable/injectable.dart';

import '../../../features/core/data/datasources/secure_storage.dart';
import 'token_store.dart';

@LazySingleton(as: TokenStore)
class TokenStoreImpl implements TokenStore {
  TokenStoreImpl(this._secureStorage);

  final SecureStorage _secureStorage;

  static const _key = 'auth_token';

  @override
  Future<String?> getToken() => _secureStorage.read(_key);

  @override
  Future<void> setToken(String token) => _secureStorage.write(_key, token);

  @override
  Future<void> deleteToken() => _secureStorage.delete(_key);
}
