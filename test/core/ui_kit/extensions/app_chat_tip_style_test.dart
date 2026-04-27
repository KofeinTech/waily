import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_chat_tip_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppChatTipStyle', () {
    test('dark() borderRadius is AppBorderRadius.m (12)', () {
      expect(AppChatTipStyle.dark().borderRadius, AppBorderRadius.m);
    });

    test('dark() horizontalPadding is 12, verticalPadding is 8', () {
      final s = AppChatTipStyle.dark();
      expect(s.horizontalPadding, 12);
      expect(s.verticalPadding, 8);
    });

    test('dark() defaultBackgroundColor is white at 6% opacity', () {
      expect(
        AppChatTipStyle.dark().defaultBackgroundColor,
        AppColors.white.withValues(alpha: 0.06),
      );
    });

    test('dark() activeBackgroundColor is AppColors.primaryLowest', () {
      expect(
        AppChatTipStyle.dark().activeBackgroundColor,
        AppColors.primaryLowest,
      );
    });

    test('dark() disabledBackgroundColor is AppColors.textSecondary', () {
      expect(
        AppChatTipStyle.dark().disabledBackgroundColor,
        AppColors.textSecondary,
      );
    });

    test('dark() text colors per state', () {
      final s = AppChatTipStyle.dark();
      expect(s.defaultTextColor, AppColors.white);
      expect(s.activeTextColor, AppColors.background);
      expect(s.disabledTextColor, AppColors.textPlaceholder);
    });

    test('copyWith overrides activeBackgroundColor only', () {
      final s = AppChatTipStyle.dark();
      final m = s.copyWith(activeBackgroundColor: AppColors.error);
      expect(m.activeBackgroundColor, AppColors.error);
      expect(m.defaultBackgroundColor, s.defaultBackgroundColor);
    });

    test('lerp t<0.5 keeps verticalPadding from this', () {
      final a = AppChatTipStyle.dark();
      final b = a.copyWith(verticalPadding: 99);
      expect(a.lerp(b, 0.2).verticalPadding, a.verticalPadding);
      expect(a.lerp(b, 0.8).verticalPadding, b.verticalPadding);
    });

    test('lerp blends activeBackgroundColor at midpoint', () {
      final a = AppChatTipStyle.dark();
      final b = a.copyWith(activeBackgroundColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeBackgroundColor,
        Color.lerp(a.activeBackgroundColor, b.activeBackgroundColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppChatTipStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
