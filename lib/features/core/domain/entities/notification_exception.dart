import 'app_notification.dart';

class NotificationException implements Exception {
  const NotificationException(this.notification);

  final AppNotification notification;
}
