import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Selector style tokens for the dark Waily theme.
///
/// Consumed by `WailySelector` to render the Figma `Selector` component-set.
/// The selector is a text-only toggle: weight + color swap between Default
/// and Active states.
@immutable
class AppSelectorStyle extends ThemeExtension<AppSelectorStyle> {
  const AppSelectorStyle._({
    required this.defaultColor,
    required this.activeColor,
    required this.disabledColor,
  });

  /// Default text color. Figma: AppColors.textPlaceholder (#646C7E).
  final Color defaultColor;

  /// Active text color. Figma: white.
  final Color activeColor;

  /// Disabled text color.
  final Color disabledColor;

  factory AppSelectorStyle.dark() => const AppSelectorStyle._(
    defaultColor: AppColors.textPlaceholder,
    activeColor: AppColors.white,
    disabledColor: AppColors.textDisabled,
  );

  @override
  AppSelectorStyle copyWith({
    Color? defaultColor,
    Color? activeColor,
    Color? disabledColor,
  }) => AppSelectorStyle._(
    defaultColor: defaultColor ?? this.defaultColor,
    activeColor: activeColor ?? this.activeColor,
    disabledColor: disabledColor ?? this.disabledColor,
  );

  @override
  AppSelectorStyle lerp(ThemeExtension<AppSelectorStyle>? other, double t) {
    if (other is! AppSelectorStyle) return this;
    return AppSelectorStyle._(
      defaultColor:
          Color.lerp(defaultColor, other.defaultColor, t) ?? defaultColor,
      activeColor:
          Color.lerp(activeColor, other.activeColor, t) ?? activeColor,
      disabledColor:
          Color.lerp(disabledColor, other.disabledColor, t) ?? disabledColor,
    );
  }
}
