import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Slide button style tokens for the dark Waily theme.
///
/// Consumed by `WailySlideButton` to render the Figma `Slide Button`
/// component-set: a primary track with a draggable thumb that confirms an
/// action when dragged past a threshold.
@immutable
class AppSlideButtonStyle extends ThemeExtension<AppSlideButtonStyle> {
  const AppSlideButtonStyle._({
    required this.height,
    required this.borderRadius,
    required this.padding,
    required this.thumbWidth,
    required this.thumbBorderRadius,
    required this.iconSize,
    required this.confirmThreshold,
    required this.trackColor,
    required this.disabledTrackColor,
    required this.thumbHaloColor,
    required this.thumbGradientStart,
    required this.thumbGradientEnd,
    required this.iconColor,
    required this.disabledIconColor,
    required this.labelColor,
    required this.disabledLabelColor,
  });

  /// Track height. Figma: 52.
  final double height;

  /// Track corner radius. Figma: 12.
  final double borderRadius;

  /// Inset between track edge and thumb. Figma: 4.
  final double padding;

  /// Thumb width. Figma: 68.
  final double thumbWidth;

  /// Thumb corner radius. Figma: 12.
  final double thumbBorderRadius;

  /// Arrow icon canvas inside the thumb.
  final double iconSize;

  /// Fraction of the available track that must be covered before
  /// `onConfirm` fires. 0.0 disables the threshold; 1.0 requires a
  /// full slide.
  final double confirmThreshold;

  /// Track background. Figma: AppColors.primary (#D4E1FF).
  final Color trackColor;

  /// Track background while disabled.
  final Color disabledTrackColor;

  /// Soft halo behind the thumb during drag. Figma `Variant2` ellipse fill.
  final Color thumbHaloColor;

  /// Inner color of the thumb's radial gradient. Figma: `Blue/400` #646C7E.
  final Color thumbGradientStart;

  /// Outer color of the thumb's radial gradient. Figma: `Blue/600` #31394B.
  final Color thumbGradientEnd;

  /// Arrow icon color. Resolved against thumb fill (Figma: borderStrong
  /// when thumb is dark, surfaceVariant when light) — kept here as the
  /// arrow paint and ignored by widgets that use a transparent thumb.
  final Color iconColor;

  /// Arrow icon color while disabled.
  final Color disabledIconColor;

  /// Label color. Figma: AppColors.surfaceVariant (#252B38).
  final Color labelColor;

  /// Label color while disabled.
  final Color disabledLabelColor;

  factory AppSlideButtonStyle.dark() => const AppSlideButtonStyle._(
    height: 52,
    borderRadius: AppBorderRadius.m,
    padding: 4,
    thumbWidth: 68,
    thumbBorderRadius: AppBorderRadius.m,
    iconSize: 24,
    confirmThreshold: 0.9,
    trackColor: AppColors.primary,
    disabledTrackColor: AppColors.textDisabled,
    thumbHaloColor: AppColors.borderStrong,
    thumbGradientStart: AppColors.textPlaceholder,
    thumbGradientEnd: Color(0xFF31394B),
    iconColor: AppColors.white,
    disabledIconColor: AppColors.textDisabled,
    labelColor: AppColors.surfaceVariant,
    disabledLabelColor: AppColors.textDisabled,
  );

  @override
  AppSlideButtonStyle copyWith({
    double? height,
    double? borderRadius,
    double? padding,
    double? thumbWidth,
    double? thumbBorderRadius,
    double? iconSize,
    double? confirmThreshold,
    Color? trackColor,
    Color? disabledTrackColor,
    Color? thumbHaloColor,
    Color? thumbGradientStart,
    Color? thumbGradientEnd,
    Color? iconColor,
    Color? disabledIconColor,
    Color? labelColor,
    Color? disabledLabelColor,
  }) => AppSlideButtonStyle._(
    height: height ?? this.height,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    thumbWidth: thumbWidth ?? this.thumbWidth,
    thumbBorderRadius: thumbBorderRadius ?? this.thumbBorderRadius,
    iconSize: iconSize ?? this.iconSize,
    confirmThreshold: confirmThreshold ?? this.confirmThreshold,
    trackColor: trackColor ?? this.trackColor,
    disabledTrackColor: disabledTrackColor ?? this.disabledTrackColor,
    thumbHaloColor: thumbHaloColor ?? this.thumbHaloColor,
    thumbGradientStart: thumbGradientStart ?? this.thumbGradientStart,
    thumbGradientEnd: thumbGradientEnd ?? this.thumbGradientEnd,
    iconColor: iconColor ?? this.iconColor,
    disabledIconColor: disabledIconColor ?? this.disabledIconColor,
    labelColor: labelColor ?? this.labelColor,
    disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
  );

  @override
  AppSlideButtonStyle lerp(
    ThemeExtension<AppSlideButtonStyle>? other,
    double t,
  ) {
    if (other is! AppSlideButtonStyle) return this;
    return AppSlideButtonStyle._(
      height: t < 0.5 ? height : other.height,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: t < 0.5 ? padding : other.padding,
      thumbWidth: t < 0.5 ? thumbWidth : other.thumbWidth,
      thumbBorderRadius: t < 0.5
          ? thumbBorderRadius
          : other.thumbBorderRadius,
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      confirmThreshold: t < 0.5
          ? confirmThreshold
          : other.confirmThreshold,
      trackColor: Color.lerp(trackColor, other.trackColor, t) ?? trackColor,
      disabledTrackColor:
          Color.lerp(disabledTrackColor, other.disabledTrackColor, t) ??
          disabledTrackColor,
      thumbHaloColor:
          Color.lerp(thumbHaloColor, other.thumbHaloColor, t) ?? thumbHaloColor,
      thumbGradientStart:
          Color.lerp(thumbGradientStart, other.thumbGradientStart, t) ??
          thumbGradientStart,
      thumbGradientEnd:
          Color.lerp(thumbGradientEnd, other.thumbGradientEnd, t) ??
          thumbGradientEnd,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      disabledIconColor:
          Color.lerp(disabledIconColor, other.disabledIconColor, t) ??
          disabledIconColor,
      labelColor: Color.lerp(labelColor, other.labelColor, t) ?? labelColor,
      disabledLabelColor:
          Color.lerp(disabledLabelColor, other.disabledLabelColor, t) ??
          disabledLabelColor,
    );
  }
}
