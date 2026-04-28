import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/network/auth/stub_auth_token_refresher.dart';

void main() {
  test('StubAuthTokenRefresher.refresh always returns null', () async {
    final refresher = StubAuthTokenRefresher();
    expect(await refresher.refresh(), isNull);
  });
}
