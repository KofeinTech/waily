abstract class AuthTokenRefresher {
  /// Returns the new access token, or null if refresh failed or is unsupported.
  Future<String?> refresh();
}
