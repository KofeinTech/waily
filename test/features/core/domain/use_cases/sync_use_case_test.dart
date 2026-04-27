import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/domain/entities/notification_exception.dart';
import 'package:waily/features/core/domain/use_cases/sync_use_case.dart';

import '../../mocks.mocks.dart';

class _SyncSuccess extends SyncUseCase<int, int> {
  _SyncSuccess(super.talker, super.notificationManager);

  @override
  int onExecute(int params) => params + 1;
}

class _SyncNotificationFailing extends SyncUseCase<void, void> {
  _SyncNotificationFailing(super.talker, super.notificationManager);

  @override
  void onExecute(void params) {
    throw const NotificationException(AppNotification.warning(message: 'warn'));
  }
}

void main() {
  late MockTalker talker;
  late MockNotificationManager manager;

  setUp(() {
    talker = MockTalker();
    manager = MockNotificationManager();
  });

  test('success path returns Right(value)', () {
    final result = _SyncSuccess(talker, manager).call(1);
    expect(result, equals(const Right<Exception, int>(2)));
  });

  test('NotificationException forwards to manager and returns Left', () {
    final result = _SyncNotificationFailing(talker, manager).call(null);
    expect(result.isLeft(), isTrue);
    verify(manager.sendNotification(
      const AppNotification.warning(message: 'warn'),
    )).called(1);
  });
}
