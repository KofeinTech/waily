import 'package:flutter/material.dart';

@immutable
class AppCardStyle extends ThemeExtension<AppCardStyle> {
  const AppCardStyle._();
  factory AppCardStyle.dark() => const AppCardStyle._();
  @override
  AppCardStyle copyWith() => this;
  @override
  AppCardStyle lerp(ThemeExtension<AppCardStyle>? other, double t) => this;
}
