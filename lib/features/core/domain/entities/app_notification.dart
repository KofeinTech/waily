import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

@freezed
sealed class AppNotification with _$AppNotification {
  const factory AppNotification.success({required String message, String? title}) = AppNotificationSuccess;
  const factory AppNotification.error({required String message, String? title}) = AppNotificationError;
  const factory AppNotification.info({required String message, String? title}) = AppNotificationInfo;
  const factory AppNotification.warning({required String message, String? title}) = AppNotificationWarning;
}
