import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/core/network/auth/token_store_impl.dart'
    show TokenStoreImpl, authTokenStorageKey;

import '../../../features/core/mocks.mocks.dart';

void main() {
  late MockSecureStorage secureStorage;
  late TokenStoreImpl tokenStore;

  setUp(() {
    secureStorage = MockSecureStorage();
    tokenStore = TokenStoreImpl(secureStorage);
  });

  test('getToken reads "auth_token" from SecureStorage', () async {
    when(secureStorage.read(authTokenStorageKey)).thenAnswer((_) async => 'abc');

    final result = await tokenStore.getToken();

    expect(result, 'abc');
    verify(secureStorage.read(authTokenStorageKey)).called(1);
  });

  test('getToken returns null when SecureStorage returns null', () async {
    when(secureStorage.read(authTokenStorageKey)).thenAnswer((_) async => null);

    final result = await tokenStore.getToken();

    expect(result, isNull);
  });

  test('setToken writes value under "auth_token" key', () async {
    when(secureStorage.write(authTokenStorageKey, 'xyz'))
        .thenAnswer((_) async {});

    await tokenStore.setToken('xyz');

    verify(secureStorage.write(authTokenStorageKey, 'xyz')).called(1);
  });

  test('deleteToken removes "auth_token"', () async {
    when(secureStorage.delete(authTokenStorageKey)).thenAnswer((_) async {});

    await tokenStore.deleteToken();

    verify(secureStorage.delete(authTokenStorageKey)).called(1);
  });
}
