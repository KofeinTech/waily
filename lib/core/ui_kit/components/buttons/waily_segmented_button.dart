import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';
import '../icons/waily_icon.dart';

/// Two-state toggle button styled like a translucent pill — Figma `Segmented btn`.
///
/// Body tap fires [onPressed] (toggle); the optional trailing close icon
/// fires [onClose]. Reads geometry/colors from [AppSegmentedButtonStyle].
class WailySegmentedButton extends StatelessWidget {
  const WailySegmentedButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.onClose,
    this.isDisabled = false,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onPressed;
  final VoidCallback? onClose;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onPressed != null;
  bool get _closeEnabled => !isDisabled && onClose != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appSegmentedButtonStyle;
    final t = context.appTextStyles;

    final Color background;
    final Color labelColor;
    final Color iconColor;
    if (isDisabled) {
      background = s.disabledBackgroundColor;
      labelColor = s.disabledLabelColor;
      iconColor = s.disabledIconColor;
    } else if (isActive) {
      background = s.activeBackgroundColor;
      labelColor = s.activeLabelColor;
      iconColor = s.iconColor;
    } else {
      background = s.defaultBackgroundColor;
      labelColor = s.defaultLabelColor;
      iconColor = s.iconColor;
    }

    final children = <Widget>[
      Text(label, style: t.s16w400(color: labelColor)),
    ];
    if (onClose != null) {
      children.add(SizedBox(width: s.itemSpacing));
      children.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _closeEnabled ? onClose : null,
          child: WailyIcon(
            icon: Assets.icons.common.close,
            size: s.iconSize,
            color: iconColor,
          ),
        ),
      );
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
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
