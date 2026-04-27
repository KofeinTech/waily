import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';
import '../icons/waily_icon.dart';

/// Sender axis on the Figma `Message Field` component-set.
enum WailyMessageSender { user, ai }

/// Chat message bubble — Figma `Message Field`.
///
/// User bubbles have a solid primary fill and dark text. AI bubbles have a
/// transparent fill with a white stroke and white text. Pass [onCopy] to
/// surface a trailing copy affordance below the AI text (Figma's
/// `Copy=On` variant). Reads geometry/colors from [AppMessageFieldStyle].
class WailyMessageField extends StatelessWidget {
  const WailyMessageField({
    super.key,
    required this.text,
    required this.sender,
    this.onCopy,
  });

  final String text;
  final WailyMessageSender sender;

  /// Tap handler for the trailing copy icon. Hidden when null and ignored
  /// for user bubbles (Figma only exposes copy on AI variants).
  final VoidCallback? onCopy;

  bool get _isUser => sender == WailyMessageSender.user;
  bool get _showCopy => !_isUser && onCopy != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appMessageFieldStyle;
    final t = context.appTextStyles;

    final EdgeInsets padding = _isUser
        ? EdgeInsets.symmetric(
            horizontal: s.userPaddingHorizontal,
            vertical: s.userPaddingVertical,
          )
        : EdgeInsets.symmetric(
            horizontal: s.aiPaddingHorizontal,
            vertical: s.aiPaddingVertical,
          );

    final BoxDecoration decoration = _isUser
        ? BoxDecoration(
            color: s.userBackgroundColor,
            borderRadius: BorderRadius.circular(s.borderRadius),
          )
        : BoxDecoration(
            color: s.aiBackgroundColor,
            borderRadius: BorderRadius.circular(s.borderRadius),
            border: Border.all(color: s.aiBorderColor),
          );

    final Color textColor = _isUser ? s.userTextColor : s.aiTextColor;

    return Container(
      padding: padding,
      decoration: decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: t.s16w400(color: textColor)),
          if (_showCopy) ...[
            SizedBox(height: s.itemSpacing),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCopy,
              child: WailyIcon(
                icon: Assets.icons.common.copy,
                size: s.copyIconSize,
                color: s.copyIconColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
