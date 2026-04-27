import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Multi-line chat composer — Figma `Chat Input Field`.
///
/// Auto-grows with the text. The trailing 40x40 button fires [onSend] when
/// the controller has text, or [onMic] when empty (only shown when the
/// matching callback is provided). When [isDisabled] is true the container
/// fills with [AppChatInputFieldStyle.disabledBackgroundColor] and the
/// text field becomes read-only.
class WailyChatInputField extends StatefulWidget {
  const WailyChatInputField({
    super.key,
    required this.controller,
    this.placeholder,
    this.onChanged,
    this.onSend,
    this.onMic,
    this.maxLines = 5,
    this.isDisabled = false,
  });

  final TextEditingController controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;

  /// Fires when the trailing button is tapped while there is text.
  final VoidCallback? onSend;

  /// Fires when the trailing button is tapped while there is no text. When
  /// null, the mic affordance is hidden so an empty composer has no trailing
  /// button.
  final VoidCallback? onMic;

  final int maxLines;
  final bool isDisabled;

  @override
  State<WailyChatInputField> createState() => _WailyChatInputFieldState();
}

class _WailyChatInputFieldState extends State<WailyChatInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onTextChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final s = context.appChatInputFieldStyle;
    final t = context.appTextStyles;

    final hasText = widget.controller.text.isNotEmpty;

    final Color background = widget.isDisabled
        ? s.disabledBackgroundColor
        : s.backgroundColor;
    final Color textColor = widget.isDisabled ? s.disabledTextColor : s.textColor;

    final IconData? actionIcon;
    final VoidCallback? actionTap;
    if (hasText && widget.onSend != null) {
      actionIcon = Icons.send;
      actionTap = widget.isDisabled ? null : widget.onSend;
    } else if (!hasText && widget.onMic != null) {
      actionIcon = Icons.mic;
      actionTap = widget.isDisabled ? null : widget.onMic;
    } else {
      actionIcon = null;
      actionTap = null;
    }

    return Container(
      constraints: BoxConstraints(minHeight: s.minHeight),
      padding: EdgeInsets.all(s.padding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(s.borderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: s.itemSpacing + 2,
                right: s.itemSpacing,
                top: 8,
                bottom: 8,
              ),
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isDisabled,
                onChanged: widget.onChanged,
                style: t.s14w400(color: textColor),
                cursorColor: s.textColor,
                minLines: 1,
                maxLines: widget.maxLines,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.placeholder,
                  hintStyle: t.s14w400(color: s.placeholderColor),
                ),
              ),
            ),
          ),
          if (actionIcon != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: actionTap,
              child: Container(
                width: s.actionButtonSize,
                height: s.actionButtonSize,
                decoration: BoxDecoration(
                  color: s.actionButtonBackgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  actionIcon,
                  size: s.iconSize,
                  color: s.actionIconColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
