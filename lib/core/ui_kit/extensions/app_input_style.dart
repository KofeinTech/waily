import 'package:flutter/material.dart';

@immutable
class AppInputStyle extends ThemeExtension<AppInputStyle> {
  const AppInputStyle._();
  factory AppInputStyle.dark() => const AppInputStyle._();
  @override
  AppInputStyle copyWith() => this;
  @override
  AppInputStyle lerp(ThemeExtension<AppInputStyle>? other, double t) => this;
}
