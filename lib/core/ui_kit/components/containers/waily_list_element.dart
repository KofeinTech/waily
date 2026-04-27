import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Tappable list row with a label, optional value, and a trailing chevron.
///
/// Renders the Figma `List element` component-set: `Type=Default` (label +
/// chevron) and `Type=2 text` (label + value + chevron). Reads
/// geometry/colors from [AppListElementStyle].
class WailyListElement extends StatelessWidget {
  const WailyListElement({
    super.key,
    required this.label,
    this.value,
    required this.onPressed,
    this.isDisabled = false,
  });

  final String label;

  /// Optional info text rendered before the chevron. Hidden when null.
  final String? value;

  final VoidCallback? onPressed;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appListElementStyle;
    final t = context.appTextStyles;

    final Color labelColor =
        isDisabled ? s.disabledLabelColor : s.labelColor;
    final Color valueColor =
        isDisabled ? s.disabledValueColor : s.valueColor;
    final Color iconColor = isDisabled ? s.disabledIconColor : s.iconColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? onPressed : null,
      child: SizedBox(
        height: s.height,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: s.verticalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: t.s16w500(color: labelColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (value != null) ...[
                Text(value!, style: t.s14w500(color: valueColor)),
                SizedBox(width: s.itemSpacing),
              ],
              Icon(
                Icons.chevron_right,
                size: s.iconSize,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
