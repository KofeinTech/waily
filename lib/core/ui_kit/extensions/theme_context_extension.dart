import 'package:flutter/material.dart';
import 'app_color_style.dart';
import 'app_text_styles.dart';
import 'app_button_style.dart';
import 'app_input_style.dart';
import 'app_card_style.dart';
import 'app_icon_button_style.dart';
import 'app_link_style.dart';
import 'app_checkbox_style.dart';
import 'app_switcher_style.dart';
import 'app_chip_style.dart';
import 'app_progress_bar_style.dart';
import 'app_loader_style.dart';
import 'app_segmented_picker_style.dart';
import 'app_segmented_button_style.dart';

/// BuildContext shortcuts for all UI kit ThemeExtensions.
///
/// Usage:
/// ```dart
/// context.appColors.background
/// context.appTextStyles.s16w500()
/// context.appButtonStyle.primaryBackground
/// ```
extension ThemeContextExtension on BuildContext {
  AppColorStyle get appColors => Theme.of(this).extension<AppColorStyle>()!;
  AppTextStyles get appTextStyles => Theme.of(this).extension<AppTextStyles>()!;
  AppButtonStyle get appButtonStyle =>
      Theme.of(this).extension<AppButtonStyle>()!;
  AppInputStyle get appInputStyle => Theme.of(this).extension<AppInputStyle>()!;
  AppCardStyle get appCardStyle => Theme.of(this).extension<AppCardStyle>()!;
  AppIconButtonStyle get appIconButtonStyle =>
      Theme.of(this).extension<AppIconButtonStyle>()!;
  AppLinkStyle get appLinkStyle => Theme.of(this).extension<AppLinkStyle>()!;
  AppCheckboxStyle get appCheckboxStyle =>
      Theme.of(this).extension<AppCheckboxStyle>()!;
  AppSwitcherStyle get appSwitcherStyle =>
      Theme.of(this).extension<AppSwitcherStyle>()!;
  AppChipStyle get appChipStyle => Theme.of(this).extension<AppChipStyle>()!;
  AppProgressBarStyle get appProgressBarStyle =>
      Theme.of(this).extension<AppProgressBarStyle>()!;
  AppLoaderStyle get appLoaderStyle =>
      Theme.of(this).extension<AppLoaderStyle>()!;
  AppSegmentedPickerStyle get appSegmentedPickerStyle =>
      Theme.of(this).extension<AppSegmentedPickerStyle>()!;
  AppSegmentedButtonStyle get appSegmentedButtonStyle =>
      Theme.of(this).extension<AppSegmentedButtonStyle>()!;
}
