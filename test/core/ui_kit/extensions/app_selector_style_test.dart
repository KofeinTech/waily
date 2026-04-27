import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_selector_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppSelectorStyle', () {
    test('dark() defaultColor is AppColors.textPlaceholder (#646C7E)', () {
      expect(AppSelectorStyle.dark().defaultColor, AppColors.textPlaceholder);
    });

    test('dark() activeColor is AppColors.white', () {
      expect(AppSelectorStyle.dark().activeColor, AppColors.white);
    });

    test('dark() disabledColor is AppColors.textDisabled', () {
      expect(AppSelectorStyle.dark().disabledColor, AppColors.textDisabled);
    });

    test('copyWith overrides activeColor only', () {
      final s = AppSelectorStyle.dark();
      final m = s.copyWith(activeColor: AppColors.error);
      expect(m.activeColor, AppColors.error);
      expect(m.defaultColor, s.defaultColor);
    });

    test('lerp blends activeColor at midpoint', () {
      final a = AppSelectorStyle.dark();
      final b = a.copyWith(activeColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeColor,
        Color.lerp(a.activeColor, b.activeColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppSelectorStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
