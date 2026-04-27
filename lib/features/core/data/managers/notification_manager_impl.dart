import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/managers/notification_manager.dart';

@Singleton(as: NotificationManager)
class NotificationManagerImpl implements NotificationManager {
  NotificationManagerImpl();

  final StreamController<AppNotification> _controller =
      StreamController<AppNotification>.broadcast();

  @override
  Stream<AppNotification> get notificationStream => _controller.stream;

  @override
  void sendNotification(AppNotification notification) {
    _controller.add(notification);
  }

  @override
  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
