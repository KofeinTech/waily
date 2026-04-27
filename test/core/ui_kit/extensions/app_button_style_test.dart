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

    test(
      'dark() primaryPressedBackground is AppColors.primaryLowest (#E5EDFF)',
      () {
        expect(
          AppButtonStyle.dark().primaryPressedBackground,
          AppColors.primaryLowest,
        );
      },
    );

    test('dark() secondaryBackground is AppColors.white', () {
      expect(AppButtonStyle.dark().secondaryBackground, AppColors.white);
    });

    test('dark() secondaryPressedBackground is AppColors.white', () {
      expect(AppButtonStyle.dark().secondaryPressedBackground, AppColors.white);
    });

    test('dark() disabledBackground is AppColors.textSecondary (#9EA3AE)', () {
      expect(AppButtonStyle.dark().disabledBackground, AppColors.textSecondary);
    });

    test('dark() borderRadiusDefault is AppBorderRadius.m (12)', () {
      expect(AppButtonStyle.dark().borderRadiusDefault, AppBorderRadius.m);
    });

    test('dark() borderRadiusSmall is AppBorderRadius.s (8)', () {
      expect(AppButtonStyle.dark().borderRadiusSmall, AppBorderRadius.s);
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

    test('dark() paddingSmall matches Figma (h:16, v:12)', () {
      expect(
        AppButtonStyle.dark().paddingSmall,
        const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.m,
        ),
      );
    });

    test('dark() heightDefault is 52', () {
      expect(AppButtonStyle.dark().heightDefault, 52);
    });

    test('dark() heightSmall is 42', () {
      expect(AppButtonStyle.dark().heightSmall, 42);
    });

    test('dark() iconSizeDefault is 16', () {
      expect(AppButtonStyle.dark().iconSizeDefault, 16);
    });

    test('dark() iconSizeSmall is 16', () {
      expect(AppButtonStyle.dark().iconSizeSmall, 16);
    });

    test('dark() iconGap is AppSpacing.s (8)', () {
      expect(AppButtonStyle.dark().iconGap, AppSpacing.s);
    });

    test('copyWith overrides primaryBackground', () {
      final style = AppButtonStyle.dark();
      final modified = style.copyWith(primaryBackground: AppColors.error);
      expect(modified.primaryBackground, AppColors.error);
      expect(modified.primaryForeground, style.primaryForeground);
    });

    test('copyWith overrides primaryPressedBackground', () {
      final style = AppButtonStyle.dark();
      final modified = style.copyWith(
        primaryPressedBackground: AppColors.error,
      );
      expect(modified.primaryPressedBackground, AppColors.error);
      expect(modified.primaryBackground, style.primaryBackground);
    });

    test('copyWith overrides heightSmall', () {
      final style = AppButtonStyle.dark();
      final modified = style.copyWith(heightSmall: 36);
      expect(modified.heightSmall, 36);
      expect(modified.heightDefault, style.heightDefault);
    });
  });
}
