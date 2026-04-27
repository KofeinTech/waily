import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/core/data/managers/notification_manager_impl.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';

void main() {
  group('NotificationManagerImpl', () {
    test('sendNotification emits the notification on the stream', () async {
      final manager = NotificationManagerImpl();
      const notification = AppNotification.success(message: 'hi');

      final future = expectLater(
        manager.notificationStream,
        emits(notification),
      );

      manager.sendNotification(notification);

      await future;
      manager.dispose();
    });

    test('multiple subscribers receive the same event (broadcast)', () async {
      final manager = NotificationManagerImpl();
      const notification = AppNotification.error(message: 'boom');

      final a = expectLater(manager.notificationStream, emits(notification));
      final b = expectLater(manager.notificationStream, emits(notification));

      manager.sendNotification(notification);

      await Future.wait([a, b]);
      manager.dispose();
    });
  });
}
