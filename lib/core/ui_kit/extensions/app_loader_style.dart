import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Loader style tokens for the dark Waily theme.
///
/// Consumed by `WailyLoader` to render the Figma `Loader` component-set: a
/// 3-dot animated loop where one dot at a time switches from
/// [defaultDotColor] to [activeDotColor].
@immutable
class AppLoaderStyle extends ThemeExtension<AppLoaderStyle> {
  const AppLoaderStyle._({
    required this.dotSize,
    required this.dotSpacing,
    required this.defaultDotColor,
    required this.activeDotColor,
    required this.cycleDuration,
  });

  /// Diameter of each dot. Figma: 24.
  final double dotSize;

  /// Horizontal gap between dots. Figma: 20 (44 stride − 24 dot).
  final double dotSpacing;

  /// Idle (non-highlighted) dot color. Figma: AppColors.primary (#D4E1FF).
  final Color defaultDotColor;

  /// Highlighted dot color. Figma: AppColors.white.
  final Color activeDotColor;

  /// Full animation cycle. Picked to match the 5-frame Figma timing.
  final Duration cycleDuration;

  factory AppLoaderStyle.dark() => const AppLoaderStyle._(
    dotSize: 24,
    dotSpacing: 20,
    defaultDotColor: AppColors.primary,
    activeDotColor: AppColors.white,
    cycleDuration: Duration(milliseconds: 1200),
  );

  @override
  AppLoaderStyle copyWith({
    double? dotSize,
    double? dotSpacing,
    Color? defaultDotColor,
    Color? activeDotColor,
    Duration? cycleDuration,
  }) => AppLoaderStyle._(
    dotSize: dotSize ?? this.dotSize,
    dotSpacing: dotSpacing ?? this.dotSpacing,
    defaultDotColor: defaultDotColor ?? this.defaultDotColor,
    activeDotColor: activeDotColor ?? this.activeDotColor,
    cycleDuration: cycleDuration ?? this.cycleDuration,
  );

  @override
  AppLoaderStyle lerp(ThemeExtension<AppLoaderStyle>? other, double t) {
    if (other is! AppLoaderStyle) return this;
    return AppLoaderStyle._(
      dotSize: t < 0.5 ? dotSize : other.dotSize,
      dotSpacing: t < 0.5 ? dotSpacing : other.dotSpacing,
      defaultDotColor:
          Color.lerp(defaultDotColor, other.defaultDotColor, t) ??
          defaultDotColor,
      activeDotColor:
          Color.lerp(activeDotColor, other.activeDotColor, t) ?? activeDotColor,
      cycleDuration: t < 0.5 ? cycleDuration : other.cycleDuration,
    );
  }
}
