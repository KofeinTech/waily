import 'package:flutter/material.dart';

@immutable
class AppButtonStyle extends ThemeExtension<AppButtonStyle> {
  const AppButtonStyle._();
  factory AppButtonStyle.dark() => const AppButtonStyle._();
  @override
  AppButtonStyle copyWith() => this;
  @override
  AppButtonStyle lerp(ThemeExtension<AppButtonStyle>? other, double t) => this;
}
