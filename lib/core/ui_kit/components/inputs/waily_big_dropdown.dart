import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Tappable card with title, optional subtitle, and a trailing chevron.
///
/// Renders the Figma `Big Dropdown` trigger surface. The opening behavior
/// (bottom sheet, menu) lives outside this atom — wire it up in [onPressed].
/// Reads geometry/colors from [AppBigDropdownStyle].
class WailyBigDropdown extends StatelessWidget {
  const WailyBigDropdown({
    super.key,
    required this.title,
    this.subtitle,
    required this.onPressed,
    this.isDisabled = false,
  });

  final String title;

  /// Optional caption rendered below [title]. Hidden when null.
  final String? subtitle;

  final VoidCallback? onPressed;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appBigDropdownStyle;
    final t = context.appTextStyles;

    final Color background;
    final Color titleColor;
    final Color subtitleColor;
    final Color iconColor;
    if (isDisabled) {
      background = s.disabledBackgroundColor;
      titleColor = s.disabledTitleColor;
      subtitleColor = s.disabledSubtitleColor;
      iconColor = s.disabledIconColor;
    } else {
      background = s.backgroundColor;
      titleColor = s.titleColor;
      subtitleColor = s.subtitleColor;
      iconColor = s.iconColor;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? onPressed : null,
      child: Container(
        height: s.height,
        padding: EdgeInsets.all(s.padding),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(s.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: t.s18w400(color: titleColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: s.titleSubtitleSpacing),
                    Text(
                      subtitle!,
                      style: t.s14w400(color: subtitleColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: s.iconSize,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
