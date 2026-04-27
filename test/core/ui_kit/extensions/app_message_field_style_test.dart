import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_message_field_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppMessageFieldStyle', () {
    test('dark() borderRadius is 14 (Figma)', () {
      expect(AppMessageFieldStyle.dark().borderRadius, 14);
    });

    test('dark() user padding is 14h/12v (Figma)', () {
      final s = AppMessageFieldStyle.dark();
      expect(s.userPaddingHorizontal, 14);
      expect(s.userPaddingVertical, 12);
    });

    test('dark() AI padding is 14h/8v (Figma)', () {
      final s = AppMessageFieldStyle.dark();
      expect(s.aiPaddingHorizontal, 14);
      expect(s.aiPaddingVertical, 8);
    });

    test('dark() itemSpacing is 12 and copyIconSize is 24', () {
      final s = AppMessageFieldStyle.dark();
      expect(s.itemSpacing, 12);
      expect(s.copyIconSize, 24);
    });

    test('dark() userBackgroundColor is AppColors.primary', () {
      expect(
        AppMessageFieldStyle.dark().userBackgroundColor,
        AppColors.primary,
      );
    });

    test('dark() aiBackgroundColor is fully transparent', () {
      expect(AppMessageFieldStyle.dark().aiBackgroundColor.a, 0);
    });

    test('dark() aiBorderColor is white', () {
      expect(AppMessageFieldStyle.dark().aiBorderColor, AppColors.white);
    });

    test('dark() userTextColor is surfaceVariant, aiTextColor is white', () {
      final s = AppMessageFieldStyle.dark();
      expect(s.userTextColor, AppColors.surfaceVariant);
      expect(s.aiTextColor, AppColors.white);
    });

    test('copyWith overrides userBackgroundColor only', () {
      final s = AppMessageFieldStyle.dark();
      final m = s.copyWith(userBackgroundColor: AppColors.error);
      expect(m.userBackgroundColor, AppColors.error);
      expect(m.aiBorderColor, s.aiBorderColor);
    });

    test('lerp t<0.5 keeps borderRadius from this', () {
      final a = AppMessageFieldStyle.dark();
      final b = a.copyWith(borderRadius: 99);
      expect(a.lerp(b, 0.2).borderRadius, a.borderRadius);
      expect(a.lerp(b, 0.8).borderRadius, b.borderRadius);
    });

    test('lerp blends userBackgroundColor at midpoint', () {
      final a = AppMessageFieldStyle.dark();
      final b = a.copyWith(userBackgroundColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).userBackgroundColor,
        Color.lerp(a.userBackgroundColor, b.userBackgroundColor, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppMessageFieldStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
