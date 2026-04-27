import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// One entry inside a [WailySegmentedPicker].
typedef WailySegmentedPickerItem<T> = ({T value, String label});

/// Generic segmented picker — N labels in a pill, one selected at a time.
///
/// Renders the Figma `Segmented Picker` component-set. Reads container and
/// item geometry/colors from [AppSegmentedPickerStyle].
class WailySegmentedPicker<T> extends StatelessWidget {
  const WailySegmentedPicker({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  }) : assert(items.length > 0, 'WailySegmentedPicker needs at least one item');

  final List<WailySegmentedPickerItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final s = context.appSegmentedPickerStyle;
    final t = context.appTextStyles;

    return Container(
      height: s.containerHeight,
      padding: EdgeInsets.all(s.containerPadding),
      decoration: BoxDecoration(
        color: s.containerBackgroundColor,
        borderRadius: BorderRadius.circular(s.containerBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isActive = item.value == value;
          final Color background;
          final Color labelColor;
          if (isActive && isDisabled) {
            background = s.disabledItemBackgroundColor;
            labelColor = s.disabledLabelColor;
          } else if (isActive) {
            background = s.activeItemBackgroundColor;
            labelColor = s.activeLabelColor;
          } else {
            background = Colors.transparent;
            labelColor = isDisabled ? s.disabledLabelColor : s.defaultLabelColor;
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (isDisabled || isActive) ? null : () => onChanged(item.value),
            child: Container(
              height: s.itemHeight,
              padding: EdgeInsets.symmetric(
                horizontal: s.itemHorizontalPadding,
                vertical: s.itemVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(s.itemBorderRadius),
              ),
              alignment: Alignment.center,
              child: Text(item.label, style: t.s14w500(color: labelColor)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
