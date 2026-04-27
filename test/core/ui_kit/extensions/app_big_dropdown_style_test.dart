import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_big_dropdown_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppBigDropdownStyle', () {
    test('dark() height is 70 (Figma)', () {
      expect(AppBigDropdownStyle.dark().height, 70);
    });

    test('dark() borderRadius is 14 (Figma)', () {
      expect(AppBigDropdownStyle.dark().borderRadius, 14);
    });

    test('dark() padding is 12 (Figma)', () {
      expect(AppBigDropdownStyle.dark().padding, 12);
    });

    test('dark() titleSubtitleSpacing is 6 (Figma)', () {
      expect(AppBigDropdownStyle.dark().titleSubtitleSpacing, 6);
    });

    test('dark() iconSize is 24 (Figma)', () {
      expect(AppBigDropdownStyle.dark().iconSize, 24);
    });

    test('dark() backgroundColor is white at 4% opacity', () {
      expect(
        AppBigDropdownStyle.dark().backgroundColor,
        AppColors.white.withValues(alpha: 0.04),
      );
    });

    test('dark() titleColor is white, subtitleColor is textSecondary', () {
      final s = AppBigDropdownStyle.dark();
      expect(s.titleColor, AppColors.white);
      expect(s.subtitleColor, AppColors.textSecondary);
    });

    test('copyWith overrides backgroundColor only', () {
      final s = AppBigDropdownStyle.dark();
      final m = s.copyWith(backgroundColor: AppColors.error);
      expect(m.backgroundColor, AppColors.error);
      expect(m.titleColor, s.titleColor);
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppBigDropdownStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp blends titleColor at midpoint', () {
      final a = AppBigDropdownStyle.dark();
      final b = a.copyWith(titleColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).titleColor,
        Color.lerp(a.titleColor, b.titleColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppBigDropdownStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
