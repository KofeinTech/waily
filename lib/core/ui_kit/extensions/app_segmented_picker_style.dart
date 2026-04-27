import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Segmented picker style tokens for the dark Waily theme.
///
/// Consumed by `WailySegmentedPicker` to render the Figma `Segmented Picker`
/// component-set. Container fill is white at 6% opacity (the same trick used
/// by `Icon button`). Each item flips between transparent and primary, with
/// the label flipping between white and surfaceVariant.
@immutable
class AppSegmentedPickerStyle extends ThemeExtension<AppSegmentedPickerStyle> {
  const AppSegmentedPickerStyle._({
    required this.containerHeight,
    required this.itemHeight,
    required this.containerBorderRadius,
    required this.itemBorderRadius,
    required this.containerPadding,
    required this.itemHorizontalPadding,
    required this.itemVerticalPadding,
    required this.containerBackgroundColor,
    required this.activeItemBackgroundColor,
    required this.disabledItemBackgroundColor,
    required this.defaultLabelColor,
    required this.activeLabelColor,
    required this.disabledLabelColor,
  });

  /// Outer container height. Figma: 46.
  final double containerHeight;

  /// Item height. Figma: 42.
  final double itemHeight;

  /// Container corner radius. Figma: 14.
  final double containerBorderRadius;

  /// Item corner radius. Figma: 12.
  final double itemBorderRadius;

  /// Inner padding inside the container. Figma: 2.
  final double containerPadding;

  /// Item horizontal padding. Figma: 16.
  final double itemHorizontalPadding;

  /// Item vertical padding. Figma: 12.
  final double itemVerticalPadding;

  /// Container fill — Figma renders white at 6% opacity.
  final Color containerBackgroundColor;

  /// Active item fill. Figma: #D4E1FF (primary).
  final Color activeItemBackgroundColor;

  /// Active item fill while disabled.
  final Color disabledItemBackgroundColor;

  /// Default (unselected) label color. Figma: white.
  final Color defaultLabelColor;

  /// Active label color. Figma: #252B38 (surfaceVariant).
  final Color activeLabelColor;

  /// Label color in disabled state.
  final Color disabledLabelColor;

  factory AppSegmentedPickerStyle.dark() => AppSegmentedPickerStyle._(
    containerHeight: 46,
    itemHeight: 42,
    containerBorderRadius: 14,
    itemBorderRadius: 12,
    containerPadding: 2,
    itemHorizontalPadding: 16,
    itemVerticalPadding: 12,
    containerBackgroundColor: AppColors.white.withValues(alpha: 0.06),
    activeItemBackgroundColor: AppColors.primary,
    disabledItemBackgroundColor: AppColors.textDisabled,
    defaultLabelColor: AppColors.white,
    activeLabelColor: AppColors.surfaceVariant,
    disabledLabelColor: AppColors.textDisabled,
  );

  @override
  AppSegmentedPickerStyle copyWith({
    double? containerHeight,
    double? itemHeight,
    double? containerBorderRadius,
    double? itemBorderRadius,
    double? containerPadding,
    double? itemHorizontalPadding,
    double? itemVerticalPadding,
    Color? containerBackgroundColor,
    Color? activeItemBackgroundColor,
    Color? disabledItemBackgroundColor,
    Color? defaultLabelColor,
    Color? activeLabelColor,
    Color? disabledLabelColor,
  }) => AppSegmentedPickerStyle._(
    containerHeight: containerHeight ?? this.containerHeight,
    itemHeight: itemHeight ?? this.itemHeight,
    containerBorderRadius:
        containerBorderRadius ?? this.containerBorderRadius,
    itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
    containerPadding: containerPadding ?? this.containerPadding,
    itemHorizontalPadding:
        itemHorizontalPadding ?? this.itemHorizontalPadding,
    itemVerticalPadding: itemVerticalPadding ?? this.itemVerticalPadding,
    containerBackgroundColor:
        containerBackgroundColor ?? this.containerBackgroundColor,
    activeItemBackgroundColor:
        activeItemBackgroundColor ?? this.activeItemBackgroundColor,
    disabledItemBackgroundColor:
        disabledItemBackgroundColor ?? this.disabledItemBackgroundColor,
    defaultLabelColor: defaultLabelColor ?? this.defaultLabelColor,
    activeLabelColor: activeLabelColor ?? this.activeLabelColor,
    disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
  );

  @override
  AppSegmentedPickerStyle lerp(
    ThemeExtension<AppSegmentedPickerStyle>? other,
    double t,
  ) {
    if (other is! AppSegmentedPickerStyle) return this;
    return AppSegmentedPickerStyle._(
      containerHeight: t < 0.5 ? containerHeight : other.containerHeight,
      itemHeight: t < 0.5 ? itemHeight : other.itemHeight,
      containerBorderRadius: t < 0.5
          ? containerBorderRadius
          : other.containerBorderRadius,
      itemBorderRadius: t < 0.5 ? itemBorderRadius : other.itemBorderRadius,
      containerPadding: t < 0.5 ? containerPadding : other.containerPadding,
      itemHorizontalPadding: t < 0.5
          ? itemHorizontalPadding
          : other.itemHorizontalPadding,
      itemVerticalPadding: t < 0.5
          ? itemVerticalPadding
          : other.itemVerticalPadding,
      containerBackgroundColor:
          Color.lerp(
            containerBackgroundColor,
            other.containerBackgroundColor,
            t,
          ) ??
          containerBackgroundColor,
      activeItemBackgroundColor:
          Color.lerp(
            activeItemBackgroundColor,
            other.activeItemBackgroundColor,
            t,
          ) ??
          activeItemBackgroundColor,
      disabledItemBackgroundColor:
          Color.lerp(
            disabledItemBackgroundColor,
            other.disabledItemBackgroundColor,
            t,
          ) ??
          disabledItemBackgroundColor,
      defaultLabelColor:
          Color.lerp(defaultLabelColor, other.defaultLabelColor, t) ??
          defaultLabelColor,
      activeLabelColor:
          Color.lerp(activeLabelColor, other.activeLabelColor, t) ??
          activeLabelColor,
      disabledLabelColor:
          Color.lerp(disabledLabelColor, other.disabledLabelColor, t) ??
          disabledLabelColor,
    );
  }
}
