import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Theme-aware text styles.
///
/// Delegates to [AppTypography], applying the theme's default text color
/// unless a [color] override is provided.
///
/// Example:
/// ```dart
/// Text('Hello', style: context.appTextStyles.s16w500())
/// ```
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles._(this._textColor);

  final Color _textColor;

  factory AppTextStyles.dark() => const AppTextStyles._(AppColors.textPrimary);

  TextStyle s12w500({Color? color}) =>
      AppTypography.s12w500(color: color ?? _textColor);
  TextStyle s14w400({Color? color}) =>
      AppTypography.s14w400(color: color ?? _textColor);
  TextStyle s14w500({Color? color}) =>
      AppTypography.s14w500(color: color ?? _textColor);
  TextStyle s16w400({Color? color}) =>
      AppTypography.s16w400(color: color ?? _textColor);
  TextStyle s16w500({Color? color}) =>
      AppTypography.s16w500(color: color ?? _textColor);
  TextStyle s18w400({Color? color}) =>
      AppTypography.s18w400(color: color ?? _textColor);
  TextStyle s18w500({Color? color}) =>
      AppTypography.s18w500(color: color ?? _textColor);
  TextStyle s20w500({Color? color}) =>
      AppTypography.s20w500(color: color ?? _textColor);
  TextStyle s24w500({Color? color}) =>
      AppTypography.s24w500(color: color ?? _textColor);
  TextStyle s28w500({Color? color}) =>
      AppTypography.s28w500(color: color ?? _textColor);
  TextStyle s32w500({Color? color}) =>
      AppTypography.s32w500(color: color ?? _textColor);
  TextStyle s44w500({Color? color}) =>
      AppTypography.s44w500(color: color ?? _textColor);

  @override
  AppTextStyles copyWith({Color? textColor}) =>
      AppTextStyles._(textColor ?? _textColor);

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles._(
      Color.lerp(_textColor, other._textColor, t) ?? _textColor,
    );
  }
}
