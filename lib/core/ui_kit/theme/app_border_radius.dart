// lib/core/ui_kit/theme/app_border_radius.dart

/// Semantic border radius constants derived from design tokens.
///
/// Maps raw pixel values from [design/tokens.json] to named roles.
/// Sub-8 values from the token file are intentionally excluded
/// as they do not appear in any current screen designs.
class AppBorderRadius {
  AppBorderRadius._();

  static const s = 8.0;
  static const m = 12.0;
  static const ml = 14.0;
  static const l = 16.0;
  static const xl = 20.0;
  static const full = 999.0;
}
