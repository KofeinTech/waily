import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_text_styles.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppTextStyles', () {
    test('s16w400 returns style with fontSize 16', () {
      expect(AppTextStyles.dark().s16w400().fontSize, 16.0);
    });

    test('s32w500 returns style with fontSize 32', () {
      expect(AppTextStyles.dark().s32w500().fontSize, 32.0);
    });

    test('default color is AppColors.textPrimary', () {
      final style = AppTextStyles.dark().s16w400();
      expect(style.color, AppColors.textPrimary);
    });

    test('color override replaces default', () {
      const red = Color(0xFFFF0000);
      final style = AppTextStyles.dark().s16w400(color: red);
      expect(style.color, red);
    });

    test('lerp at t=0 returns this textColor', () {
      final a = AppTextStyles.dark();
      final b = AppTextStyles.dark().copyWith(
        textColor: const Color(0xFFAAAAAA),
      );
      final result = a.lerp(b, 0.0);
      expect(result.s16w400().color, AppColors.textPrimary);
    });
  });
}
