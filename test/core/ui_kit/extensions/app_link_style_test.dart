import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_link_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_spacing.dart';

void main() {
  group('AppLinkStyle', () {
    test('dark() colorDefault is AppColors.primary (#D4E1FF)', () {
      expect(AppLinkStyle.dark().colorDefault, AppColors.primary);
    });

    test('dark() colorPressed is AppColors.primaryLowest (#E5EDFF)', () {
      expect(AppLinkStyle.dark().colorPressed, AppColors.primaryLowest);
    });

    test('dark() colorDisabled is AppColors.textDisabled', () {
      expect(AppLinkStyle.dark().colorDisabled, AppColors.textDisabled);
    });

    test('dark() verticalPadding is AppSpacing.sm (12)', () {
      expect(AppLinkStyle.dark().verticalPadding, AppSpacing.sm);
    });

    test('copyWith overrides colorDefault only', () {
      final style = AppLinkStyle.dark();
      final modified = style.copyWith(colorDefault: AppColors.error);
      expect(modified.colorDefault, AppColors.error);
      expect(modified.colorPressed, style.colorPressed);
      expect(modified.colorDisabled, style.colorDisabled);
      expect(modified.verticalPadding, style.verticalPadding);
    });

    test('copyWith overrides verticalPadding only', () {
      final style = AppLinkStyle.dark();
      final modified = style.copyWith(verticalPadding: 24);
      expect(modified.verticalPadding, 24);
      expect(modified.colorDefault, style.colorDefault);
    });

    test('lerp t<0.5 keeps verticalPadding from this; t>=0.5 takes other', () {
      final a = AppLinkStyle.dark();
      final b = a.copyWith(verticalPadding: 99);
      expect(a.lerp(b, 0.2).verticalPadding, a.verticalPadding);
      expect(a.lerp(b, 0.8).verticalPadding, b.verticalPadding);
    });

    test('lerp blends colors at midpoint', () {
      final a = AppLinkStyle.dark();
      final b = a.copyWith(colorDefault: AppColors.error);
      final mid = a.lerp(b, 0.5).colorDefault;
      expect(mid, Color.lerp(a.colorDefault, b.colorDefault, 0.5));
    });

    test('lerp returns this when other is not AppLinkStyle', () {
      final a = AppLinkStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
