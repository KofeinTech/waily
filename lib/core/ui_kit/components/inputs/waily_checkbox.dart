import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Two-state checkbox.
///
/// Renders the Figma `Check Box` component-set: a 24x24 circular control,
/// hollow when [value] is false and solid (with a 16x16 white checkmark) when
/// true. Reads everything from [AppCheckboxStyle].
///
/// Example:
/// ```dart
/// WailyCheckbox(value: agreed, onChanged: (v) => setState(() => agreed = v))
/// ```
class WailyCheckbox extends StatelessWidget {
  const WailyCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  final bool value;

  /// Toggle handler. Receives the negated [value]. Ignored when [isDisabled]
  /// is true or when null.
  final ValueChanged<bool>? onChanged;

  final bool isDisabled;

  bool get _enabled => !isDisabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appCheckboxStyle;

    final Color fill;
    final Color border;
    if (isDisabled) {
      fill = value ? s.disabledFillColor : s.defaultFillColor;
      border = s.disabledBorderColor;
    } else if (value) {
      fill = s.activeFillColor;
      border = s.activeFillColor;
    } else {
      fill = s.defaultFillColor;
      border = s.defaultBorderColor;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? () => onChanged!(!value) : null,
      child: Container(
        width: s.size,
        height: s.size,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: s.borderWidth),
        ),
        alignment: Alignment.center,
        child: value
            ? Icon(
                Icons.check,
                size: s.iconSize,
                color: isDisabled ? s.disabledCheckmarkColor : s.checkmarkColor,
              )
            : null,
      ),
    );
  }
}
