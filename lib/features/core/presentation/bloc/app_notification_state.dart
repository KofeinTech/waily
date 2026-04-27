import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/app_notification.dart';

part 'app_notification_state.freezed.dart';

@freezed
sealed class AppNotificationState with _$AppNotificationState {
  const factory AppNotificationState.initial() = AppNotificationInitial;
  const factory AppNotificationState.received(AppNotification notification) =
      AppNotificationReceived;
}
