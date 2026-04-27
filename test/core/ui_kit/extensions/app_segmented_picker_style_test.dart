import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_segmented_picker_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppSegmentedPickerStyle', () {
    test('dark() containerHeight is 46 (Figma)', () {
      expect(AppSegmentedPickerStyle.dark().containerHeight, 46);
    });

    test('dark() itemHeight is 42 (Figma)', () {
      expect(AppSegmentedPickerStyle.dark().itemHeight, 42);
    });

    test('dark() containerBorderRadius is 14, itemBorderRadius is 12', () {
      final s = AppSegmentedPickerStyle.dark();
      expect(s.containerBorderRadius, 14);
      expect(s.itemBorderRadius, 12);
    });

    test('dark() containerPadding is 2', () {
      expect(AppSegmentedPickerStyle.dark().containerPadding, 2);
    });

    test('dark() containerBackgroundColor is white at 6% opacity', () {
      expect(
        AppSegmentedPickerStyle.dark().containerBackgroundColor,
        AppColors.white.withValues(alpha: 0.06),
      );
    });

    test('dark() activeItemBackgroundColor is AppColors.primary', () {
      expect(
        AppSegmentedPickerStyle.dark().activeItemBackgroundColor,
        AppColors.primary,
      );
    });

    test('dark() defaultLabelColor is white, activeLabelColor is surfaceVariant',
        () {
      final s = AppSegmentedPickerStyle.dark();
      expect(s.defaultLabelColor, AppColors.white);
      expect(s.activeLabelColor, AppColors.surfaceVariant);
    });

    test('dark() itemHorizontalPadding is 16, itemVerticalPadding is 12', () {
      final s = AppSegmentedPickerStyle.dark();
      expect(s.itemHorizontalPadding, 16);
      expect(s.itemVerticalPadding, 12);
    });

    test('copyWith overrides activeItemBackgroundColor only', () {
      final s = AppSegmentedPickerStyle.dark();
      final m = s.copyWith(activeItemBackgroundColor: AppColors.error);
      expect(m.activeItemBackgroundColor, AppColors.error);
      expect(m.defaultLabelColor, s.defaultLabelColor);
    });

    test('lerp t<0.5 keeps containerHeight from this', () {
      final a = AppSegmentedPickerStyle.dark();
      final b = a.copyWith(containerHeight: 99);
      expect(a.lerp(b, 0.2).containerHeight, a.containerHeight);
      expect(a.lerp(b, 0.8).containerHeight, b.containerHeight);
    });

    test('lerp blends activeItemBackgroundColor at midpoint', () {
      final a = AppSegmentedPickerStyle.dark();
      final b = a.copyWith(activeItemBackgroundColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeItemBackgroundColor,
        Color.lerp(
          a.activeItemBackgroundColor,
          b.activeItemBackgroundColor,
          0.5,
        ),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppSegmentedPickerStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
