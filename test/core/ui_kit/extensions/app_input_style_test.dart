import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_input_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';

void main() {
  group('AppInputStyle', () {
    test('dark() fillColor is white at 12% opacity (Figma Primary fill)', () {
      expect(
        AppInputStyle.dark().fillColor,
        AppColors.white.withValues(alpha: 0.12),
      );
    });

    test('dark() secondaryFillColor is AppColors.textTertiary (#7F8799)', () {
      expect(AppInputStyle.dark().secondaryFillColor, AppColors.textTertiary);
    });

    test('dark() focusedBorderColor is AppColors.primary', () {
      expect(AppInputStyle.dark().focusedBorderColor, AppColors.primary);
    });

    test('dark() errorBorderColor is AppColors.error', () {
      expect(AppInputStyle.dark().errorBorderColor, AppColors.error);
    });

    test('dark() borderRadius is AppBorderRadius.m', () {
      expect(AppInputStyle.dark().borderRadius, AppBorderRadius.m);
    });

    test('copyWith overrides fillColor', () {
      final style = AppInputStyle.dark();
      final modified = style.copyWith(fillColor: AppColors.surfaceVariant);
      expect(modified.fillColor, AppColors.surfaceVariant);
      expect(modified.borderRadius, style.borderRadius);
    });

    test('copyWith overrides secondaryFillColor', () {
      final style = AppInputStyle.dark();
      final modified = style.copyWith(
        secondaryFillColor: AppColors.surfaceVariant,
      );
      expect(modified.secondaryFillColor, AppColors.surfaceVariant);
      expect(modified.fillColor, style.fillColor);
    });

    test('dark() errorStyle uses AppColors.error color', () {
      final style = AppInputStyle.dark();
      expect(style.errorStyle.color, AppColors.error);
    });

    test('dark() hintStyle uses AppColors.textSecondary (Figma #9EA3AE)', () {
      final style = AppInputStyle.dark();
      expect(style.hintStyle.color, AppColors.textSecondary);
    });
  });
}
