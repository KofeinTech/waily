import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Link style tokens for the dark Waily theme.
///
/// Consumed by `WailyLink` to render an inline tappable text without
/// Material defaults. Variants follow the Figma `Link` component-set:
/// `State` ∈ {Default, Pressed} plus a synthesized Disabled state.
@immutable
class AppLinkStyle extends ThemeExtension<AppLinkStyle> {
  const AppLinkStyle._({
    required this.colorDefault,
    required this.colorPressed,
    required this.colorDisabled,
    required this.verticalPadding,
  });

  /// Text color for Default state. Figma `Link / State=Default` text fill — #D4E1FF.
  final Color colorDefault;

  /// Text color for Pressed state. Figma `Link / State=Pressed` text fill — #E5EDFF.
  final Color colorPressed;

  /// Text color for the synthesized Disabled state — Figma has no disabled
  /// variant, so we reuse [AppColors.textDisabled] for parity with other atoms.
  final Color colorDisabled;

  /// Top/bottom padding around the label. Figma: 12 vertical, 0 horizontal.
  final double verticalPadding;

  factory AppLinkStyle.dark() => const AppLinkStyle._(
    colorDefault: AppColors.primary,
    colorPressed: AppColors.primaryLowest,
    colorDisabled: AppColors.textDisabled,
    verticalPadding: AppSpacing.sm,
  );

  @override
  AppLinkStyle copyWith({
    Color? colorDefault,
    Color? colorPressed,
    Color? colorDisabled,
    double? verticalPadding,
  }) => AppLinkStyle._(
    colorDefault: colorDefault ?? this.colorDefault,
    colorPressed: colorPressed ?? this.colorPressed,
    colorDisabled: colorDisabled ?? this.colorDisabled,
    verticalPadding: verticalPadding ?? this.verticalPadding,
  );

  @override
  AppLinkStyle lerp(ThemeExtension<AppLinkStyle>? other, double t) {
    if (other is! AppLinkStyle) return this;
    return AppLinkStyle._(
      colorDefault:
          Color.lerp(colorDefault, other.colorDefault, t) ?? colorDefault,
      colorPressed:
          Color.lerp(colorPressed, other.colorPressed, t) ?? colorPressed,
      colorDisabled:
          Color.lerp(colorDisabled, other.colorDisabled, t) ?? colorDisabled,
      verticalPadding: t < 0.5 ? verticalPadding : other.verticalPadding,
    );
  }
}
