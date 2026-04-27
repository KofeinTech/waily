import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_picker_card_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppPickerCardStyle', () {
    test('dark() borderRadius is AppBorderRadius.l (16)', () {
      expect(AppPickerCardStyle.dark().borderRadius, AppBorderRadius.l);
    });

    test('dark() padding is 16, itemSpacing is 4 (Figma)', () {
      final s = AppPickerCardStyle.dark();
      expect(s.padding, 16);
      expect(s.itemSpacing, 4);
    });

    test('dark() defaultBackgroundColor is white at 4% opacity', () {
      expect(
        AppPickerCardStyle.dark().defaultBackgroundColor,
        AppColors.white.withValues(alpha: 0.04),
      );
    });

    test('dark() activeBackgroundColor is AppColors.primary', () {
      expect(
        AppPickerCardStyle.dark().activeBackgroundColor,
        AppColors.primary,
      );
    });

    test('dark() title and subtitle colors per state', () {
      final s = AppPickerCardStyle.dark();
      expect(s.defaultTitleColor, AppColors.white);
      expect(s.activeTitleColor, AppColors.surfaceVariant);
      expect(s.defaultSubtitleColor, AppColors.textSecondary);
      expect(s.activeSubtitleColor, AppColors.textDisabled);
    });

    test('dark() checkboxSize is 24', () {
      expect(AppPickerCardStyle.dark().checkboxSize, 24);
    });

    test('copyWith overrides activeBackgroundColor only', () {
      final s = AppPickerCardStyle.dark();
      final m = s.copyWith(activeBackgroundColor: AppColors.error);
      expect(m.activeBackgroundColor, AppColors.error);
      expect(m.defaultBackgroundColor, s.defaultBackgroundColor);
    });

    test('lerp t<0.5 keeps padding from this', () {
      final a = AppPickerCardStyle.dark();
      final b = a.copyWith(padding: 99);
      expect(a.lerp(b, 0.2).padding, a.padding);
      expect(a.lerp(b, 0.8).padding, b.padding);
    });

    test('lerp blends activeBackgroundColor at midpoint', () {
      final a = AppPickerCardStyle.dark();
      final b = a.copyWith(activeBackgroundColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeBackgroundColor,
        Color.lerp(a.activeBackgroundColor, b.activeBackgroundColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppPickerCardStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
