import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Two-state switch (On / Off) plus synthesized Disabled.
///
/// Renders the Figma `Switcher` component-set: a 64x32 stadium track with a
/// 25.6 circular thumb that animates between two horizontal positions.
/// Reads everything from [AppSwitcherStyle].
class WailySwitcher extends StatelessWidget {
  const WailySwitcher({
    super.key,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;

  bool get _enabled => !isDisabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final s = context.appSwitcherStyle;

    final Color trackColor;
    final Color thumbColor;
    if (isDisabled) {
      trackColor = s.trackColorDisabled;
      thumbColor = s.thumbColorDisabled;
    } else if (value) {
      trackColor = s.trackColorOn;
      thumbColor = s.thumbColorOn;
    } else {
      trackColor = s.trackColorOff;
      thumbColor = s.thumbColorOff;
    }

    final double offThumbX = s.thumbPadding;
    final double onThumbX = s.trackWidth - s.thumbSize - s.thumbPadding;
    final double thumbX = value ? onThumbX : offThumbX;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? () => onChanged!(!value) : null,
      child: SizedBox(
        width: s.trackWidth,
        height: s.trackHeight,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: s.trackWidth,
              height: s.trackHeight,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(s.trackHeight / 2),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              left: thumbX,
              top: s.thumbPadding,
              child: Container(
                width: s.thumbSize,
                height: s.thumbSize,
                decoration: BoxDecoration(
                  color: thumbColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
