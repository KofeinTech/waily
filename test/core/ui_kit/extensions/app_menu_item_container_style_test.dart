import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_menu_item_container_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppMenuItemContainerStyle', () {
    test('dark() height is 40 (Figma)', () {
      expect(AppMenuItemContainerStyle.dark().height, 40);
    });

    test('dark() borderRadius is AppBorderRadius.s (8)', () {
      expect(AppMenuItemContainerStyle.dark().borderRadius, AppBorderRadius.s);
    });

    test('dark() horizontalPadding is 12, verticalPadding is 8', () {
      final s = AppMenuItemContainerStyle.dark();
      expect(s.horizontalPadding, 12);
      expect(s.verticalPadding, 8);
    });

    test('dark() itemSpacing is 4 and iconSize is 24', () {
      final s = AppMenuItemContainerStyle.dark();
      expect(s.itemSpacing, 4);
      expect(s.iconSize, 24);
    });

    test('dark() defaultBackgroundColor is fully transparent', () {
      expect(AppMenuItemContainerStyle.dark().defaultBackgroundColor.a, 0);
    });

    test('dark() activeBackgroundColor is borderStrong', () {
      expect(
        AppMenuItemContainerStyle.dark().activeBackgroundColor,
        AppColors.borderStrong,
      );
    });

    test('dark() iconColor and labelColor are white', () {
      final s = AppMenuItemContainerStyle.dark();
      expect(s.iconColor, AppColors.white);
      expect(s.labelColor, AppColors.white);
    });

    test('copyWith overrides activeBackgroundColor only', () {
      final s = AppMenuItemContainerStyle.dark();
      final m = s.copyWith(activeBackgroundColor: AppColors.error);
      expect(m.activeBackgroundColor, AppColors.error);
      expect(m.iconColor, s.iconColor);
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppMenuItemContainerStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp blends activeBackgroundColor at midpoint', () {
      final a = AppMenuItemContainerStyle.dark();
      final b = a.copyWith(activeBackgroundColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).activeBackgroundColor,
        Color.lerp(a.activeBackgroundColor, b.activeBackgroundColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppMenuItemContainerStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
