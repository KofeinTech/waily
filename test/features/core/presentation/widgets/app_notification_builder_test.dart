import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:waily/features/core/domain/entities/app_notification.dart';
import 'package:waily/features/core/presentation/bloc/app_notification_cubit.dart';
import 'package:waily/features/core/presentation/widgets/app_notification_builder.dart';

import '../../mocks.mocks.dart';

void main() {
  group('AppNotificationBuilder', () {
    testWidgets('renders SnackBar with success message on received(success)',
        (tester) async {
      final manager = MockNotificationManager();
      final controller = StreamController<AppNotification>.broadcast();
      when(manager.notificationStream).thenAnswer((_) => controller.stream);
      final cubit = AppNotificationCubit(manager);
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AppNotificationCubit>.value(
          value: cubit,
          child: const AppNotificationBuilder(
            child: Scaffold(body: Text('home')),
          ),
        ),
      ));

      controller.add(const AppNotification.success(message: 'ok'));
      await tester.pump(); // process the stream event
      await tester.pump(); // let the SnackBar animate in

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('ok'), findsOneWidget);
    });

    testWidgets('renders SnackBar with error message on received(error)',
        (tester) async {
      final manager = MockNotificationManager();
      final controller = StreamController<AppNotification>.broadcast();
      when(manager.notificationStream).thenAnswer((_) => controller.stream);
      final cubit = AppNotificationCubit(manager);
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AppNotificationCubit>.value(
          value: cubit,
          child: const AppNotificationBuilder(
            child: Scaffold(body: Text('home')),
          ),
        ),
      ));

      controller.add(const AppNotification.error(message: 'boom'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('boom'), findsOneWidget);
    });
  });
}
