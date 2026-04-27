import 'package:flutter/painting.dart';

/// Design system color constants.
///
/// All values sourced from [design/tokens.json] (Figma export).
/// Names reflect semantic role, not raw hue.
class AppColors {
  AppColors._();

  // --- Backgrounds ---
  static const background = Color(0xFF020815); // app background
  static const surface = Color(0xFF1D2534); // cards, sheets
  static const surfaceVariant = Color(0xFF252B38); // elevated surface
  static const surfaceHigh = Color(0xFF1F2A42); // highlighted surface

  // --- Borders / Dividers ---
  static const border = Color(0xFF363B4B);
  static const borderStrong = Color(0xFF3D475E);

  // --- Primary Brand ---
  // Figma "Button / Primary, Default" fills with #D4E1FF; primary is the subtle blue.
  static const primary = Color(0xFFD4E1FF);
  static const primarySubtle = primary;
  static const primaryLight = Color(0xFFA1C1FF);
  static const primaryLowest = Color(0xFFE5EDFF);

  // --- Text ---
  static const textPrimary = Color(0xFFFEFEFE);
  static const textSecondary = Color(0xFF9EA3AE);
  static const textTertiary = Color(0xFF7F8799);
  static const textDisabled = Color(0xFF555A66);
  static const textPlaceholder = Color(0xFF646C7E); // disabled label across Button, Input field, Chat Input, Chat Tip, Selector
  static const textMuted = Color(0xFF8C8C8C); // icon/label on Segmented btn and Text Input
  static const textInfo = Color(0xFF383333); // info text in List element

  // --- Semantic ---
  static const error = Color(0xFFD52D2D);
  static const errorVariant = Color(0xFFEA4335);
  static const success = Color(0xFF34A853);
  static const warning = Color(0xFFFBBC05);

  // --- Neutrals ---
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
}
