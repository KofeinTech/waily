import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Theme-aware color roles for the dark Waily theme.
///
/// Example:
/// ```dart
/// Container(color: context.appColors.background)
/// ```
@immutable
class AppColorStyle extends ThemeExtension<AppColorStyle> {
  const AppColorStyle._({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.primaryLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.error,
    required this.success,
    required this.icon,
    required this.iconDisabled,
    required this.border,
    required this.divider,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color primaryLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color error;
  final Color success;
  final Color icon;
  final Color iconDisabled;
  final Color border;
  final Color divider;

  /// Dark theme color assignments.
  factory AppColorStyle.dark() => const AppColorStyle._(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textDisabled: AppColors.textDisabled,
    error: AppColors.error,
    success: AppColors.success,
    icon: AppColors.textSecondary,
    iconDisabled: AppColors.textDisabled,
    border: AppColors.border,
    divider: AppColors.surfaceVariant,
  );

  @override
  AppColorStyle copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? primary,
    Color? primaryLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? error,
    Color? success,
    Color? icon,
    Color? iconDisabled,
    Color? border,
    Color? divider,
  }) => AppColorStyle._(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    primary: primary ?? this.primary,
    primaryLight: primaryLight ?? this.primaryLight,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textDisabled: textDisabled ?? this.textDisabled,
    error: error ?? this.error,
    success: success ?? this.success,
    icon: icon ?? this.icon,
    iconDisabled: iconDisabled ?? this.iconDisabled,
    border: border ?? this.border,
    divider: divider ?? this.divider,
  );

  @override
  AppColorStyle lerp(ThemeExtension<AppColorStyle>? other, double t) {
    if (other is! AppColorStyle) return this;
    return AppColorStyle._(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceVariant:
          Color.lerp(surfaceVariant, other.surfaceVariant, t) ?? surfaceVariant,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryLight:
          Color.lerp(primaryLight, other.primaryLight, t) ?? primaryLight,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textDisabled:
          Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      error: Color.lerp(error, other.error, t) ?? error,
      success: Color.lerp(success, other.success, t) ?? success,
      icon: Color.lerp(icon, other.icon, t) ?? icon,
      iconDisabled:
          Color.lerp(iconDisabled, other.iconDisabled, t) ?? iconDisabled,
      border: Color.lerp(border, other.border, t) ?? border,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
    );
  }
}
