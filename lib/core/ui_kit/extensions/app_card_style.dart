import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_border_radius.dart';

/// Card style tokens for the dark Waily theme.
///
/// Consumed by [WailyCard].
@immutable
class AppCardStyle extends ThemeExtension<AppCardStyle> {
  const AppCardStyle._({
    required this.backgroundColor,
    required this.shadowColor,
    required this.borderRadius,
    required this.padding,
    required this.elevation,
  });

  final Color backgroundColor;
  final Color shadowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;

  factory AppCardStyle.dark() => AppCardStyle._(
    backgroundColor: AppColors.surface,
    shadowColor:     AppColors.black.withValues(alpha: 0.2),
    borderRadius:    AppBorderRadius.l,
    padding:         const EdgeInsets.all(AppSpacing.m),
    elevation:       0.0,
  );

  @override
  AppCardStyle copyWith({
    Color? backgroundColor,
    Color? shadowColor,
    double? borderRadius,
    EdgeInsets? padding,
    double? elevation,
  }) => AppCardStyle._(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    shadowColor:     shadowColor     ?? this.shadowColor,
    borderRadius:    borderRadius    ?? this.borderRadius,
    padding:         padding         ?? this.padding,
    elevation:       elevation       ?? this.elevation,
  );

  @override
  AppCardStyle lerp(ThemeExtension<AppCardStyle>? other, double t) {
    if (other is! AppCardStyle) return this;
    return AppCardStyle._(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ?? backgroundColor,
      shadowColor:     Color.lerp(shadowColor,     other.shadowColor,     t) ?? shadowColor,
      borderRadius:    t < 0.5 ? borderRadius : other.borderRadius,
      padding:         EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      elevation:       lerpDouble(elevation, other.elevation, t) ?? elevation,
    );
  }
}
