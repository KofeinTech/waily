import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/domain/entities/notification_exception.dart';
import 'package:waily/features/core/domain/use_cases/async_use_case.dart';

import '../../mocks.mocks.dart';

class _SuccessUseCase extends AsyncUseCase<int, int> {
  _SuccessUseCase(super.talker, super.notificationManager);

  @override
  Future<int> onExecute(int params) async => params * 2;
}

class _NotificationFailingUseCase extends AsyncUseCase<void, void> {
  _NotificationFailingUseCase(
    super.talker,
    super.notificationManager, {
    super.isSilent = false,
  });

  @override
  Future<void> onExecute(void params) async {
    throw const NotificationException(AppNotification.error(message: 'boom'));
  }
}

class _PlainFailingUseCase extends AsyncUseCase<void, void> {
  _PlainFailingUseCase(super.talker, super.notificationManager);

  @override
  Future<void> onExecute(void params) async {
    throw Exception('plain');
  }
}

void main() {
  late MockTalker talker;
  late MockNotificationManager manager;

  setUp(() {
    talker = MockTalker();
    manager = MockNotificationManager();
  });

  test('success path returns Right(value)', () async {
    final uc = _SuccessUseCase(talker, manager);
    final result = await uc.call(21);
    expect(result, equals(const Right<Exception, int>(42)));
    verifyNever(manager.sendNotification(any));
  });

  test('NotificationException returns Left and forwards to manager', () async {
    final uc = _NotificationFailingUseCase(talker, manager);
    final result = await uc.call(null);

    expect(result.isLeft(), isTrue);
    verify(manager.sendNotification(
      const AppNotification.error(message: 'boom'),
    )).called(1);
    verify(talker.handle(any, any, any)).called(1);
  });

  test('isSilent suppresses NotificationManager call', () async {
    final uc = _NotificationFailingUseCase(talker, manager, isSilent: true);
    final result = await uc.call(null);

    expect(result.isLeft(), isTrue);
    verifyNever(manager.sendNotification(any));
  });

  test('plain Exception returns Left and is NOT forwarded to manager', () async {
    final uc = _PlainFailingUseCase(talker, manager);
    final result = await uc.call(null);

    expect(result.isLeft(), isTrue);
    verifyNever(manager.sendNotification(any));
    verify(talker.handle(any, any, any)).called(1);
  });
}
