import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';
import '../icons/waily_icon.dart';

/// Icon button physical size. Maps to the `Size` axis of the Figma
/// `Icon button` component-set.
enum WailyIconButtonSize { defaultSize, big }

/// App-wide icon-only button.
///
/// Reads all visual properties from [AppIconButtonStyle] — no Material
/// defaults. Supports two Figma sizes (Default 48x48 / Big 52x52) and three
/// states (Default / Pressed / Disabled).
///
/// Example:
/// ```dart
/// WailyIconButton(
///   icon: Assets.icons.common.close,
///   onPressed: _onClose,
/// )
/// ```
class WailyIconButton extends StatelessWidget {
  const WailyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = WailyIconButtonSize.defaultSize,
    this.isDisabled = false,
  });

  /// SVG asset to render inside the button. Painted with the resolved icon
  /// color via [WailyIcon].
  final SvgGenImage icon;

  /// Tap handler. Ignored when [isDisabled] is true or when null (the button
  /// becomes non-interactive and Material disables ripple feedback).
  final VoidCallback? onPressed;

  /// Container size. See [WailyIconButtonSize].
  final WailyIconButtonSize size;

  /// Disabled state (Figma `State=Disabled`). Suppresses [onPressed] and
  /// switches the icon to [AppIconButtonStyle.iconColorDisabled].
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appIconButtonStyle;

    final isBig = size == WailyIconButtonSize.big;
    final containerSize = isBig ? s.sizeBig : s.sizeDefault;
    final iconSize = isBig ? s.iconSizeBig : s.iconSizeDefault;
    final radius = BorderRadius.circular(s.borderRadius);

    final iconColor = isDisabled ? s.iconColorDisabled : s.iconColorDefault;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Material(
        color: s.backgroundColor,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: radius,
          child: Center(
            child: WailyIcon(icon: icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
