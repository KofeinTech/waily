import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_list_element_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppListElementStyle', () {
    test('dark() height is 56 and verticalPadding is 16 (Figma)', () {
      final s = AppListElementStyle.dark();
      expect(s.height, 56);
      expect(s.verticalPadding, 16);
    });

    test('dark() iconSize is 24 (Figma trailing arrow)', () {
      expect(AppListElementStyle.dark().iconSize, 24);
    });

    test('dark() labelColor is white, valueColor is textSecondary', () {
      final s = AppListElementStyle.dark();
      expect(s.labelColor, AppColors.white);
      expect(s.valueColor, AppColors.textSecondary);
    });

    test('dark() iconColor is white', () {
      expect(AppListElementStyle.dark().iconColor, AppColors.white);
    });

    test('copyWith overrides labelColor only', () {
      final s = AppListElementStyle.dark();
      final m = s.copyWith(labelColor: AppColors.error);
      expect(m.labelColor, AppColors.error);
      expect(m.valueColor, s.valueColor);
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppListElementStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp blends labelColor at midpoint', () {
      final a = AppListElementStyle.dark();
      final b = a.copyWith(labelColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).labelColor,
        Color.lerp(a.labelColor, b.labelColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppListElementStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
