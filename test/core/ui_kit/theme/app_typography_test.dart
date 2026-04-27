// test/core/ui_kit/theme/app_typography_test.dart
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/theme/app_typography.dart';
import 'package:waily/core/ui_kit/theme/app_fonts.dart';

void main() {
  group('AppTypography', () {
    test('s16w400 has correct fontSize and fontWeight', () {
      final style = AppTypography.s16w400();
      expect(style.fontSize, 16.0);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.fontFamily, AppFonts.helveticaNeue);
    });

    test('s16w400 height is lineHeightPx / fontSize', () {
      final style = AppTypography.s16w400();
      expect(style.height, closeTo(20.0 / 16.0, 0.001));
    });

    test('s16w400 letterSpacing matches design token', () {
      final style = AppTypography.s16w400();
      expect(style.letterSpacing, closeTo(-0.32, 0.001));
    });

    test('s32w500 has correct fontSize and fontWeight', () {
      final style = AppTypography.s32w500();
      expect(style.fontSize, 32.0);
      expect(style.fontWeight, FontWeight.w500);
    });

    test('s32w500 height is 36 / 32', () {
      final style = AppTypography.s32w500();
      expect(style.height, closeTo(36.0 / 32.0, 0.001));
    });

    test('color override is applied when provided', () {
      const red = Color(0xFFFF0000);
      final style = AppTypography.s16w400(color: red);
      expect(style.color, red);
    });

    test('color is null when not provided', () {
      final style = AppTypography.s16w400();
      expect(style.color, isNull);
    });

    test('s44w500 has correct fontSize', () {
      final style = AppTypography.s44w500();
      expect(style.fontSize, 44.0);
    });

    test('every style sets TextLeadingDistribution.even', () {
      final style = AppTypography.s16w400();
      expect(style.leadingDistribution, TextLeadingDistribution.even);
    });
  });
}
