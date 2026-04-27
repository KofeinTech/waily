import 'package:injectable/injectable.dart';

import '../entities/app_notification.dart';
import '../entities/notification_exception.dart';
import 'async_use_case.dart';
import 'no_params.dart';

@lazySingleton
class TriggerDemoErrorUseCase extends AsyncUseCase<NoParams, void> {
  TriggerDemoErrorUseCase(super.talker, super.notificationManager);

  @override
  Future<void> onExecute(NoParams params) async {
    throw const NotificationException(
      AppNotification.error(
        title: 'Demo error',
        message: 'This was thrown from a use case',
      ),
    );
  }
}
