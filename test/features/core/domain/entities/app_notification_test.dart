import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';

void main() {
  group('AppNotification', () {
    test('success variant carries message and optional title', () {
      const n = AppNotification.success(message: 'ok', title: 'Saved');
      expect(n, isA<AppNotificationSuccess>());
      n.maybeWhen(success: (m, t) {
        expect(m, 'ok');
        expect(t, 'Saved');
      }, orElse: () => fail('expected success'));
    });

    test('error variant carries only message when title omitted', () {
      const n = AppNotification.error(message: 'boom');
      expect(n, isA<AppNotificationError>());
      n.maybeWhen(error: (m, t) {
        expect(m, 'boom');
        expect(t, isNull);
      }, orElse: () => fail('expected error'));
    });

    test('two equal success notifications are equal', () {
      const a = AppNotification.success(message: 'x');
      const b = AppNotification.success(message: 'x');
      expect(a, equals(b));
    });
  });
}
