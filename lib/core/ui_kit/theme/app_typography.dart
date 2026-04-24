// lib/core/ui_kit/theme/app_typography.dart
import 'package:flutter/painting.dart';
import 'app_fonts.dart';

/// Static TextStyle factory methods.
///
/// Naming convention: s{fontSize}w{fontWeight}
/// Line height formula: height = lineHeightPx / fontSize
/// Every style applies [TextLeadingDistribution.even] to match Figma.
class AppTypography {
  AppTypography._();

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required double lineHeightPx,
    required double letterSpacing,
    Color? color,
  }) => TextStyle(
    fontFamily: AppFonts.helveticaNeue,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: lineHeightPx / fontSize,
    letterSpacing: letterSpacing,
    leadingDistribution: TextLeadingDistribution.even,
    color: color,
  );

  /// 12sp / w500 / lh 16
  static TextStyle s12w500({Color? color}) => _base(
    fontSize: 12, fontWeight: FontWeight.w500,
    lineHeightPx: 16, letterSpacing: -0.12, color: color,
  );

  /// 14sp / w400 / lh 18
  static TextStyle s14w400({Color? color}) => _base(
    fontSize: 14, fontWeight: FontWeight.w400,
    lineHeightPx: 18, letterSpacing: -0.14, color: color,
  );

  /// 14sp / w500 / lh 18
  static TextStyle s14w500({Color? color}) => _base(
    fontSize: 14, fontWeight: FontWeight.w500,
    lineHeightPx: 18, letterSpacing: -0.14, color: color,
  );

  /// 16sp / w400 / lh 20
  static TextStyle s16w400({Color? color}) => _base(
    fontSize: 16, fontWeight: FontWeight.w400,
    lineHeightPx: 20, letterSpacing: -0.32, color: color,
  );

  /// 16sp / w500 / lh 20
  static TextStyle s16w500({Color? color}) => _base(
    fontSize: 16, fontWeight: FontWeight.w500,
    lineHeightPx: 20, letterSpacing: -0.32, color: color,
  );

  /// 18sp / w400 / lh 22
  static TextStyle s18w400({Color? color}) => _base(
    fontSize: 18, fontWeight: FontWeight.w400,
    lineHeightPx: 22, letterSpacing: -0.18, color: color,
  );

  /// 18sp / w500 / lh 22
  static TextStyle s18w500({Color? color}) => _base(
    fontSize: 18, fontWeight: FontWeight.w500,
    lineHeightPx: 22, letterSpacing: -0.18, color: color,
  );

  /// 20sp / w500 / lh 24
  static TextStyle s20w500({Color? color}) => _base(
    fontSize: 20, fontWeight: FontWeight.w500,
    lineHeightPx: 24, letterSpacing: -0.20, color: color,
  );

  /// 24sp / w500 / lh 28
  static TextStyle s24w500({Color? color}) => _base(
    fontSize: 24, fontWeight: FontWeight.w500,
    lineHeightPx: 28, letterSpacing: -0.48, color: color,
  );

  /// 28sp / w500 / lh 32
  static TextStyle s28w500({Color? color}) => _base(
    fontSize: 28, fontWeight: FontWeight.w500,
    lineHeightPx: 32, letterSpacing: -0.84, color: color,
  );

  /// 32sp / w500 / lh 36
  static TextStyle s32w500({Color? color}) => _base(
    fontSize: 32, fontWeight: FontWeight.w500,
    lineHeightPx: 36, letterSpacing: -0.96, color: color,
  );

  /// 44sp / w500 / lh 48
  static TextStyle s44w500({Color? color}) => _base(
    fontSize: 44, fontWeight: FontWeight.w500,
    lineHeightPx: 48, letterSpacing: -1.32, color: color,
  );
}
