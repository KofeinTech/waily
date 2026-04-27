import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Tappable card with title and optional description — Figma `Option`.
///
/// Two states (Default / Selected) plus a synthesized Disabled. Selecting
/// changes the card background to primary and inverts the title color to
/// the dark app background. Reads geometry/colors from [AppOptionStyle].
class WailyOption extends StatelessWidget {
  const WailyOption({
    super.key,
    required this.title,
    this.description,
    required this.isSelected,
    required this.onPressed,
    this.isDisabled = false,
  });

  final String title;
  final String? description;
  final bool isSelected;
  final VoidCallback? onPressed;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appOptionStyle;
    final t = context.appTextStyles;

    final Color background;
    final Color titleColor;
    final Color descriptionColor;
    if (isDisabled) {
      background = s.disabledBackgroundColor;
      titleColor = s.disabledTitleColor;
      descriptionColor = s.disabledDescriptionColor;
    } else if (isSelected) {
      background = s.selectedBackgroundColor;
      titleColor = s.selectedTitleColor;
      descriptionColor = s.selectedDescriptionColor;
    } else {
      background = s.defaultBackgroundColor;
      titleColor = s.defaultTitleColor;
      descriptionColor = s.defaultDescriptionColor;
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
            if (description != null) ...[
              SizedBox(height: s.titleDescriptionSpacing),
              Text(
                description!,
                style: t.s14w400(color: descriptionColor),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
