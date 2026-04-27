import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_history_card_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppHistoryCardStyle', () {
    test('dark() borderRadius is 14 (Figma)', () {
      expect(AppHistoryCardStyle.dark().borderRadius, 14);
    });

    test('dark() padding is 12 (Figma)', () {
      expect(AppHistoryCardStyle.dark().padding, 12);
    });

    test('dark() dailyBackgroundColor is white at 4% opacity', () {
      expect(
        AppHistoryCardStyle.dark().dailyBackgroundColor,
        AppColors.white.withValues(alpha: 0.04),
      );
    });

    test('dark() todayBackgroundColor is white at 6% opacity', () {
      expect(
        AppHistoryCardStyle.dark().todayBackgroundColor,
        AppColors.white.withValues(alpha: 0.06),
      );
    });

    test('dark() todayPillColor is AppColors.primary', () {
      expect(AppHistoryCardStyle.dark().todayPillColor, AppColors.primary);
    });

    test('dark() todayPillTextColor is AppColors.surfaceVariant', () {
      expect(
        AppHistoryCardStyle.dark().todayPillTextColor,
        AppColors.surfaceVariant,
      );
    });

    test('dark() titleColor is white, subtitleColor/chatTextColor are textSecondary',
        () {
      final s = AppHistoryCardStyle.dark();
      expect(s.titleColor, AppColors.white);
      expect(s.subtitleColor, AppColors.textSecondary);
      expect(s.chatTextColor, AppColors.textSecondary);
    });

    test('copyWith overrides todayPillColor only', () {
      final s = AppHistoryCardStyle.dark();
      final m = s.copyWith(todayPillColor: AppColors.error);
      expect(m.todayPillColor, AppColors.error);
      expect(m.titleColor, s.titleColor);
    });

    test('lerp t<0.5 keeps padding from this', () {
      final a = AppHistoryCardStyle.dark();
      final b = a.copyWith(padding: 99);
      expect(a.lerp(b, 0.2).padding, a.padding);
      expect(a.lerp(b, 0.8).padding, b.padding);
    });

    test('lerp blends todayPillColor at midpoint', () {
      final a = AppHistoryCardStyle.dark();
      final b = a.copyWith(todayPillColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).todayPillColor,
        Color.lerp(a.todayPillColor, b.todayPillColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppHistoryCardStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
