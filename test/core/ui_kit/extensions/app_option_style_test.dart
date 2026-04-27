import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_option_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppOptionStyle', () {
    test('dark() height is 70 (Figma)', () {
      expect(AppOptionStyle.dark().height, 70);
    });

    test('dark() borderRadius is AppBorderRadius.m (12)', () {
      expect(AppOptionStyle.dark().borderRadius, AppBorderRadius.m);
    });

    test('dark() padding is 12 and titleDescriptionSpacing is 6', () {
      final s = AppOptionStyle.dark();
      expect(s.padding, 12);
      expect(s.titleDescriptionSpacing, 6);
    });

    test('dark() defaultBackgroundColor is fully transparent', () {
      expect(AppOptionStyle.dark().defaultBackgroundColor.a, 0);
    });

    test('dark() selectedBackgroundColor is AppColors.primary', () {
      expect(AppOptionStyle.dark().selectedBackgroundColor, AppColors.primary);
    });

    test('dark() defaultTitleColor is white, selectedTitleColor is background',
        () {
      final s = AppOptionStyle.dark();
      expect(s.defaultTitleColor, AppColors.white);
      expect(s.selectedTitleColor, AppColors.background);
    });

    test(
        'dark() defaultDescriptionColor is textSecondary, selectedDescriptionColor is textDisabled',
        () {
      final s = AppOptionStyle.dark();
      expect(s.defaultDescriptionColor, AppColors.textSecondary);
      expect(s.selectedDescriptionColor, AppColors.textDisabled);
    });

    test('copyWith overrides selectedBackgroundColor only', () {
      final s = AppOptionStyle.dark();
      final m = s.copyWith(selectedBackgroundColor: AppColors.error);
      expect(m.selectedBackgroundColor, AppColors.error);
      expect(m.defaultTitleColor, s.defaultTitleColor);
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppOptionStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp blends selectedBackgroundColor at midpoint', () {
      final a = AppOptionStyle.dark();
      final b = a.copyWith(selectedBackgroundColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).selectedBackgroundColor,
        Color.lerp(a.selectedBackgroundColor, b.selectedBackgroundColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppOptionStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
