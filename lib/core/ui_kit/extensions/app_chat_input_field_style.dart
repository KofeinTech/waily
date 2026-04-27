import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Chat input field style tokens for the dark Waily theme.
///
/// Consumed by `WailyChatInputField` to render the Figma `Chat Input Field`
/// component-set (multi-line composer with a trailing send/mic button).
@immutable
class AppChatInputFieldStyle extends ThemeExtension<AppChatInputFieldStyle> {
  const AppChatInputFieldStyle._({
    required this.minHeight,
    required this.borderRadius,
    required this.padding,
    required this.itemSpacing,
    required this.actionButtonSize,
    required this.iconSize,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
    required this.actionButtonBackgroundColor,
    required this.actionIconColor,
    required this.textColor,
    required this.placeholderColor,
    required this.disabledTextColor,
  });

  /// Minimum height (single line). Figma: 52.
  final double minHeight;

  /// Container corner radius. Figma: 12.
  final double borderRadius;

  /// Inner inset around the row. Compromise between Figma states (Basic 16,
  /// Filled/Typing 6) — picked the "press-state" 6 so the trailing 40x40
  /// button fits the container snugly.
  final double padding;

  /// Spacing between text and trailing action button. Figma: 8.
  final double itemSpacing;

  /// Trailing action button container. Figma: 40x40.
  final double actionButtonSize;

  /// Trailing action icon canvas. Figma: 24x24.
  final double iconSize;

  /// Container background. Figma: AppColors.surface (#1D2534).
  final Color backgroundColor;

  /// Container background while disabled. Figma: AppColors.textSecondary.
  final Color disabledBackgroundColor;

  /// Action button background. Figma: AppColors.primary (#D4E1FF).
  final Color actionButtonBackgroundColor;

  /// Action icon color. Figma: white.
  final Color actionIconColor;

  /// Input glyph color. Figma: white.
  final Color textColor;

  /// Placeholder glyph color. Figma: AppColors.textSecondary.
  final Color placeholderColor;

  /// Input glyph color while disabled.
  final Color disabledTextColor;

  factory AppChatInputFieldStyle.dark() => const AppChatInputFieldStyle._(
    minHeight: 52,
    borderRadius: AppBorderRadius.m,
    padding: 6,
    itemSpacing: 8,
    actionButtonSize: 40,
    iconSize: 24,
    backgroundColor: AppColors.surface,
    disabledBackgroundColor: AppColors.textSecondary,
    actionButtonBackgroundColor: AppColors.primary,
    actionIconColor: AppColors.white,
    textColor: AppColors.white,
    placeholderColor: AppColors.textSecondary,
    disabledTextColor: AppColors.textDisabled,
  );

  @override
  AppChatInputFieldStyle copyWith({
    double? minHeight,
    double? borderRadius,
    double? padding,
    double? itemSpacing,
    double? actionButtonSize,
    double? iconSize,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? actionButtonBackgroundColor,
    Color? actionIconColor,
    Color? textColor,
    Color? placeholderColor,
    Color? disabledTextColor,
  }) => AppChatInputFieldStyle._(
    minHeight: minHeight ?? this.minHeight,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    actionButtonSize: actionButtonSize ?? this.actionButtonSize,
    iconSize: iconSize ?? this.iconSize,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    actionButtonBackgroundColor:
        actionButtonBackgroundColor ?? this.actionButtonBackgroundColor,
    actionIconColor: actionIconColor ?? this.actionIconColor,
    textColor: textColor ?? this.textColor,
    placeholderColor: placeholderColor ?? this.placeholderColor,
    disabledTextColor: disabledTextColor ?? this.disabledTextColor,
  );

  @override
  AppChatInputFieldStyle lerp(
    ThemeExtension<AppChatInputFieldStyle>? other,
    double t,
  ) {
    if (other is! AppChatInputFieldStyle) return this;
    return AppChatInputFieldStyle._(
      minHeight: t < 0.5 ? minHeight : other.minHeight,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: t < 0.5 ? padding : other.padding,
      itemSpacing: t < 0.5 ? itemSpacing : other.itemSpacing,
      actionButtonSize: t < 0.5 ? actionButtonSize : other.actionButtonSize,
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      disabledBackgroundColor:
          Color.lerp(
            disabledBackgroundColor,
            other.disabledBackgroundColor,
            t,
          ) ??
          disabledBackgroundColor,
      actionButtonBackgroundColor:
          Color.lerp(
            actionButtonBackgroundColor,
            other.actionButtonBackgroundColor,
            t,
          ) ??
          actionButtonBackgroundColor,
      actionIconColor:
          Color.lerp(actionIconColor, other.actionIconColor, t) ??
          actionIconColor,
      textColor: Color.lerp(textColor, other.textColor, t) ?? textColor,
      placeholderColor:
          Color.lerp(placeholderColor, other.placeholderColor, t) ??
          placeholderColor,
      disabledTextColor:
          Color.lerp(disabledTextColor, other.disabledTextColor, t) ??
          disabledTextColor,
    );
  }
}
