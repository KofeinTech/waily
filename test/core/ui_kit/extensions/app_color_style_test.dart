import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_color_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppColorStyle', () {
    test('dark() background equals AppColors.background', () {
      expect(AppColorStyle.dark().background, AppColors.background);
    });

    test('dark() primary equals AppColors.primary', () {
      expect(AppColorStyle.dark().primary, AppColors.primary);
    });

    test('dark() error equals AppColors.error', () {
      expect(AppColorStyle.dark().error, AppColors.error);
    });

    test('copyWith overrides specified field', () {
      final original = AppColorStyle.dark();
      const newColor = Color(0xFF123456);
      final modified = original.copyWith(background: newColor);
      expect(modified.background, newColor);
      expect(modified.primary, original.primary);
    });

    test('copyWith without args returns equivalent object', () {
      final style = AppColorStyle.dark();
      final copy = style.copyWith();
      expect(copy.background, style.background);
      expect(copy.primary, style.primary);
    });

    test('lerp at t=0 returns this', () {
      final a = AppColorStyle.dark();
      final b = a.copyWith(background: const Color(0xFFFFFFFF));
      final result = a.lerp(b, 0.0);
      expect(result.background, a.background);
    });

    test('lerp at t=1 returns other', () {
      final a = AppColorStyle.dark();
      final b = a.copyWith(background: const Color(0xFFFFFFFF));
      final result = a.lerp(b, 1.0);
      expect(result.background, b.background);
    });
  });
}
