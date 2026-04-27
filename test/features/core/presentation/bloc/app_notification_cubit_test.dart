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

      expect(emitted, hasLength(1));
      expect(
        emitted.single,
        isA<AppNotificationReceived>().having(
          (s) => s.notification,
          'notification',
          const AppNotification.success(message: 'hi'),
        ),
      );

      await sub.cancel();
      await cubit.close();
    });

    test('emits twice on duplicate notifications (no equality dedup)',
        () async {
      final cubit = AppNotificationCubit(manager);
      final emitted = <AppNotificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      const dup = AppNotification.success(message: 'dup');
      controller.add(dup);
      // A tiny real-time delay between adds ensures DateTime.now() advances
      // between the two emit() calls inside the cubit; without it, the two
      // timestamps could collide on systems with coarse clock resolution.
      await Future<void>.delayed(const Duration(milliseconds: 1));
      controller.add(dup);
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(emitted, hasLength(2));
      expect(emitted.every((s) => s is AppNotificationReceived), isTrue);
      // The two received states must be distinct (different emittedAt) so
      // BlocListener fires for each.
      expect(emitted[0], isNot(equals(emitted[1])));

      await sub.cancel();
      await cubit.close();
    });
  });
}
