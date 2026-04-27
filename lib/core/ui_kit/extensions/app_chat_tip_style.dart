import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Chat tip style tokens for the dark Waily theme.
///
/// Consumed by `WailyChatTip` to render the Figma `Chat Tip` component-set:
/// `State` ∈ {Default, Active, Disabled}.
@immutable
class AppChatTipStyle extends ThemeExtension<AppChatTipStyle> {
  const AppChatTipStyle._({
    required this.borderRadius,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.defaultBackgroundColor,
    required this.activeBackgroundColor,
    required this.disabledBackgroundColor,
    required this.defaultTextColor,
    required this.activeTextColor,
    required this.disabledTextColor,
  });

  /// Card corner radius. Figma: 12.
  final double borderRadius;

  /// Horizontal padding. Figma: 12.
  final double horizontalPadding;

  /// Vertical padding. Figma: 8.
  final double verticalPadding;

  /// Default background — Figma: white at 6% opacity.
  final Color defaultBackgroundColor;

  /// Active background — Figma: AppColors.primaryLowest (#E5EDFF).
  final Color activeBackgroundColor;

  /// Disabled background — Figma: AppColors.textSecondary (#9EA3AE).
  final Color disabledBackgroundColor;

  /// Default text color (s14w400). Figma: white.
  final Color defaultTextColor;

  /// Active text color. Figma: AppColors.background (#020815).
  final Color activeTextColor;

  /// Disabled text color. Figma: AppColors.textPlaceholder (#646C7E).
  final Color disabledTextColor;

  factory AppChatTipStyle.dark() => AppChatTipStyle._(
    borderRadius: AppBorderRadius.m,
    horizontalPadding: 12,
    verticalPadding: 8,
    defaultBackgroundColor: AppColors.white.withValues(alpha: 0.06),
    activeBackgroundColor: AppColors.primaryLowest,
    disabledBackgroundColor: AppColors.textSecondary,
    defaultTextColor: AppColors.white,
    activeTextColor: AppColors.background,
    disabledTextColor: AppColors.textPlaceholder,
  );

  @override
  AppChatTipStyle copyWith({
    double? borderRadius,
    double? horizontalPadding,
    double? verticalPadding,
    Color? defaultBackgroundColor,
    Color? activeBackgroundColor,
    Color? disabledBackgroundColor,
    Color? defaultTextColor,
    Color? activeTextColor,
    Color? disabledTextColor,
  }) => AppChatTipStyle._(
    borderRadius: borderRadius ?? this.borderRadius,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    verticalPadding: verticalPadding ?? this.verticalPadding,
    defaultBackgroundColor:
        defaultBackgroundColor ?? this.defaultBackgroundColor,
    activeBackgroundColor:
        activeBackgroundColor ?? this.activeBackgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    defaultTextColor: defaultTextColor ?? this.defaultTextColor,
    activeTextColor: activeTextColor ?? this.activeTextColor,
    disabledTextColor: disabledTextColor ?? this.disabledTextColor,
  );

  @override
  AppChatTipStyle lerp(ThemeExtension<AppChatTipStyle>? other, double t) {
    if (other is! AppChatTipStyle) return this;
    return AppChatTipStyle._(
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      horizontalPadding: t < 0.5 ? horizontalPadding : other.horizontalPadding,
      verticalPadding: t < 0.5 ? verticalPadding : other.verticalPadding,
      defaultBackgroundColor:
          Color.lerp(
            defaultBackgroundColor,
            other.defaultBackgroundColor,
            t,
          ) ??
          defaultBackgroundColor,
      activeBackgroundColor:
          Color.lerp(activeBackgroundColor, other.activeBackgroundColor, t) ??
          activeBackgroundColor,
      disabledBackgroundColor:
          Color.lerp(
            disabledBackgroundColor,
            other.disabledBackgroundColor,
            t,
          ) ??
          disabledBackgroundColor,
      defaultTextColor:
          Color.lerp(defaultTextColor, other.defaultTextColor, t) ??
          defaultTextColor,
      activeTextColor:
          Color.lerp(activeTextColor, other.activeTextColor, t) ??
          activeTextColor,
      disabledTextColor:
          Color.lerp(disabledTextColor, other.disabledTextColor, t) ??
          disabledTextColor,
    );
  }
}
