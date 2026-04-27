import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_loader_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppLoaderStyle', () {
    test('dark() dotSize is 24 (Figma)', () {
      expect(AppLoaderStyle.dark().dotSize, 24);
    });

    test('dark() dotSpacing is 20 (Figma 44 stride - 24 dot)', () {
      expect(AppLoaderStyle.dark().dotSpacing, 20);
    });

    test('dark() defaultDotColor is AppColors.primary (#D4E1FF)', () {
      expect(AppLoaderStyle.dark().defaultDotColor, AppColors.primary);
    });

    test('dark() activeDotColor is AppColors.white', () {
      expect(AppLoaderStyle.dark().activeDotColor, AppColors.white);
    });

    test('dark() cycleDuration is 1200ms', () {
      expect(
        AppLoaderStyle.dark().cycleDuration,
        const Duration(milliseconds: 1200),
      );
    });

    test('copyWith overrides activeDotColor only', () {
      final s = AppLoaderStyle.dark();
      final m = s.copyWith(activeDotColor: AppColors.error);
      expect(m.activeDotColor, AppColors.error);
      expect(m.defaultDotColor, s.defaultDotColor);
    });

    test('lerp t<0.5 keeps dotSize from this', () {
      final a = AppLoaderStyle.dark();
      final b = a.copyWith(dotSize: 99);
      expect(a.lerp(b, 0.2).dotSize, a.dotSize);
      expect(a.lerp(b, 0.8).dotSize, b.dotSize);
    });

    test('lerp blends activeDotColor at midpoint', () {
      final a = AppLoaderStyle.dark();
      final b = a.copyWith(activeDotColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeDotColor,
        Color.lerp(a.activeDotColor, b.activeDotColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppLoaderStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
