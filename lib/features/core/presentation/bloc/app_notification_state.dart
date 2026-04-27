import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/app_notification.dart';

part 'app_notification_state.freezed.dart';

@freezed
sealed class AppNotificationState with _$AppNotificationState {
  const factory AppNotificationState.initial() = AppNotificationInitial;

  /// [emittedAt] makes every emission distinct so Cubit's value-equality
  /// dedup does not swallow duplicate notifications (same message in a row).
  const factory AppNotificationState.received(
    AppNotification notification, {
    required DateTime emittedAt,
  }) = AppNotificationReceived;
}
