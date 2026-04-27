import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Text-only selector — Figma `Selector` component-set.
///
/// Default state renders a muted s14w400 placeholder-grey label; Active
/// flips to white s14w500. Used as a wheel/picker option visual.
class WailySelector extends StatelessWidget {
  const WailySelector({
    super.key,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.isDisabled = false,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onPressed;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appSelectorStyle;
    final t = context.appTextStyles;

    final Color color;
    if (isDisabled) {
      color = s.disabledColor;
    } else if (isActive) {
      color = s.activeColor;
    } else {
      color = s.defaultColor;
    }

    final TextStyle style =
        isActive ? t.s14w500(color: color) : t.s14w400(color: color);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? onPressed : null,
      child: Text(label, style: style),
    );
  }
}
