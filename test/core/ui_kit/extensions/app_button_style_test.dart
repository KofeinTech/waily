// test/core/ui_kit/extensions/app_button_style_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_button_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_spacing.dart';

void main() {
  group('AppButtonStyle', () {
    test('dark() primaryBackground is AppColors.primary (#D4E1FF)', () {
      expect(AppButtonStyle.dark().primaryBackground, AppColors.primary);
    });

    test('dark() secondaryBackground is AppColors.white', () {
      expect(AppButtonStyle.dark().secondaryBackground, AppColors.white);
    });

    test('dark() disabledBackground is AppColors.textSecondary (#9EA3AE)', () {
      expect(AppButtonStyle.dark().disabledBackground, AppColors.textSecondary);
    });

    test('dark() borderRadiusDefault is AppBorderRadius.m (12)', () {
      expect(AppButtonStyle.dark().borderRadiusDefault, AppBorderRadius.m);
    });

    test('dark() borderRadiusBig is AppBorderRadius.l (16)', () {
      expect(AppButtonStyle.dark().borderRadiusBig, AppBorderRadius.l);
    });

    test('dark() paddingDefault matches Figma (h:20, v:16)', () {
      expect(
        AppButtonStyle.dark().paddingDefault,
        const EdgeInsets.symmetric(
          vertical: AppSpacing.m,
          horizontal: AppSpacing.ml,
        ),
      );
    });

    test('dark() paddingBig is (h:24, v:20)', () {
      expect(
        AppButtonStyle.dark().paddingBig,
        const EdgeInsets.symmetric(
          vertical: AppSpacing.ml,
          horizontal: AppSpacing.l,
        ),
      );
    });

    test('dark() heightDefault is 52', () {
      expect(AppButtonStyle.dark().heightDefault, 52);
    });

    test('dark() heightBig is 64', () {
      expect(AppButtonStyle.dark().heightBig, 64);
    });

    test('copyWith overrides primaryBackground', () {
      final style = AppButtonStyle.dark();
      final modified = style.copyWith(primaryBackground: AppColors.error);
      expect(modified.primaryBackground, AppColors.error);
      expect(modified.primaryForeground, style.primaryForeground);
    });

    test('copyWith overrides heightBig', () {
      final style = AppButtonStyle.dark();
      final modified = style.copyWith(heightBig: 72);
      expect(modified.heightBig, 72);
      expect(modified.heightDefault, style.heightDefault);
    });
  });
}
