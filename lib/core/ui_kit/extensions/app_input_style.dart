import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_border_radius.dart';

/// Input field style tokens for the dark Waily theme.
///
/// Consumed by [WailyTextField] to build [InputDecoration] without Material defaults.
@immutable
class AppInputStyle extends ThemeExtension<AppInputStyle> {
  const AppInputStyle._({
    required this.fillColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.borderRadius,
    required this.contentPadding,
    required this.labelStyle,
    required this.inputStyle,
    required this.hintStyle,
  });

  final Color fillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final TextStyle labelStyle;
  final TextStyle inputStyle;
  final TextStyle hintStyle;

  factory AppInputStyle.dark() => AppInputStyle._(
    fillColor:           AppColors.surface,
    borderColor:         AppColors.border,
    focusedBorderColor:  AppColors.primary,
    errorBorderColor:    AppColors.error,
    borderRadius:        AppBorderRadius.m,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.m,
      vertical: AppSpacing.m,
    ),
    labelStyle: AppTypography.s14w400(color: AppColors.textSecondary),
    inputStyle: AppTypography.s16w400(color: AppColors.textPrimary),
    hintStyle:  AppTypography.s16w400(color: AppColors.textDisabled),
  );

  @override
  AppInputStyle copyWith({
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    double? borderRadius,
    EdgeInsets? contentPadding,
    TextStyle? labelStyle,
    TextStyle? inputStyle,
    TextStyle? hintStyle,
  }) => AppInputStyle._(
    fillColor:           fillColor           ?? this.fillColor,
    borderColor:         borderColor         ?? this.borderColor,
    focusedBorderColor:  focusedBorderColor  ?? this.focusedBorderColor,
    errorBorderColor:    errorBorderColor    ?? this.errorBorderColor,
    borderRadius:        borderRadius        ?? this.borderRadius,
    contentPadding:      contentPadding      ?? this.contentPadding,
    labelStyle:          labelStyle          ?? this.labelStyle,
    inputStyle:          inputStyle          ?? this.inputStyle,
    hintStyle:           hintStyle           ?? this.hintStyle,
  );

  @override
  AppInputStyle lerp(ThemeExtension<AppInputStyle>? other, double t) {
    if (other is! AppInputStyle) return this;
    return AppInputStyle._(
      fillColor:          Color.lerp(fillColor,          other.fillColor,          t) ?? fillColor,
      borderColor:        Color.lerp(borderColor,        other.borderColor,        t) ?? borderColor,
      focusedBorderColor: Color.lerp(focusedBorderColor, other.focusedBorderColor, t) ?? focusedBorderColor,
      errorBorderColor:   Color.lerp(errorBorderColor,   other.errorBorderColor,   t) ?? errorBorderColor,
      borderRadius:       t < 0.5 ? borderRadius : other.borderRadius,
      contentPadding:     EdgeInsets.lerp(contentPadding, other.contentPadding, t) ?? contentPadding,
      labelStyle:         TextStyle.lerp(labelStyle, other.labelStyle, t) ?? labelStyle,
      inputStyle:         TextStyle.lerp(inputStyle, other.inputStyle, t) ?? inputStyle,
      hintStyle:          TextStyle.lerp(hintStyle,  other.hintStyle,  t) ?? hintStyle,
    );
  }
}
