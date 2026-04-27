import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/domain/entities/notification_exception.dart';

void main() {
  test('NotificationException carries the AppNotification payload', () {
    const notification = AppNotification.error(message: 'boom');
    const exception = NotificationException(notification);

    expect(exception, isA<Exception>());
    expect(exception.notification, equals(notification));
  });
}
