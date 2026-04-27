import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_text_input_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppTextInputStyle', () {
    test('dark() height is 70 (Figma)', () {
      expect(AppTextInputStyle.dark().height, 70);
    });

    test('dark() borderRadius is 14 (Figma)', () {
      expect(AppTextInputStyle.dark().borderRadius, 14);
    });

    test('dark() padding is 12 and itemSpacing is 8', () {
      final s = AppTextInputStyle.dark();
      expect(s.padding, 12);
      expect(s.itemSpacing, 8);
    });

    test('dark() iconSize is 20 (Figma close icon)', () {
      expect(AppTextInputStyle.dark().iconSize, 20);
    });

    test('dark() backgroundColor is white at 4% opacity', () {
      expect(
        AppTextInputStyle.dark().backgroundColor,
        AppColors.white.withValues(alpha: 0.04),
      );
    });

    test('dark() defaultBorderColor is white, activeBorderColor is primary', () {
      final s = AppTextInputStyle.dark();
      expect(s.defaultBorderColor, AppColors.white);
      expect(s.activeBorderColor, AppColors.primary);
    });

    test('dark() errorBorderColor is AppColors.error', () {
      expect(AppTextInputStyle.dark().errorBorderColor, AppColors.error);
    });

    test('dark() inputColor is white, placeholderColor is textSecondary', () {
      final s = AppTextInputStyle.dark();
      expect(s.inputColor, AppColors.white);
      expect(s.placeholderColor, AppColors.textSecondary);
    });

    test('copyWith overrides activeBorderColor only', () {
      final s = AppTextInputStyle.dark();
      final m = s.copyWith(activeBorderColor: AppColors.success);
      expect(m.activeBorderColor, AppColors.success);
      expect(m.defaultBorderColor, s.defaultBorderColor);
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppTextInputStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp blends activeBorderColor at midpoint', () {
      final a = AppTextInputStyle.dark();
      final b = a.copyWith(activeBorderColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeBorderColor,
        Color.lerp(a.activeBorderColor, b.activeBorderColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppTextInputStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
