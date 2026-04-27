import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Digit box style tokens for the dark Waily theme.
///
/// Consumed by `WailyDigitBox` to render the Figma `digit box` component-set:
/// `state` ∈ {Default, Filled, Active, Error}.
@immutable
class AppDigitBoxStyle extends ThemeExtension<AppDigitBoxStyle> {
  const AppDigitBoxStyle._({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.padding,
    required this.borderWidth,
    required this.filledBackgroundColor,
    required this.errorBackgroundColor,
    required this.activeBorderColor,
    required this.errorBorderColor,
    required this.digitColor,
    required this.cursorColor,
  });

  /// Box width. Figma: 48.
  final double width;

  /// Box height. Figma: 52.
  final double height;

  /// Corner radius. Figma: 8.
  final double borderRadius;

  /// Inner inset. Figma: 12.
  final double padding;

  /// Border thickness used by Active and Error states.
  final double borderWidth;

  /// Background for Default / Filled / Active. Figma: white at 12% opacity.
  final Color filledBackgroundColor;

  /// Background for Error state. Figma: transparent.
  final Color errorBackgroundColor;

  /// Border color for Active state. Figma: AppColors.primary (#D4E1FF).
  final Color activeBorderColor;

  /// Border color for Error state. Figma: AppColors.error (#D52D2D).
  final Color errorBorderColor;

  /// Glyph color for Filled / Error states. Figma: white.
  final Color digitColor;

  /// Glyph color for the Active state's cursor character. Figma: white.
  final Color cursorColor;

  factory AppDigitBoxStyle.dark() => AppDigitBoxStyle._(
    width: 48,
    height: 52,
    borderRadius: AppBorderRadius.s,
    padding: 12,
    borderWidth: 1,
    filledBackgroundColor: AppColors.white.withValues(alpha: 0.12),
    errorBackgroundColor: const Color(0x00000000),
    activeBorderColor: AppColors.primary,
    errorBorderColor: AppColors.error,
    digitColor: AppColors.white,
    cursorColor: AppColors.white,
  );

  @override
  AppDigitBoxStyle copyWith({
    double? width,
    double? height,
    double? borderRadius,
    double? padding,
    double? borderWidth,
    Color? filledBackgroundColor,
    Color? errorBackgroundColor,
    Color? activeBorderColor,
    Color? errorBorderColor,
    Color? digitColor,
    Color? cursorColor,
  }) => AppDigitBoxStyle._(
    width: width ?? this.width,
    height: height ?? this.height,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    borderWidth: borderWidth ?? this.borderWidth,
    filledBackgroundColor:
        filledBackgroundColor ?? this.filledBackgroundColor,
    errorBackgroundColor: errorBackgroundColor ?? this.errorBackgroundColor,
    activeBorderColor: activeBorderColor ?? this.activeBorderColor,
    errorBorderColor: errorBorderColor ?? this.errorBorderColor,
    digitColor: digitColor ?? this.digitColor,
    cursorColor: cursorColor ?? this.cursorColor,
  );

  @override
  AppDigitBoxStyle lerp(ThemeExtension<AppDigitBoxStyle>? other, double t) {
    if (other is! AppDigitBoxStyle) return this;
    return AppDigitBoxStyle._(
      width: t < 0.5 ? width : other.width,
      height: t < 0.5 ? height : other.height,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: t < 0.5 ? padding : other.padding,
      borderWidth: t < 0.5 ? borderWidth : other.borderWidth,
      filledBackgroundColor:
          Color.lerp(
            filledBackgroundColor,
            other.filledBackgroundColor,
            t,
          ) ??
          filledBackgroundColor,
      errorBackgroundColor:
          Color.lerp(errorBackgroundColor, other.errorBackgroundColor, t) ??
          errorBackgroundColor,
      activeBorderColor:
          Color.lerp(activeBorderColor, other.activeBorderColor, t) ??
          activeBorderColor,
      errorBorderColor:
          Color.lerp(errorBorderColor, other.errorBorderColor, t) ??
          errorBorderColor,
      digitColor: Color.lerp(digitColor, other.digitColor, t) ?? digitColor,
      cursorColor:
          Color.lerp(cursorColor, other.cursorColor, t) ?? cursorColor,
    );
  }
}
