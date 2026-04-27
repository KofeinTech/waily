import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_progress_bar_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppProgressBarStyle', () {
    test('dark() height is 8 (Figma)', () {
      expect(AppProgressBarStyle.dark().height, 8);
    });

    test('dark() fillColor is white', () {
      expect(AppProgressBarStyle.dark().fillColor, AppColors.white);
    });

    test('dark() trackColor is AppColors.surfaceVariant', () {
      expect(AppProgressBarStyle.dark().trackColor, AppColors.surfaceVariant);
    });

    test('copyWith overrides fillColor only', () {
      final s = AppProgressBarStyle.dark();
      final m = s.copyWith(fillColor: AppColors.error);
      expect(m.fillColor, AppColors.error);
      expect(m.trackColor, s.trackColor);
      expect(m.height, s.height);
    });

    test('lerp blends fillColor at midpoint', () {
      final a = AppProgressBarStyle.dark();
      final b = a.copyWith(fillColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).fillColor,
        Color.lerp(a.fillColor, b.fillColor, 0.5),
      );
    });

    test('lerp t<0.5 keeps height from this', () {
      final a = AppProgressBarStyle.dark();
      final b = a.copyWith(height: 99);
      expect(a.lerp(b, 0.2).height, a.height);
      expect(a.lerp(b, 0.8).height, b.height);
    });

    test('lerp returns this when other is null', () {
      final a = AppProgressBarStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
