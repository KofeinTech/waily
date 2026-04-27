import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// History card style tokens for the dark Waily theme.
///
/// Consumed by `WailyHistoryCard` to render the Figma `History card`
/// component-set: Default (daily), Today (daily with pill), Chat.
@immutable
class AppHistoryCardStyle extends ThemeExtension<AppHistoryCardStyle> {
  const AppHistoryCardStyle._({
    required this.borderRadius,
    required this.padding,
    required this.itemSpacing,
    required this.dailyBackgroundColor,
    required this.todayBackgroundColor,
    required this.chatBackgroundColor,
    required this.todayPillColor,
    required this.todayPillTextColor,
    required this.todayPillRadius,
    required this.todayPillHorizontalPadding,
    required this.todayPillVerticalPadding,
    required this.titleColor,
    required this.subtitleColor,
    required this.chatTextColor,
  });

  final double borderRadius;
  final double padding;
  final double itemSpacing;

  final Color dailyBackgroundColor;
  final Color todayBackgroundColor;
  final Color chatBackgroundColor;

  final Color todayPillColor;
  final Color todayPillTextColor;
  final double todayPillRadius;
  final double todayPillHorizontalPadding;
  final double todayPillVerticalPadding;

  final Color titleColor;
  final Color subtitleColor;
  final Color chatTextColor;

  factory AppHistoryCardStyle.dark() => AppHistoryCardStyle._(
    borderRadius: 14,
    padding: 12,
    itemSpacing: 4,
    dailyBackgroundColor: AppColors.white.withValues(alpha: 0.04),
    todayBackgroundColor: AppColors.white.withValues(alpha: 0.06),
    chatBackgroundColor: AppColors.white.withValues(alpha: 0.04),
    todayPillColor: AppColors.primary,
    todayPillTextColor: AppColors.surfaceVariant,
    todayPillRadius: 8,
    todayPillHorizontalPadding: 8,
    todayPillVerticalPadding: 4,
    titleColor: AppColors.white,
    subtitleColor: AppColors.textSecondary,
    chatTextColor: AppColors.textSecondary,
  );

  @override
  AppHistoryCardStyle copyWith({
    double? borderRadius,
    double? padding,
    double? itemSpacing,
    Color? dailyBackgroundColor,
    Color? todayBackgroundColor,
    Color? chatBackgroundColor,
    Color? todayPillColor,
    Color? todayPillTextColor,
    double? todayPillRadius,
    double? todayPillHorizontalPadding,
    double? todayPillVerticalPadding,
    Color? titleColor,
    Color? subtitleColor,
    Color? chatTextColor,
  }) => AppHistoryCardStyle._(
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    dailyBackgroundColor: dailyBackgroundColor ?? this.dailyBackgroundColor,
    todayBackgroundColor: todayBackgroundColor ?? this.todayBackgroundColor,
    chatBackgroundColor: chatBackgroundColor ?? this.chatBackgroundColor,
    todayPillColor: todayPillColor ?? this.todayPillColor,
    todayPillTextColor: todayPillTextColor ?? this.todayPillTextColor,
    todayPillRadius: todayPillRadius ?? this.todayPillRadius,
    todayPillHorizontalPadding:
        todayPillHorizontalPadding ?? this.todayPillHorizontalPadding,
    todayPillVerticalPadding:
        todayPillVerticalPadding ?? this.todayPillVerticalPadding,
    titleColor: titleColor ?? this.titleColor,
    subtitleColor: subtitleColor ?? this.subtitleColor,
    chatTextColor: chatTextColor ?? this.chatTextColor,
  );

  @override
  AppHistoryCardStyle lerp(
    ThemeExtension<AppHistoryCardStyle>? other,
    double t,
  ) {
    if (other is! AppHistoryCardStyle) return this;
    return AppHistoryCardStyle._(
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: t < 0.5 ? padding : other.padding,
      itemSpacing: t < 0.5 ? itemSpacing : other.itemSpacing,
      dailyBackgroundColor:
          Color.lerp(dailyBackgroundColor, other.dailyBackgroundColor, t) ??
          dailyBackgroundColor,
      todayBackgroundColor:
          Color.lerp(todayBackgroundColor, other.todayBackgroundColor, t) ??
          todayBackgroundColor,
      chatBackgroundColor:
          Color.lerp(chatBackgroundColor, other.chatBackgroundColor, t) ??
          chatBackgroundColor,
      todayPillColor:
          Color.lerp(todayPillColor, other.todayPillColor, t) ?? todayPillColor,
      todayPillTextColor:
          Color.lerp(todayPillTextColor, other.todayPillTextColor, t) ??
          todayPillTextColor,
      todayPillRadius: t < 0.5 ? todayPillRadius : other.todayPillRadius,
      todayPillHorizontalPadding: t < 0.5
          ? todayPillHorizontalPadding
          : other.todayPillHorizontalPadding,
      todayPillVerticalPadding: t < 0.5
          ? todayPillVerticalPadding
          : other.todayPillVerticalPadding,
      titleColor: Color.lerp(titleColor, other.titleColor, t) ?? titleColor,
      subtitleColor:
          Color.lerp(subtitleColor, other.subtitleColor, t) ?? subtitleColor,
      chatTextColor:
          Color.lerp(chatTextColor, other.chatTextColor, t) ?? chatTextColor,
    );
  }
}
