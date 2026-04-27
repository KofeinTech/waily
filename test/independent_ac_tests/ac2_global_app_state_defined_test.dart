// AC2: Global app state structure is defined.
//
// We verify:
// 1. AppNotificationCubit exists and starts in its initial state — this is the
//    app-shell cubit that sits above all routes.
// 2. A fresh boot of AppNotificationCubit does not carry over any state from a
//    prior instance's notification stream, i.e. the stream subscription is
//    scoped to each cubit lifetime (no global static leakage).
// 3. The initial state is a recognisable, typed value (not null / unset).

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/domain/managers/notification_manager.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_cubit.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_state.dart';

// ---------------------------------------------------------------------------
// Minimal hand-rolled fake — implements the abstract NotificationManager
// interface without requiring build_runner / mockito codegen.
// ---------------------------------------------------------------------------
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
  group('AC2 — Global app state structure is defined', () {
    test('AppNotificationCubit starts in initial state', () async {
      final manager = _FakeNotificationManager();
      final cubit = AppNotificationCubit(manager);

      expect(
        cubit.state,
        const AppNotificationState.initial(),
        reason: 'App-shell cubit must begin in initial state on construction',
      );

      await cubit.close();
      await manager.close();
    });

    test(
        'AppNotificationState.initial() is a concrete typed value (not dynamic / null)',
        () {
      const state = AppNotificationState.initial();
      expect(state, isA<AppNotificationState>());
      // Initial should NOT already be a received state.
      expect(state, isNot(isA<AppNotificationReceived>()));
    });

    test(
        'two independently created cubits do not share stream state '
        '(no global static leakage)', () async {
      final managerA = _FakeNotificationManager();
      final managerB = _FakeNotificationManager();

      final cubitA = AppNotificationCubit(managerA);
      final cubitB = AppNotificationCubit(managerB);

      final emittedByB = <AppNotificationState>[];
      final subB = cubitB.stream.listen(emittedByB.add);

      // Push a notification to A's stream only.
      managerA.send(const AppNotification.success(message: 'only for A'));
      await Future<void>.delayed(Duration.zero);

      // B must not have received A's notification.
      expect(
        emittedByB,
        isEmpty,
        reason: 'CubitB must not receive events destined for CubitA — '
            'no global static stream leakage allowed',
      );

      await subB.cancel();
      await cubitA.close();
      await cubitB.close();
      await managerA.close();
      await managerB.close();
    });
  });
}
