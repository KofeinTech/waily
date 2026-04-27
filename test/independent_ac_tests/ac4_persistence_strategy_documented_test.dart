// AC4: State persistence strategy is documented (for user preferences, auth state).
//
// We verify:
// 1. docs/state-management.md exists.
// 2. It references flutter_secure_storage (or "SecureStorage") for tokens.
// 3. It references SharedPreferences (or "LocalStorage") for preferences.
// 4. It contains an explicit rule against storing tokens in non-secure storage.
// 5. The diff includes both a LocalStorage interface and a SecureStorage
//    interface (checked by filename presence in the git-diff output) — we
//    confirm their file paths exist on disk without reading their contents.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AC4 — Persistence strategy is documented', () {
    late String docContent;

    setUpAll(() {
      final file = File('docs/state-management.md');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'docs/state-management.md must exist',
      );
      docContent = file.readAsStringSync();
    });

    test('doc references flutter_secure_storage or SecureStorage', () {
      final hasSecure = docContent.contains('flutter_secure_storage') ||
          docContent.contains('SecureStorage') ||
          docContent.toLowerCase().contains('secure');

      expect(
        hasSecure,
        isTrue,
        reason:
            'docs/state-management.md must mention secure storage for tokens',
      );
    });

    test('doc references SharedPreferences or LocalStorage', () {
      final hasPrefs = docContent.contains('SharedPreferences') ||
          docContent.contains('LocalStorage') ||
          docContent.contains('shared_preferences');

      expect(
        hasPrefs,
        isTrue,
        reason:
            'docs/state-management.md must mention SharedPreferences / '
            'LocalStorage for non-sensitive preferences',
      );
    });

    test('doc contains explicit rule NOT to store tokens in non-secure storage',
        () {
      // Accept any of the common phrasings.
      final hasRule = docContent.toLowerCase().contains('never store token') ||
          docContent.toLowerCase().contains('do not store token') ||
          docContent.toLowerCase().contains('not store tokens') ||
          (docContent.toLowerCase().contains('token') &&
              docContent.toLowerCase().contains('never') &&
              docContent.toLowerCase().contains('local'));

      expect(
        hasRule,
        isTrue,
        reason:
            'docs/state-management.md must contain an explicit rule that '
            'tokens must not be stored in non-secure (LocalStorage / '
            'SharedPreferences) storage',
      );
    });

    test('LocalStorage interface file exists on disk', () {
      final file = File(
        'lib/features/core/domain/sources/local_storage.dart',
      );
      expect(
        file.existsSync(),
        isTrue,
        reason:
            'A LocalStorage abstraction must exist at '
            'lib/features/core/domain/sources/local_storage.dart',
      );
    });

    test('SecureStorage interface file exists on disk', () {
      final file = File(
        'lib/features/core/domain/sources/secure_storage.dart',
      );
      expect(
        file.existsSync(),
        isTrue,
        reason:
            'A SecureStorage abstraction must exist at '
            'lib/features/core/domain/sources/secure_storage.dart',
      );
    });
  });
}
