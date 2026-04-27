import '../entities/app_notification.dart';

abstract class NotificationManager {
  Stream<AppNotification> get notificationStream;
  void sendNotification(AppNotification notification);
  void dispose();
}
