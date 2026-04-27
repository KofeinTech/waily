import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_cubit.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_state.dart';

import '../../mocks.mocks.dart';

void main() {
  group('AppNotificationCubit', () {
    late MockNotificationManager manager;
    late StreamController<AppNotification> controller;

    setUp(() {
      manager = MockNotificationManager();
      controller = StreamController<AppNotification>.broadcast();
      when(manager.notificationStream).thenAnswer((_) => controller.stream);
    });

    tearDown(() async {
      await controller.close();
    });

    test('starts in initial state', () {
      final cubit = AppNotificationCubit(manager);
      expect(cubit.state, const AppNotificationState.initial());
      cubit.close();
    });

    test('emits received() when manager pushes a notification', () async {
      final cubit = AppNotificationCubit(manager);
      final emitted = <AppNotificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      controller.add(const AppNotification.success(message: 'hi'));
      // Let the stream tick.
      await Future<void>.delayed(Duration.zero);

      expect(emitted, const [
        AppNotificationState.received(
          AppNotification.success(message: 'hi'),
        ),
      ]);

      await sub.cancel();
      await cubit.close();
    });
  });
}
