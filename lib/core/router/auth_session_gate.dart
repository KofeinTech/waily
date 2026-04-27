import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/core/domain/sources/secure_storage.dart';

/// Tracks whether the current user has an active session.
///
/// Plugged into `GoRouter.refreshListenable` so the router re-evaluates
/// its `redirect` whenever the gate state changes. The interface stays
/// stable when the real auth feature lands — only the implementation
/// behind `@LazySingleton(as: AuthSessionGate)` changes.
abstract class AuthSessionGate extends ChangeNotifier {
  bool get isAuthenticated;

  /// Re-reads the underlying source of truth. Idempotent.
  Future<void> refresh();
}

/// Storage key under which the session token lives.
///
/// Top-level constant so the future real auth implementation can write
/// to the same slot.
const String authTokenStorageKey = 'auth_token';

/// Default implementation until the auth feature ships.
@LazySingleton(as: AuthSessionGate)
class StubAuthSessionGate extends ChangeNotifier implements AuthSessionGate {
  StubAuthSessionGate(this._secureStorage);

  final SecureStorage _secureStorage;

  bool _isAuthenticated = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> refresh() async {
    final next = await _readToken();
    if (next != _isAuthenticated) {
      _isAuthenticated = next;
      notifyListeners();
    }
  }

  Future<bool> _readToken() async {
    try {
      final token = await _secureStorage.read(authTokenStorageKey);
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
