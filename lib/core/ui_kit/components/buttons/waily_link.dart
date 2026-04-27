import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Inline tappable text link.
///
/// Reads colors and padding from [AppLinkStyle] — no Material defaults.
/// Mirrors the Figma `Link` component-set: `State` ∈ {Default, Pressed} plus
/// a synthesized Disabled state.
///
/// Example:
/// ```dart
/// WailyLink(label: 'Log in', onPressed: _login)
/// ```
class WailyLink extends StatefulWidget {
  const WailyLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
  });

  final String label;

  /// Tap handler. Ignored when [isDisabled] is true or when null.
  final VoidCallback? onPressed;

  /// Disabled state. Switches the label to [AppLinkStyle.colorDisabled] and
  /// suppresses [onPressed].
  final bool isDisabled;

  @override
  State<WailyLink> createState() => _WailyLinkState();
}

class _WailyLinkState extends State<WailyLink> {
  bool _pressed = false;

  bool get _enabled => !widget.isDisabled && widget.onPressed != null;

  void _setPressed(bool pressed) {
    if (!mounted) return;
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.appLinkStyle;

    final Color color;
    if (widget.isDisabled) {
      color = s.colorDisabled;
    } else if (_pressed) {
      color = s.colorPressed;
    } else {
      color = s.colorDefault;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? widget.onPressed : null,
      onTapDown: _enabled ? (_) => _setPressed(true) : null,
      onTapUp: _enabled ? (_) => _setPressed(false) : null,
      onTapCancel: _enabled ? () => _setPressed(false) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: s.verticalPadding),
        child: Text(
          widget.label,
          style: context.appTextStyles.s16w500(color: color),
        ),
      ),
    );
  }
}
