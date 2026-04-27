import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_chat_input_field_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppChatInputFieldStyle', () {
    test('dark() minHeight is 52 (Figma)', () {
      expect(AppChatInputFieldStyle.dark().minHeight, 52);
    });

    test('dark() borderRadius is AppBorderRadius.m (12)', () {
      expect(AppChatInputFieldStyle.dark().borderRadius, AppBorderRadius.m);
    });

    test('dark() actionButtonSize is 40 and iconSize is 24', () {
      final s = AppChatInputFieldStyle.dark();
      expect(s.actionButtonSize, 40);
      expect(s.iconSize, 24);
    });

    test('dark() backgroundColor is AppColors.surface', () {
      expect(AppChatInputFieldStyle.dark().backgroundColor, AppColors.surface);
    });

    test('dark() disabledBackgroundColor is AppColors.textSecondary', () {
      expect(
        AppChatInputFieldStyle.dark().disabledBackgroundColor,
        AppColors.textSecondary,
      );
    });

    test('dark() actionButtonBackgroundColor is AppColors.primary', () {
      expect(
        AppChatInputFieldStyle.dark().actionButtonBackgroundColor,
        AppColors.primary,
      );
    });

    test('dark() textColor is white, placeholderColor is textSecondary', () {
      final s = AppChatInputFieldStyle.dark();
      expect(s.textColor, AppColors.white);
      expect(s.placeholderColor, AppColors.textSecondary);
    });

    test('copyWith overrides backgroundColor only', () {
      final s = AppChatInputFieldStyle.dark();
      final m = s.copyWith(backgroundColor: AppColors.error);
      expect(m.backgroundColor, AppColors.error);
      expect(m.textColor, s.textColor);
    });

    test('lerp t<0.5 keeps minHeight from this', () {
      final a = AppChatInputFieldStyle.dark();
      final b = a.copyWith(minHeight: 99);
      expect(a.lerp(b, 0.2).minHeight, a.minHeight);
      expect(a.lerp(b, 0.8).minHeight, b.minHeight);
    });

    test('lerp blends actionButtonBackgroundColor at midpoint', () {
      final a = AppChatInputFieldStyle.dark();
      final b = a.copyWith(actionButtonBackgroundColor: AppColors.error);
      expect(
        a.lerp(b, 0.5).actionButtonBackgroundColor,
        Color.lerp(
          a.actionButtonBackgroundColor,
          b.actionButtonBackgroundColor,
          0.5,
        ),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppChatInputFieldStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
