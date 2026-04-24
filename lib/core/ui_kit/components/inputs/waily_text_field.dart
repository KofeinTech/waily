import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// App-wide text input widget.
///
/// All visual properties read from [AppInputStyle] — no Material defaults.
/// State (controller, focus) is managed externally.
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
    this.errorText,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final s = context.appInputStyle;
    final radius = BorderRadius.circular(s.borderRadius);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: s.inputStyle,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: s.fillColor,
        labelStyle: s.labelStyle,
        hintStyle: s.hintStyle,
        errorStyle: s.errorStyle,
        contentPadding: s.contentPadding,
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.focusedBorderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.errorBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.errorBorderColor),
        ),
      ),
    );
  }
}
