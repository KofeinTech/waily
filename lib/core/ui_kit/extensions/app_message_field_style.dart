import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Message bubble style tokens for the dark Waily theme.
///
/// Consumed by `WailyMessageField` to render the Figma `Message Field`
/// component-set: chat-bubble visuals for user vs AI messages.
@immutable
class AppMessageFieldStyle extends ThemeExtension<AppMessageFieldStyle> {
  const AppMessageFieldStyle._({
    required this.borderRadius,
    required this.userPaddingHorizontal,
    required this.userPaddingVertical,
    required this.aiPaddingHorizontal,
    required this.aiPaddingVertical,
    required this.itemSpacing,
    required this.copyIconSize,
    required this.userBackgroundColor,
    required this.aiBackgroundColor,
    required this.aiBorderColor,
    required this.userTextColor,
    required this.aiTextColor,
    required this.copyIconColor,
  });

  /// Bubble corner radius. Figma: 14.
  final double borderRadius;

  /// Horizontal padding for user bubble. Figma: 14.
  final double userPaddingHorizontal;

  /// Vertical padding for user bubble. Figma: 12.
  final double userPaddingVertical;

  /// Horizontal padding for AI bubble. Figma: 14.
  final double aiPaddingHorizontal;

  /// Vertical padding for AI bubble. Figma: 8.
  final double aiPaddingVertical;

  /// Vertical gap between text and copy icon (AI only). Figma: 12.
  final double itemSpacing;

  /// Trailing copy icon canvas. Figma: 24x24.
  final double copyIconSize;

  /// User bubble background. Figma: AppColors.primary (#D4E1FF).
  final Color userBackgroundColor;

  /// AI bubble background — Figma renders transparent fill with a stroke.
  final Color aiBackgroundColor;

  /// AI bubble stroke. Figma: white.
  final Color aiBorderColor;

  /// User text color. Figma: AppColors.surfaceVariant (#252B38).
  final Color userTextColor;

  /// AI text color. Figma: white.
  final Color aiTextColor;

  /// Copy icon color (AI bubble).
  final Color copyIconColor;

  factory AppMessageFieldStyle.dark() => const AppMessageFieldStyle._(
    borderRadius: 14,
    userPaddingHorizontal: 14,
    userPaddingVertical: 12,
    aiPaddingHorizontal: 14,
    aiPaddingVertical: 8,
    itemSpacing: 12,
    copyIconSize: 24,
    userBackgroundColor: AppColors.primary,
    aiBackgroundColor: Color(0x00000000),
    aiBorderColor: AppColors.white,
    userTextColor: AppColors.surfaceVariant,
    aiTextColor: AppColors.white,
    copyIconColor: AppColors.white,
  );

  @override
  AppMessageFieldStyle copyWith({
    double? borderRadius,
    double? userPaddingHorizontal,
    double? userPaddingVertical,
    double? aiPaddingHorizontal,
    double? aiPaddingVertical,
    double? itemSpacing,
    double? copyIconSize,
    Color? userBackgroundColor,
    Color? aiBackgroundColor,
    Color? aiBorderColor,
    Color? userTextColor,
    Color? aiTextColor,
    Color? copyIconColor,
  }) => AppMessageFieldStyle._(
    borderRadius: borderRadius ?? this.borderRadius,
    userPaddingHorizontal:
        userPaddingHorizontal ?? this.userPaddingHorizontal,
    userPaddingVertical: userPaddingVertical ?? this.userPaddingVertical,
    aiPaddingHorizontal: aiPaddingHorizontal ?? this.aiPaddingHorizontal,
    aiPaddingVertical: aiPaddingVertical ?? this.aiPaddingVertical,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    copyIconSize: copyIconSize ?? this.copyIconSize,
    userBackgroundColor: userBackgroundColor ?? this.userBackgroundColor,
    aiBackgroundColor: aiBackgroundColor ?? this.aiBackgroundColor,
    aiBorderColor: aiBorderColor ?? this.aiBorderColor,
    userTextColor: userTextColor ?? this.userTextColor,
    aiTextColor: aiTextColor ?? this.aiTextColor,
    copyIconColor: copyIconColor ?? this.copyIconColor,
  );

  @override
  AppMessageFieldStyle lerp(
    ThemeExtension<AppMessageFieldStyle>? other,
    double t,
  ) {
    if (other is! AppMessageFieldStyle) return this;
    return AppMessageFieldStyle._(
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      userPaddingHorizontal: t < 0.5
          ? userPaddingHorizontal
          : other.userPaddingHorizontal,
      userPaddingVertical: t < 0.5
          ? userPaddingVertical
          : other.userPaddingVertical,
      aiPaddingHorizontal: t < 0.5
          ? aiPaddingHorizontal
          : other.aiPaddingHorizontal,
      aiPaddingVertical: t < 0.5
          ? aiPaddingVertical
          : other.aiPaddingVertical,
      itemSpacing: t < 0.5 ? itemSpacing : other.itemSpacing,
      copyIconSize: t < 0.5 ? copyIconSize : other.copyIconSize,
      userBackgroundColor:
          Color.lerp(userBackgroundColor, other.userBackgroundColor, t) ??
          userBackgroundColor,
      aiBackgroundColor:
          Color.lerp(aiBackgroundColor, other.aiBackgroundColor, t) ??
          aiBackgroundColor,
      aiBorderColor:
          Color.lerp(aiBorderColor, other.aiBorderColor, t) ?? aiBorderColor,
      userTextColor:
          Color.lerp(userTextColor, other.userTextColor, t) ?? userTextColor,
      aiTextColor:
          Color.lerp(aiTextColor, other.aiTextColor, t) ?? aiTextColor,
      copyIconColor:
          Color.lerp(copyIconColor, other.copyIconColor, t) ?? copyIconColor,
    );
  }
}
