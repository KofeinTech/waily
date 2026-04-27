import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Progress bar style tokens for the dark Waily theme.
///
/// Consumed by `WailyProgressBar` to render the Figma `Progress Bar` instance.
/// Figma shows the bar as a flat white pill at full state — track color is
/// inferred (surfaceVariant) so partial fills remain visible on the app
/// background.
@immutable
class AppProgressBarStyle extends ThemeExtension<AppProgressBarStyle> {
  const AppProgressBarStyle._({
    required this.height,
    required this.fillColor,
    required this.trackColor,
  });

  /// Bar thickness. Figma: 8.
  final double height;

  /// Filled portion color. Figma: white.
  final Color fillColor;

  /// Background portion color (track). Inferred — Figma renders the bar at
  /// 100%, so the track is not directly visible there.
  final Color trackColor;

  factory AppProgressBarStyle.dark() => const AppProgressBarStyle._(
    height: 8,
    fillColor: AppColors.white,
    trackColor: AppColors.surfaceVariant,
  );

  @override
  AppProgressBarStyle copyWith({
    double? height,
    Color? fillColor,
    Color? trackColor,
  }) => AppProgressBarStyle._(
    height: height ?? this.height,
    fillColor: fillColor ?? this.fillColor,
    trackColor: trackColor ?? this.trackColor,
  );

  @override
  AppProgressBarStyle lerp(
    ThemeExtension<AppProgressBarStyle>? other,
    double t,
  ) {
    if (other is! AppProgressBarStyle) return this;
    return AppProgressBarStyle._(
      height: t < 0.5 ? height : other.height,
      fillColor: Color.lerp(fillColor, other.fillColor, t) ?? fillColor,
      trackColor: Color.lerp(trackColor, other.trackColor, t) ?? trackColor,
    );
  }
}
