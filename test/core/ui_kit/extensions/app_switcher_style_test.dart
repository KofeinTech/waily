import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_switcher_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppSwitcherStyle', () {
    test('dark() trackWidth/trackHeight is 64x32 (Figma)', () {
      final s = AppSwitcherStyle.dark();
      expect(s.trackWidth, 64);
      expect(s.trackHeight, 32);
    });

    test('dark() thumbSize is 25.6 (Figma circle diameter)', () {
      expect(AppSwitcherStyle.dark().thumbSize, 25.6);
    });

    test('dark() thumbPadding is 3.2 (Figma inset)', () {
      expect(AppSwitcherStyle.dark().thumbPadding, 3.2);
    });

    test('dark() trackColorOff is white', () {
      expect(AppSwitcherStyle.dark().trackColorOff, AppColors.white);
    });

    test('dark() trackColorOn is AppColors.primary (#D4E1FF)', () {
      expect(AppSwitcherStyle.dark().trackColorOn, AppColors.primary);
    });

    test('dark() thumbColorOff is AppColors.textTertiary (#7F8799)', () {
      expect(AppSwitcherStyle.dark().thumbColorOff, AppColors.textTertiary);
    });

    test('dark() thumbColorOn is AppColors.borderStrong (#3D475E)', () {
      expect(AppSwitcherStyle.dark().thumbColorOn, AppColors.borderStrong);
    });

    test('copyWith overrides trackColorOn only', () {
      final s = AppSwitcherStyle.dark();
      final m = s.copyWith(trackColorOn: AppColors.error);
      expect(m.trackColorOn, AppColors.error);
      expect(m.thumbColorOn, s.thumbColorOn);
    });

    test('lerp t<0.5 keeps thumbSize from this', () {
      final a = AppSwitcherStyle.dark();
      final b = a.copyWith(thumbSize: 99);
      expect(a.lerp(b, 0.2).thumbSize, a.thumbSize);
      expect(a.lerp(b, 0.8).thumbSize, b.thumbSize);
    });

    test('lerp blends thumbColorOn at midpoint', () {
      final a = AppSwitcherStyle.dark();
      final b = a.copyWith(thumbColorOn: AppColors.error);
      expect(
        a.lerp(b, 0.5).thumbColorOn,
        Color.lerp(a.thumbColorOn, b.thumbColorOn, 0.5),
      );
    });

    test('lerp returns this when other is null', () {
      final a = AppSwitcherStyle.dark();
      expect(a.lerp(null, 0.5), same(a));
    });
  });
}
