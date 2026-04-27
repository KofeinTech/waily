import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';
import '../icons/waily_icon.dart';

/// Two background tones available on the Figma `Chip` component-set.
enum WailyChipColor { dark, light }

/// Compact pill with a label, optional value text, and a trailing close icon.
///
/// Renders the Figma `Chip` component-set: `Type` ∈ {Default, 2 items} ×
/// `Color` ∈ {Dark, Light}. Pass [value] to opt into the 2-items layout. Set
/// [onClose] to enable the trailing close icon — when null, the icon is
/// hidden and the chip becomes read-only. Reads everything from
/// [AppChipStyle].
class WailyChip extends StatelessWidget {
  const WailyChip({
    super.key,
    required this.label,
    this.value,
    this.onClose,
    this.color = WailyChipColor.dark,
    this.isDisabled = false,
  });

  final String label;

  /// Secondary text rendered after the label (Figma `Type=2 items`). Hidden
  /// when null, falling back to the Default type.
  final String? value;

  /// Tap handler for the trailing close icon. When null the icon is hidden.
  final VoidCallback? onClose;

  final WailyChipColor color;

  final bool isDisabled;

  bool get _enabled => !isDisabled && onClose != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appChipStyle;
    final t = context.appTextStyles;

    final Color background;
    if (isDisabled) {
      background = s.disabledBackgroundColor;
    } else if (color == WailyChipColor.dark) {
      background = s.darkBackgroundColor;
    } else {
      background = s.lightBackgroundColor;
    }

    final labelColor = isDisabled ? s.disabledLabelColor : s.labelColor;
    final valueColor = isDisabled ? s.disabledLabelColor : s.valueColor;
    final iconColor = isDisabled ? s.disabledIconColor : s.iconColor;

    final children = <Widget>[
      Text(label, style: t.s14w500(color: labelColor)),
    ];

    if (value != null) {
      children.add(SizedBox(width: s.itemSpacing));
      children.add(Text(value!, style: t.s14w400(color: valueColor)));
    }

    if (onClose != null) {
      children.add(SizedBox(width: s.itemSpacing));
      children.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? onClose : null,
          child: WailyIcon(
            icon: Assets.icons.common.close,
            size: s.iconSize,
            color: iconColor,
          ),
        ),
      );
    }

    return Container(
      height: s.height,
      padding: EdgeInsets.symmetric(
        horizontal: s.horizontalPadding,
        vertical: s.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(s.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
