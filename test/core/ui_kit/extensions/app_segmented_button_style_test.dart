import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_segmented_button_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppSegmentedButtonStyle', () {
    test('dark() height is 48 (Figma)', () {
      expect(AppSegmentedButtonStyle.dark().height, 48);
    });

    test('dark() borderRadius is AppBorderRadius.m (12)', () {
      expect(AppSegmentedButtonStyle.dark().borderRadius, AppBorderRadius.m);
    });

    test('dark() horizontalPadding is 16, verticalPadding is 14', () {
      final s = AppSegmentedButtonStyle.dark();
      expect(s.horizontalPadding, 16);
      expect(s.verticalPadding, 14);
    });

    test('dark() itemSpacing is 8 (Figma)', () {
      expect(AppSegmentedButtonStyle.dark().itemSpacing, 8);
    });

    test('dark() iconSize is 20 (Figma close icon)', () {
      expect(AppSegmentedButtonStyle.dark().iconSize, 20);
    });

    test('dark() defaultBackgroundColor is white at 12% opacity', () {
      expect(
        AppSegmentedButtonStyle.dark().defaultBackgroundColor,
        AppColors.white.withValues(alpha: 0.12),
      );
    });

    test('dark() activeBackgroundColor is AppColors.primary', () {
      expect(
        AppSegmentedButtonStyle.dark().activeBackgroundColor,
        AppColors.primary,
      );
    });

    test('dark() defaultLabelColor is white, activeLabelColor is surfaceVariant',
        () {
      final s = AppSegmentedButtonStyle.dark();
      expect(s.defaultLabelColor, AppColors.white);
      expect(s.activeLabelColor, AppColors.surfaceVariant);
    });

    test('dark() iconColor is white in both states', () {
      expect(AppSegmentedButtonStyle.dark().iconColor, AppColors.white);
    });

    test('copyWith overrides activeBackgroundColor only', () {
      final s = AppSegmentedButtonStyle.dark();
      final m = s.copyWith(activeBackgroundColor: AppColors.error);
      expect(m.activeBackgroundColor, AppColors.error);
      expect(m.defaultBackgroundColor, s.defaultBackgroundColor);
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppSegmentedButtonStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp blends activeBackgroundColor at midpoint', () {
      final a = AppSegmentedButtonStyle.dark();
      final b = a.copyWith(activeBackgroundColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeBackgroundColor,
        Color.lerp(a.activeBackgroundColor, b.activeBackgroundColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppSegmentedButtonStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
