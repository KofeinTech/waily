// test/core/ui_kit/extensions/app_button_style_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_button_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_spacing.dart';

void main() {
  group('AppButtonStyle', () {
    test('dark() primaryBackground is AppColors.primarySubtle', () {
      expect(AppButtonStyle.dark().primaryBackground, AppColors.primarySubtle);
    });

    test('dark() primaryForeground is AppColors.surfaceVariant', () {
      expect(AppButtonStyle.dark().primaryForeground, AppColors.surfaceVariant);
    });

    test('dark() disabledBackground is AppColors.textSecondary', () {
      expect(
        AppButtonStyle.dark().disabledBackground,
        AppColors.textSecondary,
      );
    });

    test('dark() disabledForeground is AppColors.surfaceVariant', () {
      expect(
        AppButtonStyle.dark().disabledForeground,
        AppColors.surfaceVariant,
      );
    });

    test('dark() borderRadius is AppBorderRadius.m', () {
      expect(AppButtonStyle.dark().borderRadius, AppBorderRadius.m);
    });

    test('dark() padding is vertical m, horizontal ml', () {
      expect(
        AppButtonStyle.dark().padding,
        const EdgeInsets.symmetric(
          vertical: AppSpacing.m,
          horizontal: AppSpacing.ml,
        ),
      );
    });

    test('copyWith overrides primaryBackground', () {
      final style = AppButtonStyle.dark();
      final modified = style.copyWith(primaryBackground: AppColors.error);
      expect(modified.primaryBackground, AppColors.error);
      expect(modified.primaryForeground, style.primaryForeground);
    });
  });
}
