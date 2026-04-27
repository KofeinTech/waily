import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';
import '../../theme/app_spacing.dart';

/// Visual variant of [WailyTextField], matching the Figma `Input field`
/// `Type` axis.
enum WailyTextFieldVariant { primary, secondary }

/// App-wide text input widget.
///
/// All visual properties read from [AppInputStyle] — no Material defaults.
/// State (controller, focus) is managed externally.
///
/// Variant + state map to the Figma `Input field` component-set:
/// `Type` ∈ {Primary, Secondary} ×
/// `State` ∈ {Default, Active, Filled, Disabled, Error}.
///
/// Example:
/// ```dart
/// WailyTextField(
///   label: 'Email',
///   hint: 'you@example.com',
///   controller: _emailController,
///   errorText: _emailError,
/// )
/// ```
class WailyTextField extends StatelessWidget {
  const WailyTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.onChanged,
    this.keyboardType,
    this.variant = WailyTextFieldVariant.primary,
  });

  /// Minimum input box height. Matches the inner "Input field" frame in
  /// Figma (the box without the label slot above it).
  static const double _primaryMinHeight = 52;

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final WailyTextFieldVariant variant;

  bool get _isSecondary => variant == WailyTextFieldVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final s = context.appInputStyle;
    final radius = BorderRadius.circular(s.borderRadius);

    final fillColor = _isSecondary ? s.secondaryFillColor : s.fillColor;
    final idleBorderColor = _isSecondary
        ? s.secondaryBorderColor
        : s.borderColor;

    OutlineInputBorder borderWith(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color),
    );

    final InputDecoration decoration = InputDecoration(
      // Primary renders its own label above the box; Secondary uses Material's
      // labelText slot to keep the field compact.
      labelText: _isSecondary ? label : null,
      hintText: hint,
      errorText: errorText,
      filled: true,
      fillColor: fillColor,
      labelStyle: s.labelStyle,
      hintStyle: s.hintStyle,
      errorStyle: s.errorStyle,
      contentPadding: s.contentPadding,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      isDense: true,
      border: borderWith(idleBorderColor),
      enabledBorder: borderWith(idleBorderColor),
      focusedBorder: borderWith(s.focusedBorderColor),
      disabledBorder: borderWith(idleBorderColor),
      errorBorder: borderWith(s.errorBorderColor),
      focusedErrorBorder: borderWith(s.errorBorderColor),
    );

    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: s.inputStyle,
      decoration: decoration,
    );

    if (_isSecondary) {
      return field;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _primaryMinHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(label!, style: s.labelStyle),
            const SizedBox(height: AppSpacing.s),
          ],
          field,
        ],
      ),
    );
  }
}
