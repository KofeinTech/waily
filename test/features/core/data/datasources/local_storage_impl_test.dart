import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waily/features/core/data/datasources/local_storage_impl.dart';

/// Verifies AC5 of WAIL-13:
/// "SharedPreferences is configured for simple key-value storage
///  (settings, preferences)".
///
/// Uses the in-memory mock provided by SharedPreferences.setMockInitialValues
/// so this is pure unit-level coverage of the round-trip behaviour.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageImpl', () {
    late LocalStorageImpl storage;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      storage = LocalStorageImpl();
    });

    group('String', () {
      test('writeString persists and readString returns the same value',
          () async {
        await storage.writeString('locale', 'en');
        expect(await storage.readString('locale'), 'en');
      });

      test('readString returns null for a missing key', () async {
        expect(await storage.readString('missing'), isNull);
      });

      test('writeString overwrites a previous value', () async {
        await storage.writeString('locale', 'en');
        await storage.writeString('locale', 'ru');
        expect(await storage.readString('locale'), 'ru');
      });

      test('empty string round-trips as empty string (not null)', () async {
        await storage.writeString('k', '');
        expect(await storage.readString('k'), '');
      });
    });

    group('Bool', () {
      test('writeBool true persists and readBool returns true', () async {
        await storage.writeBool('onboarded', true);
        expect(await storage.readBool('onboarded'), true);
      });

      test('writeBool false persists distinctly from "missing key"', () async {
        await storage.writeBool('onboarded', false);
        expect(await storage.readBool('onboarded'), false);
        expect(await storage.readBool('missing'), isNull);
      });
    });

    group('Int', () {
      test('writeInt persists and readInt returns the same value', () async {
        await storage.writeInt('streak', 42);
        expect(await storage.readInt('streak'), 42);
      });

      test('readInt returns null for a missing key', () async {
        expect(await storage.readInt('missing'), isNull);
      });

      test('zero and negative values round-trip exactly', () async {
        await storage.writeInt('zero', 0);
        await storage.writeInt('neg', -7);
        expect(await storage.readInt('zero'), 0);
        expect(await storage.readInt('neg'), -7);
      });
    });

    group('remove / clear', () {
      test('remove deletes only the given key', () async {
        await storage.writeString('a', '1');
        await storage.writeString('b', '2');

        await storage.remove('a');

        expect(await storage.readString('a'), isNull);
        expect(await storage.readString('b'), '2');
      });

      test('remove on a non-existent key is a no-op (no throw)', () async {
        await storage.remove('nope');
        expect(await storage.readString('nope'), isNull);
      });

      test('clear wipes all keys across all types', () async {
        await storage.writeString('s', 'x');
        await storage.writeBool('b', true);
        await storage.writeInt('i', 9);

        await storage.clear();

        expect(await storage.readString('s'), isNull);
        expect(await storage.readBool('b'), isNull);
        expect(await storage.readInt('i'), isNull);
      });
    });

    test('Lazy SharedPreferences instance is reused across calls', () async {
      // Two consecutive writes succeed and read back -- this would fail if
      // _ensure() weren't memoising the instance correctly under concurrent
      // first-access.
      final f1 = storage.writeString('k1', 'v1');
      final f2 = storage.writeString('k2', 'v2');
      await Future.wait<void>([f1, f2]);
      expect(await storage.readString('k1'), 'v1');
      expect(await storage.readString('k2'), 'v2');
    });
  });
}
