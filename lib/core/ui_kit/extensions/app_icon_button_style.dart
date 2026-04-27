import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Icon button style tokens for the dark Waily theme.
///
/// Consumed by `WailyIconButton` to build icon-only button visuals without
/// Material defaults.
///
/// Variants follow the Figma `Icon button` component-set:
/// `Size` ∈ {Default, Big} × `State` ∈ {Default, Pressed, Disabled}.
@immutable
class AppIconButtonStyle extends ThemeExtension<AppIconButtonStyle> {
  const AppIconButtonStyle._({
    required this.backgroundColor,
    required this.iconColorDefault,
    required this.iconColorPressed,
    required this.iconColorDisabled,
    required this.borderRadius,
    required this.sizeDefault,
    required this.sizeBig,
    required this.iconSizeDefault,
    required this.iconSizeBig,
  });

  /// Container fill across all states. Figma reads as solid white at the
  /// resolved-token level, but the rendered `backgroundColor` is white at 6%
  /// opacity (same across Default / Pressed / Disabled variants).
  final Color backgroundColor;

  /// Icon foreground for Default state.
  final Color iconColorDefault;

  /// Icon foreground for Pressed state. Equal to [iconColorDefault] in Figma —
  /// kept as a separate field so the widget can swap on press if a future
  /// design diverges.
  final Color iconColorPressed;

  /// Icon foreground for Disabled state.
  final Color iconColorDisabled;

  /// Container corner radius. Figma: 12 across both sizes.
  final double borderRadius;

  /// Container width and height for `Size=Default` (Figma 48x48).
  final double sizeDefault;

  /// Container width and height for `Size=Big` (Figma 52x52).
  final double sizeBig;

  /// Icon canvas for `Size=Default` (Figma 24x24).
  final double iconSizeDefault;

  /// Icon canvas for `Size=Big` (Figma 28x28).
  final double iconSizeBig;

  factory AppIconButtonStyle.dark() => AppIconButtonStyle._(
    // Figma `Icon button` rendered background — white at 6% opacity.
    backgroundColor: AppColors.white.withValues(alpha: 0.06),
    // Figma `Icon button / State=Default` icon vector — #FFFFFF.
    iconColorDefault: AppColors.white,
    // Figma `Icon button / State=Pressed` icon vector — also #FFFFFF.
    iconColorPressed: AppColors.white,
    // Figma `Icon button / State=Disabled` icon vector — #9EA3AE.
    iconColorDisabled: AppColors.textSecondary,
    // Figma cornerRadius — 12 across all variants.
    borderRadius: AppBorderRadius.m,
    // Figma `Size=Default` — 48x48.
    sizeDefault: 48,
    // Figma `Size=Big` — 52x52.
    sizeBig: 52,
    // Figma Default size icon — 24x24.
    iconSizeDefault: 24,
    // Figma Big size icon — 28x28.
    iconSizeBig: 28,
  );

  @override
  AppIconButtonStyle copyWith({
    Color? backgroundColor,
    Color? iconColorDefault,
    Color? iconColorPressed,
    Color? iconColorDisabled,
    double? borderRadius,
    double? sizeDefault,
    double? sizeBig,
    double? iconSizeDefault,
    double? iconSizeBig,
  }) => AppIconButtonStyle._(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    iconColorDefault: iconColorDefault ?? this.iconColorDefault,
    iconColorPressed: iconColorPressed ?? this.iconColorPressed,
    iconColorDisabled: iconColorDisabled ?? this.iconColorDisabled,
    borderRadius: borderRadius ?? this.borderRadius,
    sizeDefault: sizeDefault ?? this.sizeDefault,
    sizeBig: sizeBig ?? this.sizeBig,
    iconSizeDefault: iconSizeDefault ?? this.iconSizeDefault,
    iconSizeBig: iconSizeBig ?? this.iconSizeBig,
  );

  @override
  AppIconButtonStyle lerp(ThemeExtension<AppIconButtonStyle>? other, double t) {
    if (other is! AppIconButtonStyle) return this;
    return AppIconButtonStyle._(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      iconColorDefault:
          Color.lerp(iconColorDefault, other.iconColorDefault, t) ??
          iconColorDefault,
      iconColorPressed:
          Color.lerp(iconColorPressed, other.iconColorPressed, t) ??
          iconColorPressed,
      iconColorDisabled:
          Color.lerp(iconColorDisabled, other.iconColorDisabled, t) ??
          iconColorDisabled,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      sizeDefault: t < 0.5 ? sizeDefault : other.sizeDefault,
      sizeBig: t < 0.5 ? sizeBig : other.sizeBig,
      iconSizeDefault: t < 0.5 ? iconSizeDefault : other.iconSizeDefault,
      iconSizeBig: t < 0.5 ? iconSizeBig : other.iconSizeBig,
    );
  }
}
