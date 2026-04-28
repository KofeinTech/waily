import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/router/auth_session_gate.dart';

import '../../features/core/mocks.mocks.dart';

void main() {
  group('StubAuthSessionGate', () {
    late MockSecureStorage storage;
    late StubAuthSessionGate gate;

    setUp(() {
      storage = MockSecureStorage();
      gate = StubAuthSessionGate(storage);
    });

    test('is authenticated by default so dev builds reach the shell', () {
      expect(gate.isAuthenticated, isTrue);
    });

    test('refresh() is a no-op and does not notify listeners', () async {
      var notified = 0;
      gate.addListener(() => notified++);

      await gate.refresh();
      await gate.refresh();

      expect(gate.isAuthenticated, isTrue);
      expect(notified, 0);
    });
  });
}
