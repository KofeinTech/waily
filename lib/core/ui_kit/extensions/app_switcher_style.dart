import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Switcher style tokens for the dark Waily theme.
///
/// Consumed by `WailySwitcher` to render the Figma `Switcher` component-set:
/// `State` ∈ {Off, On} plus a synthesized Disabled state.
@immutable
class AppSwitcherStyle extends ThemeExtension<AppSwitcherStyle> {
  const AppSwitcherStyle._({
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbSize,
    required this.thumbPadding,
    required this.trackColorOff,
    required this.trackColorOn,
    required this.thumbColorOff,
    required this.thumbColorOn,
    required this.trackColorDisabled,
    required this.thumbColorDisabled,
  });

  /// Track width. Figma: 64.
  final double trackWidth;

  /// Track height. Figma: 32.
  final double trackHeight;

  /// Thumb diameter. Figma: 25.6.
  final double thumbSize;

  /// Inset between thumb and track edge. Figma: 3.2.
  final double thumbPadding;

  /// Track fill in Off state. Figma: #FFFFFF.
  final Color trackColorOff;

  /// Track fill in On state. Figma: #D4E1FF (primary).
  final Color trackColorOn;

  /// Thumb fill in Off state. Figma: #7F8799 (textTertiary).
  final Color thumbColorOff;

  /// Thumb fill in On state. Figma: #3D475E (borderStrong).
  final Color thumbColorOn;

  /// Track fill in synthesized Disabled state.
  final Color trackColorDisabled;

  /// Thumb fill in synthesized Disabled state.
  final Color thumbColorDisabled;

  factory AppSwitcherStyle.dark() => const AppSwitcherStyle._(
    trackWidth: 64,
    trackHeight: 32,
    thumbSize: 25.6,
    thumbPadding: 3.2,
    trackColorOff: AppColors.white,
    trackColorOn: AppColors.primary,
    thumbColorOff: AppColors.textTertiary,
    thumbColorOn: AppColors.borderStrong,
    trackColorDisabled: AppColors.border,
    thumbColorDisabled: AppColors.textDisabled,
  );

  @override
  AppSwitcherStyle copyWith({
    double? trackWidth,
    double? trackHeight,
    double? thumbSize,
    double? thumbPadding,
    Color? trackColorOff,
    Color? trackColorOn,
    Color? thumbColorOff,
    Color? thumbColorOn,
    Color? trackColorDisabled,
    Color? thumbColorDisabled,
  }) => AppSwitcherStyle._(
    trackWidth: trackWidth ?? this.trackWidth,
    trackHeight: trackHeight ?? this.trackHeight,
    thumbSize: thumbSize ?? this.thumbSize,
    thumbPadding: thumbPadding ?? this.thumbPadding,
    trackColorOff: trackColorOff ?? this.trackColorOff,
    trackColorOn: trackColorOn ?? this.trackColorOn,
    thumbColorOff: thumbColorOff ?? this.thumbColorOff,
    thumbColorOn: thumbColorOn ?? this.thumbColorOn,
    trackColorDisabled: trackColorDisabled ?? this.trackColorDisabled,
    thumbColorDisabled: thumbColorDisabled ?? this.thumbColorDisabled,
  );

  @override
  AppSwitcherStyle lerp(ThemeExtension<AppSwitcherStyle>? other, double t) {
    if (other is! AppSwitcherStyle) return this;
    return AppSwitcherStyle._(
      trackWidth: t < 0.5 ? trackWidth : other.trackWidth,
      trackHeight: t < 0.5 ? trackHeight : other.trackHeight,
      thumbSize: t < 0.5 ? thumbSize : other.thumbSize,
      thumbPadding: t < 0.5 ? thumbPadding : other.thumbPadding,
      trackColorOff:
          Color.lerp(trackColorOff, other.trackColorOff, t) ?? trackColorOff,
      trackColorOn:
          Color.lerp(trackColorOn, other.trackColorOn, t) ?? trackColorOn,
      thumbColorOff:
          Color.lerp(thumbColorOff, other.thumbColorOff, t) ?? thumbColorOff,
      thumbColorOn:
          Color.lerp(thumbColorOn, other.thumbColorOn, t) ?? thumbColorOn,
      trackColorDisabled:
          Color.lerp(trackColorDisabled, other.trackColorDisabled, t) ??
          trackColorDisabled,
      thumbColorDisabled:
          Color.lerp(thumbColorDisabled, other.thumbColorDisabled, t) ??
          thumbColorDisabled,
    );
  }
}
