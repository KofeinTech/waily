import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/managers/notification_manager.dart';
import 'app_notification_state.dart';

@lazySingleton
class AppNotificationCubit extends Cubit<AppNotificationState> {
  AppNotificationCubit(this._manager)
      : super(const AppNotificationState.initial()) {
    _subscription = _manager.notificationStream.listen(
      (notification) => emit(AppNotificationState.received(notification)),
    );
  }

  final NotificationManager _manager;
  late final StreamSubscription<AppNotification> _subscription;

  @override
  @disposeMethod
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
