import 'package:flutter/material.dart';
import '../extensions/app_color_style.dart';
import '../extensions/app_text_styles.dart';
import '../extensions/app_button_style.dart';
import '../extensions/app_input_style.dart';
import '../extensions/app_card_style.dart';
import '../extensions/app_icon_button_style.dart';
import '../extensions/app_link_style.dart';
import '../extensions/app_checkbox_style.dart';
import '../extensions/app_switcher_style.dart';
import '../extensions/app_chip_style.dart';
import '../extensions/app_progress_bar_style.dart';
import '../extensions/app_loader_style.dart';
import '../extensions/app_segmented_picker_style.dart';
import '../extensions/app_segmented_button_style.dart';
import 'app_fonts.dart';

/// The single [ThemeData] used throughout the app.
///
/// Dark theme only — no light theme.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: AppFonts.helveticaNeue,
  useMaterial3: true,
  extensions: [
    AppColorStyle.dark(),
    AppTextStyles.dark(),
    AppButtonStyle.dark(),
    AppInputStyle.dark(),
    AppCardStyle.dark(),
    AppIconButtonStyle.dark(),
    AppLinkStyle.dark(),
    AppCheckboxStyle.dark(),
    AppSwitcherStyle.dark(),
    AppChipStyle.dark(),
    AppProgressBarStyle.dark(),
    AppLoaderStyle.dark(),
    AppSegmentedPickerStyle.dark(),
    AppSegmentedButtonStyle.dark(),
  ],
);
