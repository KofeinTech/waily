import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Selection card with title, optional subtitle, and a trailing checkbox —
/// Figma `Picker Card` component-set.
///
/// Default state: translucent white card, white title, textSecondary
/// subtitle. Selected state: primary fill, surfaceVariant title,
/// textDisabled subtitle, plus a trailing white-on-primary checkmark.
/// Reads geometry/colors from [AppPickerCardStyle].
class WailyPickerCard extends StatelessWidget {
  const WailyPickerCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onPressed,
    this.isDisabled = false,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback? onPressed;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appPickerCardStyle;
    final t = context.appTextStyles;

    final Color background;
    final Color titleColor;
    final Color subtitleColor;
    if (isDisabled) {
      background = s.disabledBackgroundColor;
      titleColor = s.disabledTitleColor;
      subtitleColor = s.disabledSubtitleColor;
    } else if (isSelected) {
      background = s.activeBackgroundColor;
      titleColor = s.activeTitleColor;
      subtitleColor = s.activeSubtitleColor;
    } else {
      background = s.defaultBackgroundColor;
      titleColor = s.defaultTitleColor;
      subtitleColor = s.defaultSubtitleColor;
    }

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: t.s16w500(color: titleColor),
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          SizedBox(height: s.itemSpacing),
          Text(
            subtitle!,
            style: t.s14w400(color: subtitleColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? onPressed : null,
      child: Container(
        padding: EdgeInsets.all(s.padding),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(s.borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: s.padding),
                child: Icon(
                  Icons.check,
                  size: s.checkboxSize,
                  color: titleColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
