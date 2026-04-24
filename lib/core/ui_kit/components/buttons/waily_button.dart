import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Button display variants.
enum WailyButtonVariant { primary, secondary, outlined }

/// App-wide button widget.
///
/// Reads all visual properties from [AppButtonStyle] — no Material defaults.
///
/// Example:
/// ```dart
/// WailyButton(label: 'Continue', onPressed: _onContinue)
/// WailyButton(label: 'Cancel', onPressed: _onCancel, variant: WailyButtonVariant.outlined)
/// ```
class WailyButton extends StatelessWidget {
  const WailyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = WailyButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final WailyButtonVariant variant;

  ButtonStyle _buildStyle({
    required Color background,
    required Color foreground,
    required Color disabledBackground,
    required Color disabledForeground,
    required double borderRadius,
    required EdgeInsets padding,
    required TextStyle textStyle,
    BorderSide? side,
  }) =>
      ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? disabledBackground
              : background,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? disabledForeground
              : foreground,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: side ?? BorderSide.none,
          ),
        ),
        padding: WidgetStateProperty.all(padding),
        textStyle:
            WidgetStateProperty.all(textStyle.copyWith(inherit: false)),
        splashFactory: NoSplash.splashFactory,
      );

  @override
  Widget build(BuildContext context) {
    final s = context.appButtonStyle;

    switch (variant) {
      case WailyButtonVariant.primary:
      case WailyButtonVariant.secondary:
        final bg = variant == WailyButtonVariant.primary
            ? s.primaryBackground
            : s.secondaryBackground;
        final fg = variant == WailyButtonVariant.primary
            ? s.primaryForeground
            : s.secondaryForeground;
        return ElevatedButton(
          onPressed: onPressed,
          style: _buildStyle(
            background: bg,
            foreground: fg,
            disabledBackground: s.disabledBackground,
            disabledForeground: s.disabledForeground,
            borderRadius: s.borderRadius,
            padding: s.padding,
            textStyle: s.textStyle,
          ),
          child: Text(label),
        );

      case WailyButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: _buildStyle(
            background: Colors.transparent,
            foreground: s.outlinedForeground,
            disabledBackground: Colors.transparent,
            disabledForeground: s.disabledForeground,
            borderRadius: s.borderRadius,
            padding: s.padding,
            textStyle: s.textStyle,
            side: BorderSide(color: s.outlinedBorderColor),
          ),
          child: Text(label),
        );
    }
  }
}
