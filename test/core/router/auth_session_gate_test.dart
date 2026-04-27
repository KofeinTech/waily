import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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

    test('isAuthenticated is false before refresh', () {
      expect(gate.isAuthenticated, isFalse);
    });

    test('refresh() flips to true when storage holds a non-empty token', () async {
      when(storage.read('auth_token')).thenAnswer((_) async => 'jwt-value');

      var notified = 0;
      gate.addListener(() => notified++);

      await gate.refresh();

      expect(gate.isAuthenticated, isTrue);
      expect(notified, 1);
    });

    test('refresh() stays false on null token and does not notify', () async {
      when(storage.read('auth_token')).thenAnswer((_) async => null);

      var notified = 0;
      gate.addListener(() => notified++);

      await gate.refresh();

      expect(gate.isAuthenticated, isFalse);
      expect(notified, 0);
    });

    test('refresh() stays false on empty string token', () async {
      when(storage.read('auth_token')).thenAnswer((_) async => '');

      await gate.refresh();

      expect(gate.isAuthenticated, isFalse);
    });

    test('refresh() does not notify when state is unchanged', () async {
      when(storage.read('auth_token')).thenAnswer((_) async => 'jwt');
      await gate.refresh();

      var notified = 0;
      gate.addListener(() => notified++);

      await gate.refresh();

      expect(notified, 0);
    });

    test('refresh() swallows storage errors and treats user as unauthenticated', () async {
      when(storage.read('auth_token')).thenThrow(Exception('keychain miss'));

      await gate.refresh();

      expect(gate.isAuthenticated, isFalse);
    });
  });
}
