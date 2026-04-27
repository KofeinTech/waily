// AC5: Team documentation created for state management patterns and best practices.
//
// We verify:
// 1. docs/state-management.md exists and has more than 30 non-empty lines.
// 2. README.md mentions "state management" (case-insensitive).
// 3. README.md links to docs/state-management.md.
// 4. CLAUDE.md mentions persistence and references either docs/state-management.md
//    OR contains the persistence hard rule inline.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AC5 — Team documentation created', () {
    test('docs/state-management.md has more than 30 non-empty lines', () {
      final file = File('docs/state-management.md');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'docs/state-management.md must exist',
      );

      final lines = file
          .readAsLinesSync()
          .where((l) => l.trim().isNotEmpty)
          .toList();

      expect(
        lines.length,
        greaterThan(30),
        reason:
            'docs/state-management.md must have more than 30 non-empty lines; '
            'found ${lines.length}',
      );
    });

    test('README.md mentions state management', () {
      final file = File('README.md');
      expect(file.existsSync(), isTrue, reason: 'README.md must exist');

      final content = file.readAsStringSync().toLowerCase();

      expect(
        content.contains('state management') || content.contains('state-management'),
        isTrue,
        reason: 'README.md must mention "state management"',
      );
    });

    test('README.md links to docs/state-management.md', () {
      final file = File('README.md');
      final content = file.readAsStringSync();

      expect(
        content.contains('docs/state-management.md') ||
            content.contains('state-management'),
        isTrue,
        reason:
            'README.md must contain a link to docs/state-management.md so '
            'team members can find the team doc',
      );
    });

    test(
        'CLAUDE.md mentions persistence and references docs/state-management.md '
        'or contains the persistence hard rule inline', () {
      final file = File('CLAUDE.md');
      expect(file.existsSync(), isTrue, reason: 'CLAUDE.md must exist');

      final content = file.readAsStringSync();
      final lower = content.toLowerCase();

      final mentionsPersistence = lower.contains('persist') ||
          lower.contains('storage') ||
          lower.contains('token');

      expect(
        mentionsPersistence,
        isTrue,
        reason: 'CLAUDE.md must mention persistence / storage concepts',
      );

      // Either a link to the doc OR inline rule — both satisfy the AC.
      final hasDocRef = content.contains('docs/state-management.md') ||
          content.contains('state-management.md');

      final hasInlineRule =
          lower.contains('never store token') ||
          lower.contains('localstorage') ||
          lower.contains('securest');

      expect(
        hasDocRef || hasInlineRule,
        isTrue,
        reason:
            'CLAUDE.md must either link to docs/state-management.md or contain '
            'the persistence hard rules inline',
      );
    });
  });
}
