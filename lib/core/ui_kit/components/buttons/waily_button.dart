import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';
import '../icons/waily_icon.dart';

/// Button visual type. Maps to the `Type` axis of the Figma `Button`
/// component-set.
enum WailyButtonType { primary, secondary }

/// Button physical size. Maps to the `Size` axis of the Figma `Button`
/// component-set.
enum WailyButtonSize { defaultSize, small }

/// App-wide button widget.
///
/// Reads all visual properties from [AppButtonStyle] — no Material defaults.
/// State (pressed/loading/disabled) is provided as flags rather than as enum
/// values; the widget composes the correct visuals.
///
/// Use the named factories rather than the private constructor:
/// ```dart
/// WailyButton.primary(label: 'Continue', onPressed: _onContinue)
/// WailyButton.secondary(label: 'Skip', onPressed: _onSkip, size: WailyButtonSize.small)
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
    this.leadingIcon,
    this.actionIcon,
    this.leadingIconColor,
    this.actionIconColor,
    this.leadingIconSize,
    this.actionIconSize,
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
    SvgGenImage? leadingIcon,
    SvgGenImage? actionIcon,
    Color? leadingIconColor,
    Color? actionIconColor,
    double? leadingIconSize,
    double? actionIconSize,
  }) => WailyButton._(
    key: key,
    type: WailyButtonType.primary,
    size: size,
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    expanded: expanded,
    leadingIcon: leadingIcon,
    actionIcon: actionIcon,
    leadingIconColor: leadingIconColor,
    actionIconColor: actionIconColor,
    leadingIconSize: leadingIconSize,
    actionIconSize: actionIconSize,
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
    SvgGenImage? leadingIcon,
    SvgGenImage? actionIcon,
    Color? leadingIconColor,
    Color? actionIconColor,
    double? leadingIconSize,
    double? actionIconSize,
  }) => WailyButton._(
    key: key,
    type: WailyButtonType.secondary,
    size: size,
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    expanded: expanded,
    leadingIcon: leadingIcon,
    actionIcon: actionIcon,
    leadingIconColor: leadingIconColor,
    actionIconColor: actionIconColor,
    leadingIconSize: leadingIconSize,
    actionIconSize: actionIconSize,
  );

  final WailyButtonType type;
  final WailyButtonSize size;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool expanded;

  /// Optional icons (hidden while [isLoading]). Colour and size default to
  /// the button foreground and per-size icon token respectively.
  final SvgGenImage? leadingIcon;
  final SvgGenImage? actionIcon;
  final Color? leadingIconColor;
  final Color? actionIconColor;
  final double? leadingIconSize;
  final double? actionIconSize;

  bool get _interactive => !isDisabled && !isLoading && onPressed != null;

  /// Loading-spinner geometry, decoupled from the label font-size.
  /// Default size: 20px diameter, 2.0 stroke. Small: 16px / 2.0.
  static ({double size, double strokeWidth}) _spinnerMetrics(
    WailyButtonSize size,
  ) {
    switch (size) {
      case WailyButtonSize.defaultSize:
        return (size: 20, strokeWidth: 2);
      case WailyButtonSize.small:
        return (size: 16, strokeWidth: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.appButtonStyle;

    final isSmall = size == WailyButtonSize.small;
    final radius = isSmall ? s.borderRadiusSmall : s.borderRadiusDefault;
    final padding = isSmall ? s.paddingSmall : s.paddingDefault;
    final height = isSmall ? s.heightSmall : s.heightDefault;
    final textStyle = isSmall ? s.textStyleSmall : s.textStyleDefault;
    final iconSize = isSmall ? s.iconSizeSmall : s.iconSizeDefault;
    final spinner = _spinnerMetrics(size);

    final Color background = isDisabled
        ? s.disabledBackground
        : type == WailyButtonType.primary
        ? s.primaryBackground
        : s.secondaryBackground;
    final Color pressedBackground = isDisabled
        ? s.disabledBackground
        : type == WailyButtonType.primary
        ? s.primaryPressedBackground
        : s.secondaryPressedBackground;
    final Color foreground = isDisabled
        ? s.disabledForeground
        : type == WailyButtonType.primary
        ? s.primaryForeground
        : s.secondaryForeground;

    final Widget child = isLoading
        ? SizedBox(
            width: spinner.size,
            height: spinner.size,
            child: CircularProgressIndicator(
              strokeWidth: spinner.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : _WailyButtonContent(
            label: label,
            textStyle: textStyle.copyWith(color: foreground),
            leadingIcon: leadingIcon,
            actionIcon: actionIcon,
            leadingIconColor: leadingIconColor ?? foreground,
            actionIconColor: actionIconColor ?? foreground,
            leadingIconSize: leadingIconSize ?? iconSize,
            actionIconSize: actionIconSize ?? iconSize,
            iconGap: s.iconGap,
          );

    return _WailyButtonSurface(
      background: background,
      pressedBackground: pressedBackground,
      borderRadius: BorderRadius.circular(radius),
      padding: padding,
      height: height,
      expanded: expanded,
      onTap: _interactive ? onPressed : null,
      child: child,
    );
  }
}

/// Renders the non-loading button content: optional leading icon, label,
/// optional trailing icon. Skips null slots and the adjacent gap entirely.
class _WailyButtonContent extends StatelessWidget {
  const _WailyButtonContent({
    required this.label,
    required this.textStyle,
    required this.leadingIcon,
    required this.actionIcon,
    required this.leadingIconColor,
    required this.actionIconColor,
    required this.leadingIconSize,
    required this.actionIconSize,
    required this.iconGap,
  });

  final String label;
  final TextStyle textStyle;
  final SvgGenImage? leadingIcon;
  final SvgGenImage? actionIcon;
  final Color leadingIconColor;
  final Color actionIconColor;
  final double leadingIconSize;
  final double actionIconSize;
  final double iconGap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (leadingIcon != null) {
      children.add(
        WailyIcon(
          icon: leadingIcon!,
          size: leadingIconSize,
          color: leadingIconColor,
        ),
      );
      children.add(SizedBox(width: iconGap));
    }
    children.add(Text(label, style: textStyle));
    if (actionIcon != null) {
      children.add(SizedBox(width: iconGap));
      children.add(
        WailyIcon(
          icon: actionIcon!,
          size: actionIconSize,
          color: actionIconColor,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _WailyButtonSurface extends StatefulWidget {
  const _WailyButtonSurface({
    required this.background,
    required this.pressedBackground,
    required this.borderRadius,
    required this.padding,
    required this.height,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  final Color background;
  final Color pressedBackground;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double height;
  final bool expanded;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_WailyButtonSurface> createState() => _WailyButtonSurfaceState();
}

class _WailyButtonSurfaceState extends State<_WailyButtonSurface> {
  final Set<WidgetState> _states = <WidgetState>{};

  void _setPressed(bool pressed) {
    if (!mounted) return;
    final has = _states.contains(WidgetState.pressed);
    if (has == pressed) return;
    setState(() {
      if (pressed) {
        _states.add(WidgetState.pressed);
      } else {
        _states.remove(WidgetState.pressed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.pressed)) return widget.pressedBackground;
      return widget.background;
    }).resolve(_states);

    return SizedBox(
      height: widget.height,
      width: widget.expanded ? double.infinity : null,
      child: Material(
        color: color,
        borderRadius: widget.borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: widget.onTap == null ? null : _setPressed,
          borderRadius: widget.borderRadius,
          child: Padding(
            padding: widget.padding,
            child: Row(
              mainAxisSize: widget.expanded
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [widget.child],
            ),
          ),
        ),
      ),
    );
  }
}
