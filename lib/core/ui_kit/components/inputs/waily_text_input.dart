import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';
import '../icons/waily_icon.dart';

/// Single-line text input with optional label and trailing clear icon.
///
/// Renders the Figma `Text Input` component-set (distinct from `Input field`
/// — see `WailyTextField` for that). Reads geometry/colors from
/// [AppTextInputStyle].
class WailyTextInput extends StatefulWidget {
  const WailyTextInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.onChanged,
    this.hasError = false,
    this.isDisabled = false,
  });

  final TextEditingController controller;

  /// Optional caption above the input. Hidden when null.
  final String? label;

  /// Placeholder shown while empty.
  final String? placeholder;

  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool isDisabled;

  @override
  State<WailyTextInput> createState() => _WailyTextInputState();
}

class _WailyTextInputState extends State<WailyTextInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() => setState(() {});
  void _onTextChange() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.appTextInputStyle;
    final t = context.appTextStyles;

    final hasFocus = _focusNode.hasFocus;
    final hasValue = widget.controller.text.isNotEmpty;

    final Color background;
    final Color borderColor;
    final Color inputColor;
    final Color iconColor;
    if (widget.isDisabled) {
      background = s.disabledBackgroundColor;
      borderColor = s.disabledBorderColor;
      inputColor = s.disabledInputColor;
      iconColor = s.disabledIconColor;
    } else if (widget.hasError) {
      background = s.backgroundColor;
      borderColor = s.errorBorderColor;
      inputColor = s.inputColor;
      iconColor = s.iconColor;
    } else if (hasFocus) {
      background = s.backgroundColor;
      borderColor = s.activeBorderColor;
      inputColor = s.inputColor;
      iconColor = s.iconColor;
    } else {
      background = s.backgroundColor;
      borderColor = s.defaultBorderColor;
      inputColor = s.inputColor;
      iconColor = s.iconColor;
    }

    return Container(
      constraints: BoxConstraints(minHeight: s.minHeight),
      padding: EdgeInsets.all(s.padding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(s.borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(widget.label!, style: t.s14w400(color: s.labelColor)),
            SizedBox(height: s.itemSpacing),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: !widget.isDisabled,
                  style: t.s14w400(color: inputColor),
                  cursorColor: s.inputColor,
                  onChanged: widget.onChanged,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: t.s14w400(color: s.placeholderColor),
                  ),
                ),
              ),
              if (hasValue && !widget.isDisabled) ...[
                SizedBox(width: s.itemSpacing),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _clear,
                  child: WailyIcon(
                    icon: Assets.icons.common.close,
                    size: s.iconSize,
                    color: iconColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
