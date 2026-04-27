import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Text input style tokens for the dark Waily theme.
///
/// Consumed by `WailyTextInput` to render the Figma `Text Input` component-set
/// (distinct from `Input field` which powers `WailyTextField`). Card-shaped
/// container with a translucent fill, white stroke, and trailing clear icon.
@immutable
class AppTextInputStyle extends ThemeExtension<AppTextInputStyle> {
  const AppTextInputStyle._({
    required this.height,
    required this.borderRadius,
    required this.padding,
    required this.itemSpacing,
    required this.iconSize,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
    required this.defaultBorderColor,
    required this.activeBorderColor,
    required this.errorBorderColor,
    required this.disabledBorderColor,
    required this.labelColor,
    required this.placeholderColor,
    required this.inputColor,
    required this.disabledInputColor,
    required this.iconColor,
    required this.disabledIconColor,
  });

  /// Container height. Figma: 70.
  final double height;

  /// Container corner radius. Figma: 14.
  final double borderRadius;

  /// Inner inset. Figma: 12.
  final double padding;

  /// Vertical gap between label and body text. Figma: 8.
  final double itemSpacing;

  /// Trailing clear icon canvas. Figma: 20x20.
  final double iconSize;

  /// Container fill — Figma renders white at 4% opacity.
  final Color backgroundColor;

  /// Container fill while disabled.
  final Color disabledBackgroundColor;

  /// Border color in default and filled states. Figma: white.
  final Color defaultBorderColor;

  /// Border color when focused/active. Figma: AppColors.primary.
  final Color activeBorderColor;

  /// Border color in error state. Figma: AppColors.error.
  final Color errorBorderColor;

  /// Border color when disabled.
  final Color disabledBorderColor;

  /// Optional label color (rendered above the input).
  final Color labelColor;

  /// Placeholder text color when input is empty/inactive.
  final Color placeholderColor;

  /// Input glyph color when focused or filled.
  final Color inputColor;

  /// Input glyph color when disabled.
  final Color disabledInputColor;

  /// Trailing clear icon color.
  final Color iconColor;

  /// Trailing clear icon color when disabled.
  final Color disabledIconColor;

  factory AppTextInputStyle.dark() => AppTextInputStyle._(
    height: 70,
    borderRadius: 14,
    padding: 12,
    itemSpacing: 8,
    iconSize: 20,
    backgroundColor: AppColors.white.withValues(alpha: 0.04),
    disabledBackgroundColor: AppColors.white.withValues(alpha: 0.02),
    defaultBorderColor: AppColors.white,
    activeBorderColor: AppColors.primary,
    errorBorderColor: AppColors.error,
    disabledBorderColor: AppColors.textDisabled,
    labelColor: AppColors.textSecondary,
    placeholderColor: AppColors.textSecondary,
    inputColor: AppColors.white,
    disabledInputColor: AppColors.textDisabled,
    iconColor: AppColors.white,
    disabledIconColor: AppColors.textDisabled,
  );

  @override
  AppTextInputStyle copyWith({
    double? height,
    double? borderRadius,
    double? padding,
    double? itemSpacing,
    double? iconSize,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? defaultBorderColor,
    Color? activeBorderColor,
    Color? errorBorderColor,
    Color? disabledBorderColor,
    Color? labelColor,
    Color? placeholderColor,
    Color? inputColor,
    Color? disabledInputColor,
    Color? iconColor,
    Color? disabledIconColor,
  }) => AppTextInputStyle._(
    height: height ?? this.height,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    iconSize: iconSize ?? this.iconSize,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    defaultBorderColor: defaultBorderColor ?? this.defaultBorderColor,
    activeBorderColor: activeBorderColor ?? this.activeBorderColor,
    errorBorderColor: errorBorderColor ?? this.errorBorderColor,
    disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
    labelColor: labelColor ?? this.labelColor,
    placeholderColor: placeholderColor ?? this.placeholderColor,
    inputColor: inputColor ?? this.inputColor,
    disabledInputColor: disabledInputColor ?? this.disabledInputColor,
    iconColor: iconColor ?? this.iconColor,
    disabledIconColor: disabledIconColor ?? this.disabledIconColor,
  );

  @override
  AppTextInputStyle lerp(
    ThemeExtension<AppTextInputStyle>? other,
    double t,
  ) {
    if (other is! AppTextInputStyle) return this;
    return AppTextInputStyle._(
      height: t < 0.5 ? height : other.height,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: t < 0.5 ? padding : other.padding,
      itemSpacing: t < 0.5 ? itemSpacing : other.itemSpacing,
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      disabledBackgroundColor:
          Color.lerp(
            disabledBackgroundColor,
            other.disabledBackgroundColor,
            t,
          ) ??
          disabledBackgroundColor,
      defaultBorderColor:
          Color.lerp(defaultBorderColor, other.defaultBorderColor, t) ??
          defaultBorderColor,
      activeBorderColor:
          Color.lerp(activeBorderColor, other.activeBorderColor, t) ??
          activeBorderColor,
      errorBorderColor:
          Color.lerp(errorBorderColor, other.errorBorderColor, t) ??
          errorBorderColor,
      disabledBorderColor:
          Color.lerp(disabledBorderColor, other.disabledBorderColor, t) ??
          disabledBorderColor,
      labelColor: Color.lerp(labelColor, other.labelColor, t) ?? labelColor,
      placeholderColor:
          Color.lerp(placeholderColor, other.placeholderColor, t) ??
          placeholderColor,
      inputColor: Color.lerp(inputColor, other.inputColor, t) ?? inputColor,
      disabledInputColor:
          Color.lerp(disabledInputColor, other.disabledInputColor, t) ??
          disabledInputColor,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      disabledIconColor:
          Color.lerp(disabledIconColor, other.disabledIconColor, t) ??
          disabledIconColor,
    );
  }
}
