import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_digit_box_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppDigitBoxStyle', () {
    test('dark() width is 48 and height is 52 (Figma)', () {
      final s = AppDigitBoxStyle.dark();
      expect(s.width, 48);
      expect(s.height, 52);
    });

    test('dark() borderRadius is AppBorderRadius.s (8)', () {
      expect(AppDigitBoxStyle.dark().borderRadius, AppBorderRadius.s);
    });

    test('dark() padding is 12 and borderWidth is 1', () {
      final s = AppDigitBoxStyle.dark();
      expect(s.padding, 12);
      expect(s.borderWidth, 1);
    });

    test('dark() filledBackgroundColor is white at 12% opacity', () {
      expect(
        AppDigitBoxStyle.dark().filledBackgroundColor,
        AppColors.white.withValues(alpha: 0.12),
      );
    });

    test('dark() errorBackgroundColor is fully transparent', () {
      expect(AppDigitBoxStyle.dark().errorBackgroundColor.a, 0);
    });

    test('dark() activeBorderColor is AppColors.primary', () {
      expect(AppDigitBoxStyle.dark().activeBorderColor, AppColors.primary);
    });

    test('dark() errorBorderColor is AppColors.error', () {
      expect(AppDigitBoxStyle.dark().errorBorderColor, AppColors.error);
    });

    test('dark() digitColor and cursorColor are white', () {
      final s = AppDigitBoxStyle.dark();
      expect(s.digitColor, AppColors.white);
      expect(s.cursorColor, AppColors.white);
    });

    test('copyWith overrides activeBorderColor only', () {
      final s = AppDigitBoxStyle.dark();
      final m = s.copyWith(activeBorderColor: AppColors.success);
      expect(m.activeBorderColor, AppColors.success);
      expect(m.errorBorderColor, s.errorBorderColor);
    });

    test('lerp t<0.5 keeps width from this', () {
      final a = AppDigitBoxStyle.dark();
      final b = a.copyWith(width: 99);
      expect(a.lerp(b, 0.2).width, a.width);
      expect(a.lerp(b, 0.8).width, b.width);
    });

    test('lerp blends activeBorderColor at midpoint', () {
      final a = AppDigitBoxStyle.dark();
      final b = a.copyWith(activeBorderColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeBorderColor,
        Color.lerp(a.activeBorderColor, b.activeBorderColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppDigitBoxStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
