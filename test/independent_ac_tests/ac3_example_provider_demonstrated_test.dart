// AC3: Example state provider/notifier is created and demonstrated.
//
// The reference implementation is AppNotificationCubit + TriggerDemoErrorUseCase
// (surfaced from demo_home_screen).  We test the cubit end-to-end:
//
// 1. A notification pushed by the manager produces an observable state change.
// 2. Sending the SAME trigger twice in a row does NOT silently drop the second
//    emission (regression guard against dedup-by-equality bugs).
// 3. An empty message does not crash the pipeline.
// 4. A very long message (> 2 000 chars) does not crash the pipeline.
// 5. Closing the cubit and re-creating it does not throw (lifecycle hygiene).

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/domain/managers/notification_manager.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_cubit.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_state.dart';

class _FakeNotificationManager implements NotificationManager {
  final StreamController<AppNotification> _ctrl =
      StreamController<AppNotification>.broadcast();

  @override
  Stream<AppNotification> get notificationStream => _ctrl.stream;

  @override
  void sendNotification(AppNotification notification) =>
      _ctrl.add(notification);

  void send(AppNotification n) => sendNotification(n);

  @override
  void dispose() => _ctrl.close();

  Future<void> close() => _ctrl.close();
}

void main() {
  group('AC3 — Example provider is created and demonstrated', () {
    test('notification pushed to manager is observable as cubit state change',
        () async {
      final manager = _FakeNotificationManager();
      final cubit = AppNotificationCubit(manager);

      final emitted = <AppNotificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      manager.send(const AppNotification.success(message: 'hello'));
      await Future<void>.delayed(Duration.zero);

      expect(emitted, hasLength(1));
      expect(
        emitted.single,
        isA<AppNotificationReceived>().having(
          (s) => s.notification,
          'notification',
          const AppNotification.success(message: 'hello'),
        ),
      );

      await sub.cancel();
      await cubit.close();
      await manager.close();
    });

    test(
        'sending the same trigger twice produces two distinct emissions '
        '(no silent dedup / equality short-circuit)', () async {
      final manager = _FakeNotificationManager();
      final cubit = AppNotificationCubit(manager);

      final emitted = <AppNotificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      const dup = AppNotification.error(message: 'dup-trigger');
      manager.send(dup);
      await Future<void>.delayed(const Duration(milliseconds: 2));
      manager.send(dup);
      await Future<void>.delayed(const Duration(milliseconds: 2));

      expect(
        emitted,
        hasLength(2),
        reason:
            'Both identical notifications must reach the cubit state; the '
            'second must not be silently dropped',
      );
      // Even though the notification payload is equal, the two state objects
      // must be considered distinct so that BlocListener fires for each.
      expect(
        emitted[0],
        isNot(equals(emitted[1])),
        reason:
            'Each AppNotificationReceived must differ (e.g. by timestamp) so '
            'BlocListener fires twice',
      );

      await sub.cancel();
      await cubit.close();
      await manager.close();
    });

    test('empty message does not crash the pipeline', () async {
      final manager = _FakeNotificationManager();
      final cubit = AppNotificationCubit(manager);

      final emitted = <AppNotificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      expect(
        () {
          manager.send(const AppNotification.error(message: ''));
        },
        returnsNormally,
        reason: 'Sending a notification with empty message must not throw',
      );

      await Future<void>.delayed(Duration.zero);
      expect(
        emitted,
        hasLength(1),
        reason: 'Empty-message notification must still reach the cubit state',
      );

      await sub.cancel();
      await cubit.close();
      await manager.close();
    });

    test('very long message (> 2 000 chars) does not crash the pipeline',
        () async {
      final manager = _FakeNotificationManager();
      final cubit = AppNotificationCubit(manager);

      final emitted = <AppNotificationState>[];
      final sub = cubit.stream.listen(emitted.add);

      final longMessage = 'x' * 2001;

      expect(
        () {
          manager.send(AppNotification.error(message: longMessage));
        },
        returnsNormally,
        reason: 'Very long message must not throw when sent',
      );

      await Future<void>.delayed(Duration.zero);
      expect(
        emitted,
        hasLength(1),
        reason: 'Long-message notification must still reach the cubit state',
      );

      await sub.cancel();
      await cubit.close();
      await manager.close();
    });

    test('closing and re-creating the cubit does not throw (lifecycle hygiene)',
        () async {
      final manager = _FakeNotificationManager();

      final cubitFirst = AppNotificationCubit(manager);
      await cubitFirst.close();

      expect(
        () => AppNotificationCubit(manager),
        returnsNormally,
        reason:
            'A second cubit wired to the same manager must be constructable '
            'after the first is closed',
      );

      await manager.close();
    });
  });
}
