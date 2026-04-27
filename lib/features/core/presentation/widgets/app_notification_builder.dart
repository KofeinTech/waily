import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../bloc/app_notification_cubit.dart';
import '../bloc/app_notification_state.dart';

class AppNotificationBuilder extends StatelessWidget {
  const AppNotificationBuilder({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppNotificationCubit, AppNotificationState>(
      listener: (context, state) {
        switch (state) {
          case AppNotificationInitial():
            return;
          case AppNotificationReceived(:final notification):
            _showSnackBar(context, notification);
        }
      },
      child: child,
    );
  }

  void _showSnackBar(BuildContext context, AppNotification notification) {
    final scheme = Theme.of(context).colorScheme;
    final (color, icon, text) = switch (notification) {
      AppNotificationSuccess(:final message, :final title) =>
        (scheme.primaryContainer, Icons.check_circle, _compose(title, message)),
      AppNotificationError(:final message, :final title) =>
        (scheme.errorContainer, Icons.error, _compose(title, message)),
      AppNotificationInfo(:final message, :final title) =>
        (scheme.secondaryContainer, Icons.info, _compose(title, message)),
      AppNotificationWarning(:final message, :final title) =>
        (scheme.tertiaryContainer, Icons.warning, _compose(title, message)),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
  }

  String _compose(String? title, String message) =>
      title == null ? message : '$title: $message';
}
