// test/core/ui_kit/extensions/app_button_style_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_button_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';

void main() {
  group('AppButtonStyle', () {
    test('dark() primaryBackground is AppColors.primary', () {
      expect(AppButtonStyle.dark().primaryBackground, AppColors.primary);
    });

    test('dark() primaryForeground is AppColors.textPrimary', () {
      expect(AppButtonStyle.dark().primaryForeground, AppColors.textPrimary);
    });

    test('dark() disabledBackground is AppColors.surfaceVariant', () {
      expect(AppButtonStyle.dark().disabledBackground, AppColors.surfaceVariant);
    });

    test('dark() borderRadius is AppBorderRadius.l', () {
      expect(AppButtonStyle.dark().borderRadius, AppBorderRadius.l);
    });

    test('copyWith overrides primaryBackground', () {
      final style = AppButtonStyle.dark();
      final modified = style.copyWith(primaryBackground: AppColors.error);
      expect(modified.primaryBackground, AppColors.error);
      expect(modified.primaryForeground, style.primaryForeground);
    });
  });
}
