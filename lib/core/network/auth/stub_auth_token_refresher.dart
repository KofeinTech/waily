import 'package:injectable/injectable.dart';

import 'auth_token_refresher.dart';

@LazySingleton(as: AuthTokenRefresher)
class StubAuthTokenRefresher implements AuthTokenRefresher {
  @override
  Future<String?> refresh() async => null;
}
