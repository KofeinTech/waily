import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../core/domain/entities/app_notification.dart';
import '../../../core/domain/managers/notification_manager.dart';
import '../../../core/domain/use_cases/no_params.dart';
import '../../../core/domain/use_cases/trigger_demo_error_use_case.dart';

/// Internal dev-tools screen. Exercises the notification pipeline
/// end-to-end. Reachable only from `Profile -> Dev tools`.
class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waily — state mgmt demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => getIt<NotificationManager>().sendNotification(
                const AppNotification.success(message: 'Hello from manager'),
              ),
              child: const Text('Show notification (direct)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  getIt<TriggerDemoErrorUseCase>().call(const NoParams()),
              child: const Text('Trigger error via use case'),
            ),
          ],
        ),
      ),
    );
  }
}
