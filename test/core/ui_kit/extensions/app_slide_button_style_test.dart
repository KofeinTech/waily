import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_slide_button_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppSlideButtonStyle', () {
    test('dark() height is 52 (Figma)', () {
      expect(AppSlideButtonStyle.dark().height, 52);
    });

    test('dark() borderRadius and thumbBorderRadius are AppBorderRadius.m', () {
      final s = AppSlideButtonStyle.dark();
      expect(s.borderRadius, AppBorderRadius.m);
      expect(s.thumbBorderRadius, AppBorderRadius.m);
    });

    test('dark() padding is 4 (Figma) and thumbWidth is 68', () {
      final s = AppSlideButtonStyle.dark();
      expect(s.padding, 4);
      expect(s.thumbWidth, 68);
    });

    test('dark() iconSize is 24', () {
      expect(AppSlideButtonStyle.dark().iconSize, 24);
    });

    test('dark() confirmThreshold is 0.9', () {
      expect(AppSlideButtonStyle.dark().confirmThreshold, 0.9);
    });

    test('dark() trackColor is AppColors.primary', () {
      expect(AppSlideButtonStyle.dark().trackColor, AppColors.primary);
    });

    test('dark() thumbHaloColor is borderStrong (Figma Variant2 ellipse)', () {
      expect(
        AppSlideButtonStyle.dark().thumbHaloColor,
        AppColors.borderStrong,
      );
    });

    test('dark() thumb radial gradient is textPlaceholder → #31394B', () {
      final s = AppSlideButtonStyle.dark();
      expect(s.thumbGradientStart, AppColors.textPlaceholder);
      expect(s.thumbGradientEnd, const Color(0xFF31394B));
    });

    test('dark() iconColor is white (over dark fill trail)', () {
      expect(AppSlideButtonStyle.dark().iconColor, AppColors.white);
    });

    test('dark() labelColor is AppColors.surfaceVariant', () {
      expect(AppSlideButtonStyle.dark().labelColor, AppColors.surfaceVariant);
    });

    test('copyWith overrides confirmThreshold only', () {
      final s = AppSlideButtonStyle.dark();
      final m = s.copyWith(confirmThreshold: 0.5);
      expect(m.confirmThreshold, 0.5);
      expect(m.trackColor, s.trackColor);
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppSlideButtonStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp blends trackColor at midpoint', () {
      final a = AppSlideButtonStyle.dark();
      final b = a.copyWith(trackColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).trackColor,
        Color.lerp(a.trackColor, b.trackColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppSlideButtonStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
