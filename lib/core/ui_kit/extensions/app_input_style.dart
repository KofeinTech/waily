import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_border_radius.dart';

/// Input field style tokens for the dark Waily theme.
///
/// Consumed by [WailyTextField] to build [InputDecoration] without Material
/// defaults.
///
/// Variants follow the Figma `Input field` component-set:
/// `Type` ∈ {Primary, Secondary} ×
/// `State` ∈ {Default, Active, Filled, Disabled, Error}.
@immutable
class AppInputStyle extends ThemeExtension<AppInputStyle> {
  const AppInputStyle._({
    required this.fillColor,
    required this.secondaryFillColor,
    required this.borderColor,
    required this.secondaryBorderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.borderRadius,
    required this.contentPadding,
    required this.labelStyle,
    required this.inputStyle,
    required this.hintStyle,
    required this.errorStyle,
  });

  /// Primary fill (Figma Input field / Type=Primary => `#FFFFFF`).
  final Color fillColor;

  /// Secondary fill (Figma Input field / Type=Secondary => `#7F8799`).
  final Color secondaryFillColor;

  /// Primary default/idle border (transparent — only Active/Error use a stroke).
  final Color borderColor;

  /// Secondary default/idle border.
  final Color secondaryBorderColor;

  /// Focused/Active stroke for both Primary and Secondary (Figma `#D4E1FF`).
  final Color focusedBorderColor;

  /// Error stroke for both Primary and Secondary (Figma `#D52D2D`).
  final Color errorBorderColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final TextStyle labelStyle;
  final TextStyle inputStyle;
  final TextStyle hintStyle;
  final TextStyle errorStyle;

  factory AppInputStyle.dark() => AppInputStyle._(
    // Primary fill in Figma is white (#FFFFFF). The dark app pairs that with
    // a subtle blue stroke when focused.
    fillColor: AppColors.white,
    // Secondary fill in Figma is #7F8799 (textTertiary).
    secondaryFillColor: AppColors.textTertiary,
    // Idle border is transparent in Figma `default` state.
    borderColor: const Color(0x00000000),
    secondaryBorderColor: const Color(0x00000000),
    // Active stroke matches `primary` (#D4E1FF).
    focusedBorderColor: AppColors.primary,
    errorBorderColor: AppColors.error,
    borderRadius: AppBorderRadius.m,
    // Figma padding (14h / 16v). 14 isn't a current AppSpacing token, but it
    // matches AppBorderRadius.ml (14); inlined for clarity.
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: AppSpacing.m,
    ),
    labelStyle: AppTypography.s16w400(color: AppColors.textSecondary),
    inputStyle: AppTypography.s16w400(color: AppColors.surfaceVariant),
    hintStyle: AppTypography.s16w400(color: AppColors.primary),
    errorStyle: AppTypography.s14w400(color: AppColors.error),
  );

  @override
  AppInputStyle copyWith({
    Color? fillColor,
    Color? secondaryFillColor,
    Color? borderColor,
    Color? secondaryBorderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    double? borderRadius,
    EdgeInsets? contentPadding,
    TextStyle? labelStyle,
    TextStyle? inputStyle,
    TextStyle? hintStyle,
    TextStyle? errorStyle,
  }) => AppInputStyle._(
    fillColor: fillColor ?? this.fillColor,
    secondaryFillColor: secondaryFillColor ?? this.secondaryFillColor,
    borderColor: borderColor ?? this.borderColor,
    secondaryBorderColor: secondaryBorderColor ?? this.secondaryBorderColor,
    focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
    errorBorderColor: errorBorderColor ?? this.errorBorderColor,
    borderRadius: borderRadius ?? this.borderRadius,
    contentPadding: contentPadding ?? this.contentPadding,
    labelStyle: labelStyle ?? this.labelStyle,
    inputStyle: inputStyle ?? this.inputStyle,
    hintStyle: hintStyle ?? this.hintStyle,
    errorStyle: errorStyle ?? this.errorStyle,
  );

  @override
  AppInputStyle lerp(ThemeExtension<AppInputStyle>? other, double t) {
    if (other is! AppInputStyle) return this;
    return AppInputStyle._(
      fillColor: Color.lerp(fillColor, other.fillColor, t) ?? fillColor,
      secondaryFillColor:
          Color.lerp(secondaryFillColor, other.secondaryFillColor, t) ??
          secondaryFillColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      secondaryBorderColor:
          Color.lerp(secondaryBorderColor, other.secondaryBorderColor, t) ??
          secondaryBorderColor,
      focusedBorderColor:
          Color.lerp(focusedBorderColor, other.focusedBorderColor, t) ??
          focusedBorderColor,
      errorBorderColor:
          Color.lerp(errorBorderColor, other.errorBorderColor, t) ??
          errorBorderColor,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      contentPadding:
          EdgeInsets.lerp(contentPadding, other.contentPadding, t) ??
          contentPadding,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t) ?? labelStyle,
      inputStyle: TextStyle.lerp(inputStyle, other.inputStyle, t) ?? inputStyle,
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t) ?? hintStyle,
      errorStyle: TextStyle.lerp(errorStyle, other.errorStyle, t) ?? errorStyle,
    );
  }
}
