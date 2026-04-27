import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Button visual type. Maps to the `Type` axis of the Figma `Button`
/// component-set.
enum WailyButtonType { primary, secondary }

/// Button physical size. Maps to the `Size` axis of the Figma `Button`
/// component-set.
enum WailyButtonSize { defaultSize, big }

/// App-wide button widget.
///
/// Reads all visual properties from [AppButtonStyle] — no Material defaults.
/// State (pressed/loading/disabled) is provided as flags rather than as enum
/// values; the widget composes the correct visuals.
///
/// Use the named factories rather than the private constructor:
/// ```dart
/// WailyButton.primary(label: 'Continue', onPressed: _onContinue)
/// WailyButton.secondary(label: 'Skip', onPressed: _onSkip, size: WailyButtonSize.big)
/// WailyButton.primary(label: 'Saving…', onPressed: _save, isLoading: true)
/// ```
class WailyButton extends StatelessWidget {
  const WailyButton._({
    required this.type,
    required this.size,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.isDisabled,
    required this.expanded,
    super.key,
  });

  /// Primary button — filled blue surface.
  factory WailyButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    WailyButtonSize size = WailyButtonSize.defaultSize,
    bool isLoading = false,
    bool isDisabled = false,
    bool expanded = false,
  }) => WailyButton._(
    key: key,
    type: WailyButtonType.primary,
    size: size,
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    expanded: expanded,
  );

  /// Secondary button — filled white surface.
  factory WailyButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    WailyButtonSize size = WailyButtonSize.defaultSize,
    bool isLoading = false,
    bool isDisabled = false,
    bool expanded = false,
  }) => WailyButton._(
    key: key,
    type: WailyButtonType.secondary,
    size: size,
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    expanded: expanded,
  );

  final WailyButtonType type;
  final WailyButtonSize size;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool expanded;

  bool get _interactive => !isDisabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appButtonStyle;

    final isBig = size == WailyButtonSize.big;
    final radius = isBig ? s.borderRadiusBig : s.borderRadiusDefault;
    final padding = isBig ? s.paddingBig : s.paddingDefault;
    final height = isBig ? s.heightBig : s.heightDefault;
    final textStyle = isBig ? s.textStyleBig : s.textStyleDefault;

    final Color background = isDisabled
        ? s.disabledBackground
        : type == WailyButtonType.primary
        ? s.primaryBackground
        : s.secondaryBackground;
    final Color foreground = isDisabled
        ? s.disabledForeground
        : type == WailyButtonType.primary
        ? s.primaryForeground
        : s.secondaryForeground;

    final borderRadius = BorderRadius.circular(radius);

    final Widget child = isLoading
        ? SizedBox(
            width: textStyle.fontSize ?? 16,
            height: textStyle.fontSize ?? 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : Text(label, style: textStyle.copyWith(color: foreground));

    final core = SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: Material(
        color: background,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _interactive ? onPressed : null,
          borderRadius: borderRadius,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [child],
            ),
          ),
        ),
      ),
    );

    return core;
  }
}
