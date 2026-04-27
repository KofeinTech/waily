import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_chip_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppChipStyle', () {
    test('dark() height is 36 (Figma)', () {
      expect(AppChipStyle.dark().height, 36);
    });

    test('dark() borderRadius is AppBorderRadius.s (8)', () {
      expect(AppChipStyle.dark().borderRadius, AppBorderRadius.s);
    });

    test('dark() horizontalPadding is 12, verticalPadding is 6', () {
      final s = AppChipStyle.dark();
      expect(s.horizontalPadding, 12);
      expect(s.verticalPadding, 6);
    });

    test('dark() itemSpacing is 6 (Figma)', () {
      expect(AppChipStyle.dark().itemSpacing, 6);
    });

    test('dark() iconSize is 24 (Figma close icon)', () {
      expect(AppChipStyle.dark().iconSize, 24);
    });

    test('dark() darkBackgroundColor is AppColors.surface (#1D2534)', () {
      expect(AppChipStyle.dark().darkBackgroundColor, AppColors.surface);
    });

    test('dark() lightBackgroundColor is AppColors.borderStrong (#3D475E)', () {
      expect(AppChipStyle.dark().lightBackgroundColor, AppColors.borderStrong);
    });

    test('dark() label/value/icon colors are white', () {
      final s = AppChipStyle.dark();
      expect(s.labelColor, AppColors.white);
      expect(s.valueColor, AppColors.white);
      expect(s.iconColor, AppColors.white);
    });

    test('copyWith overrides darkBackgroundColor only', () {
      final s = AppChipStyle.dark();
      final m = s.copyWith(darkBackgroundColor: AppColors.error);
      expect(m.darkBackgroundColor, AppColors.error);
      expect(m.lightBackgroundColor, s.lightBackgroundColor);
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppChipStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp blends labelColor at midpoint', () {
      final a = AppChipStyle.dark();
      final b = a.copyWith(labelColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).labelColor,
        Color.lerp(a.labelColor, b.labelColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppChipStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
