// lib/core/ui_kit/theme/app_fonts.dart

/// Font family name constants.
///
/// Helvetica Neue is the single design-system font for Waily.
/// On iOS it is a system font — no bundling required.
/// On Android, Flutter falls back to Roboto.
///
/// Note: `design/tokens.json` contains other font families (SF Pro, Freigeist,
/// Inter) that appear in Figma as design-tool artefacts. They are intentionally
/// excluded — do not add them here.
class AppFonts {
  AppFonts._();

  static const helveticaNeue = 'Helvetica Neue';
}
