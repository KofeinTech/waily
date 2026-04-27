import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Single-character box used for OTP-style entry — Figma `digit box`.
///
/// Resolves to one of four Figma states based on inputs:
/// - [hasError] → Error (transparent fill, error border, digit shown)
/// - [hasFocus] && empty digit → Active (primary border, blinking cursor)
/// - [hasFocus] with digit → Active with digit
/// - non-empty [digit] → Filled
/// - else → Default (empty)
///
/// Reads geometry/colors from [AppDigitBoxStyle].
class WailyDigitBox extends StatelessWidget {
  const WailyDigitBox({
    super.key,
    this.digit,
    this.hasFocus = false,
    this.hasError = false,
  });

  /// Single character to display. Empty string and null both render the
  /// empty state.
  final String? digit;

  final bool hasFocus;
  final bool hasError;

  bool get _hasDigit => digit != null && digit!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final s = context.appDigitBoxStyle;
    final t = context.appTextStyles;

    final Color background;
    final Color borderColor;
    if (hasError) {
      background = s.errorBackgroundColor;
      borderColor = s.errorBorderColor;
    } else if (hasFocus) {
      background = s.filledBackgroundColor;
      borderColor = s.activeBorderColor;
    } else {
      background = s.filledBackgroundColor;
      borderColor = Colors.transparent;
    }

    final String content;
    final Color contentColor;
    if (_hasDigit) {
      content = digit!;
      contentColor = s.digitColor;
    } else if (hasFocus) {
      content = '|';
      contentColor = s.cursorColor;
    } else {
      content = '';
      contentColor = s.digitColor;
    }

    return Container(
      width: s.width,
      height: s.height,
      padding: EdgeInsets.all(s.padding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(s.borderRadius),
        border: Border.all(color: borderColor, width: s.borderWidth),
      ),
      alignment: Alignment.center,
      child: Text(content, style: t.s24w500(color: contentColor)),
    );
  }
}
