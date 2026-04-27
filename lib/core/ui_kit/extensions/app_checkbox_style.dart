import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Checkbox style tokens for the dark Waily theme.
///
/// Consumed by `WailyCheckbox` to render the Figma `Check Box` component-set.
/// Note: Figma renders the control as a 24x24 CIRCLE (cornerRadius 999) — not
/// a rounded square as the plan implied. Default is a hollow ring; Active is
/// a solid disc with a white checkmark inside.
@immutable
class AppCheckboxStyle extends ThemeExtension<AppCheckboxStyle> {
  const AppCheckboxStyle._({
    required this.size,
    required this.iconSize,
    required this.defaultFillColor,
    required this.defaultBorderColor,
    required this.activeFillColor,
    required this.disabledFillColor,
    required this.disabledBorderColor,
    required this.checkmarkColor,
    required this.disabledCheckmarkColor,
    required this.borderWidth,
  });

  /// Outer control size. Figma: 24x24.
  final double size;

  /// Inner checkmark icon size. Figma: 16x16.
  final double iconSize;

  /// Fill of the unchecked state — transparent in Figma.
  final Color defaultFillColor;

  /// Border color of the unchecked state. Figma: #3D475E (borderStrong).
  final Color defaultBorderColor;

  /// Solid disc fill when checked. Figma: #3D475E (borderStrong).
  final Color activeFillColor;

  /// Disabled fill when checked.
  final Color disabledFillColor;

  /// Disabled border when unchecked.
  final Color disabledBorderColor;

  /// Checkmark glyph color when active. Figma: #FFFFFF.
  final Color checkmarkColor;

  /// Checkmark glyph color when disabled + active.
  final Color disabledCheckmarkColor;

  /// Default-state ring stroke width.
  final double borderWidth;

  factory AppCheckboxStyle.dark() => const AppCheckboxStyle._(
    size: 24,
    iconSize: 16,
    defaultFillColor: Color(0x00000000),
    defaultBorderColor: AppColors.borderStrong,
    activeFillColor: AppColors.borderStrong,
    disabledFillColor: AppColors.textDisabled,
    disabledBorderColor: AppColors.textDisabled,
    checkmarkColor: AppColors.white,
    disabledCheckmarkColor: AppColors.textSecondary,
    borderWidth: 1,
  );

  @override
  AppCheckboxStyle copyWith({
    double? size,
    double? iconSize,
    Color? defaultFillColor,
    Color? defaultBorderColor,
    Color? activeFillColor,
    Color? disabledFillColor,
    Color? disabledBorderColor,
    Color? checkmarkColor,
    Color? disabledCheckmarkColor,
    double? borderWidth,
  }) => AppCheckboxStyle._(
    size: size ?? this.size,
    iconSize: iconSize ?? this.iconSize,
    defaultFillColor: defaultFillColor ?? this.defaultFillColor,
    defaultBorderColor: defaultBorderColor ?? this.defaultBorderColor,
    activeFillColor: activeFillColor ?? this.activeFillColor,
    disabledFillColor: disabledFillColor ?? this.disabledFillColor,
    disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
    checkmarkColor: checkmarkColor ?? this.checkmarkColor,
    disabledCheckmarkColor:
        disabledCheckmarkColor ?? this.disabledCheckmarkColor,
    borderWidth: borderWidth ?? this.borderWidth,
  );

  @override
  AppCheckboxStyle lerp(ThemeExtension<AppCheckboxStyle>? other, double t) {
    if (other is! AppCheckboxStyle) return this;
    return AppCheckboxStyle._(
      size: t < 0.5 ? size : other.size,
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      defaultFillColor:
          Color.lerp(defaultFillColor, other.defaultFillColor, t) ??
          defaultFillColor,
      defaultBorderColor:
          Color.lerp(defaultBorderColor, other.defaultBorderColor, t) ??
          defaultBorderColor,
      activeFillColor:
          Color.lerp(activeFillColor, other.activeFillColor, t) ??
          activeFillColor,
      disabledFillColor:
          Color.lerp(disabledFillColor, other.disabledFillColor, t) ??
          disabledFillColor,
      disabledBorderColor:
          Color.lerp(disabledBorderColor, other.disabledBorderColor, t) ??
          disabledBorderColor,
      checkmarkColor:
          Color.lerp(checkmarkColor, other.checkmarkColor, t) ?? checkmarkColor,
      disabledCheckmarkColor:
          Color.lerp(
            disabledCheckmarkColor,
            other.disabledCheckmarkColor,
            t,
          ) ??
          disabledCheckmarkColor,
      borderWidth: t < 0.5 ? borderWidth : other.borderWidth,
    );
  }
}
