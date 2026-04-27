import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_checkbox_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppCheckboxStyle', () {
    test('dark() size is 24x24 (Figma)', () {
      expect(AppCheckboxStyle.dark().size, 24);
    });

    test('dark() iconSize is 16 (Figma checkmark)', () {
      expect(AppCheckboxStyle.dark().iconSize, 16);
    });

    test('dark() defaultFillColor is fully transparent', () {
      expect(AppCheckboxStyle.dark().defaultFillColor.a, 0);
    });

    test('dark() defaultBorderColor is borderStrong (#3D475E)', () {
      expect(AppCheckboxStyle.dark().defaultBorderColor, AppColors.borderStrong);
    });

    test('dark() activeFillColor is borderStrong (#3D475E)', () {
      expect(AppCheckboxStyle.dark().activeFillColor, AppColors.borderStrong);
    });

    test('dark() checkmarkColor is white', () {
      expect(AppCheckboxStyle.dark().checkmarkColor, AppColors.white);
    });

    test('dark() borderWidth is 1', () {
      expect(AppCheckboxStyle.dark().borderWidth, 1);
    });

    test('copyWith overrides activeFillColor only', () {
      final s = AppCheckboxStyle.dark();
      final m = s.copyWith(activeFillColor: AppColors.error);
      expect(m.activeFillColor, AppColors.error);
      expect(m.defaultBorderColor, s.defaultBorderColor);
      expect(m.size, s.size);
    });

    test('lerp t<0.5 keeps size from this; t>=0.5 takes other', () {
      final a = AppCheckboxStyle.dark();
      final b = a.copyWith(size: 99);
      expect(a.lerp(b, 0.2).size, a.size);
      expect(a.lerp(b, 0.8).size, b.size);
    });

    test('lerp blends activeFillColor at midpoint', () {
      final a = AppCheckboxStyle.dark();
      final b = a.copyWith(activeFillColor: AppColors.error);
      final mid = a.lerp(b, 0.5).activeFillColor;
      expect(mid, Color.lerp(a.activeFillColor, b.activeFillColor, 0.5));
    });

    test('lerp returns this when other is not AppCheckboxStyle', () {
      final a = AppCheckboxStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
