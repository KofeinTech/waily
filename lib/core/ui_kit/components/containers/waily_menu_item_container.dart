import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';
import '../icons/waily_icon.dart';

/// Tab/menu item — Figma `Menu Item Container`.
///
/// Default state shows the icon only on a transparent background. Active
/// state shows the icon plus a label on a borderStrong-tinted pill. Reads
/// geometry/colors from [AppMenuItemContainerStyle].
class WailyMenuItemContainer extends StatelessWidget {
  const WailyMenuItemContainer({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.isDisabled = false,
  });

  final SvgGenImage icon;
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appMenuItemContainerStyle;
    final t = context.appTextStyles;

    final Color background;
    final Color iconColor;
    final Color labelColor;
    if (isDisabled) {
      background = s.disabledBackgroundColor;
      iconColor = s.disabledIconColor;
      labelColor = s.disabledLabelColor;
    } else if (isActive) {
      background = s.activeBackgroundColor;
      iconColor = s.iconColor;
      labelColor = s.labelColor;
    } else {
      background = s.defaultBackgroundColor;
      iconColor = s.iconColor;
      labelColor = s.labelColor;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? onPressed : null,
      child: Container(
        height: s.height,
        padding: EdgeInsets.symmetric(
          horizontal: s.horizontalPadding,
          vertical: s.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(s.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WailyIcon(icon: icon, size: s.iconSize, color: iconColor),
            if (isActive) ...[
              SizedBox(width: s.itemSpacing),
              Text(label, style: t.s12w500(color: labelColor)),
            ],
          ],
        ),
      ),
    );
  }
}
