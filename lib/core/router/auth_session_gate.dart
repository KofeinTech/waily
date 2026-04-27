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
///
/// Defaults to authenticated so the dev build can reach the shell
/// without going through a real sign-in flow. `refresh()` is a no-op —
/// the real `AuthCubit`-backed gate that replaces this binding will
/// re-introduce token reads, sign-out, and refresh-on-change.
@LazySingleton(as: AuthSessionGate)
class StubAuthSessionGate extends ChangeNotifier implements AuthSessionGate {
  StubAuthSessionGate(this._secureStorage);

  // ignore: unused_field
  final SecureStorage _secureStorage;

  @override
  bool get isAuthenticated => true;

  @override
  Future<void> refresh() async {
    // No-op: stub always grants access. The real auth gate will re-read
    // the token here and call notifyListeners() on transitions.
  }
}
