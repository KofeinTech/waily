import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Tappable chat hint card — Figma `Chat Tip`.
///
/// Renders a short prompt the user can tap to drop into the chat composer.
/// Supports three states (Default / Active / Disabled). Active inverts the
/// card to the primaryLowest tone; Disabled greys both background and text.
class WailyChatTip extends StatelessWidget {
  const WailyChatTip({
    super.key,
    required this.text,
    required this.onPressed,
    this.isActive = false,
    this.isDisabled = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appChatTipStyle;
    final t = context.appTextStyles;

    final Color background;
    final Color textColor;
    if (isDisabled) {
      background = s.disabledBackgroundColor;
      textColor = s.disabledTextColor;
    } else if (isActive) {
      background = s.activeBackgroundColor;
      textColor = s.activeTextColor;
    } else {
      background = s.defaultBackgroundColor;
      textColor = s.defaultTextColor;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? onPressed : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: s.horizontalPadding,
          vertical: s.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(s.borderRadius),
        ),
        child: Text(text, style: t.s14w400(color: textColor)),
      ),
    );
  }
}
