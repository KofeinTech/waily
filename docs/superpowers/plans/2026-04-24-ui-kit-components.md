# UI Kit — Design Tokens and Reusable Components

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete `lib/core/ui_kit/` layer — design tokens, five ThemeExtensions, four widget components, and widget tests — on top of dark-theme-only configuration.

**Architecture:** ThemeExtension-per-component per CLAUDE.md. Static token classes (`AppColors`, `AppTypography`, `AppSpacing`, `AppBorderRadius`) provide raw values; ThemeExtension classes (`AppColorStyle`, `AppTextStyles`, `AppButtonStyle`, `AppInputStyle`, `AppCardStyle`) wrap those values in a theme-aware API; widget components (`WailyButton`, `WailyCard`, `WailyTextField`, `WailyIcon`) read from ThemeExtensions via `BuildContext` shortcuts. Widget tests serve as the showcase.

**Tech Stack:** Flutter (FVM 3.38.6), flutter_svg ^2.2.4, flutter_gen (output: `lib/core/gen/`), `WidgetStateProperty` (Material 3 API)

---

## File Map

**Create:**
- `lib/core/ui_kit/theme/app_fonts.dart`
- `lib/core/ui_kit/theme/app_spacing.dart`
- `lib/core/ui_kit/theme/app_border_radius.dart`
- `lib/core/ui_kit/theme/app_colors.dart`
- `lib/core/ui_kit/theme/app_typography.dart`
- `lib/core/ui_kit/theme/app_theme.dart`
- `lib/core/ui_kit/extensions/app_color_style.dart`
- `lib/core/ui_kit/extensions/app_text_styles.dart`
- `lib/core/ui_kit/extensions/app_button_style.dart`
- `lib/core/ui_kit/extensions/app_input_style.dart`
- `lib/core/ui_kit/extensions/app_card_style.dart`
- `lib/core/ui_kit/extensions/theme_context_extension.dart`
- `lib/core/ui_kit/components/buttons/waily_button.dart`
- `lib/core/ui_kit/components/inputs/waily_text_field.dart`
- `lib/core/ui_kit/components/cards/waily_card.dart`
- `lib/core/ui_kit/components/icons/waily_icon.dart`
- `lib/core/ui_kit/index.dart`
- `assets/icons/placeholder.svg`
- `test/core/ui_kit/helpers/test_theme_wrapper.dart`
- `test/core/ui_kit/theme/app_typography_test.dart`
- `test/core/ui_kit/extensions/app_color_style_test.dart`
- `test/core/ui_kit/extensions/app_text_styles_test.dart`
- `test/core/ui_kit/components/waily_button_test.dart`
- `test/core/ui_kit/components/waily_text_field_test.dart`
- `test/core/ui_kit/components/waily_card_test.dart`
- `test/core/ui_kit/components/waily_icon_test.dart`

**Modify:**
- `lib/main.dart` — wire `darkTheme`

---

## Task 1: Figma Token Export (Prerequisite)

**Files:**
- Read: `design/tokens.json` (already exists — raw hex without names)
- Produce: updated export with named tokens (after running figma-export)

This task has no TDD — it is a data-gathering step. Run it before writing any Dart.

- [ ] **Step 1: Export design tokens from Figma**

```bash
# Run this slash command in Claude Code
/improvs:figma-export https://www.figma.com/design/fHb7WGklKtujnCbzxnLDdx/Waily-Mobile-App?node-id=206-63502&p=f&m=dev
```

Expected: new or updated JSON file appears in `design/` with named color tokens.

- [ ] **Step 2: Read the export output**

Open the produced JSON. Identify the semantic color names (e.g. `background`, `primary`, `textPrimary`, `error`). These names will drive `AppColors` in Task 3.

If the export does not produce named tokens (only raw hex), proceed with the semantic names used in Task 3 — they are derived from the role each color plays in the existing screen designs.

- [ ] **Step 3: Commit the export**

```bash
git add design/
git commit -m "chore(wail-10): export figma design tokens"
```

---

## Task 2: Static Token Foundation

**Files:**
- Create: `lib/core/ui_kit/theme/app_fonts.dart`
- Create: `lib/core/ui_kit/theme/app_spacing.dart`
- Create: `lib/core/ui_kit/theme/app_border_radius.dart`

These are pure constant classes — no ThemeExtension, no test needed (constants are compile-time checked). Remove the `.gitkeep` from `lib/core/ui_kit/`.

- [ ] **Step 1: Delete .gitkeep**

```bash
rm lib/core/ui_kit/.gitkeep
```

- [ ] **Step 2: Create app_fonts.dart**

```dart
// lib/core/ui_kit/theme/app_fonts.dart

/// Font family name constants.
///
/// Helvetica Neue is a system font on iOS — no bundling required.
/// On Android, Flutter falls back to Roboto.
class AppFonts {
  AppFonts._();

  static const helveticaNeue = 'Helvetica Neue';
}
```

- [ ] **Step 3: Create app_spacing.dart**

```dart
// lib/core/ui_kit/theme/app_spacing.dart

/// Semantic spacing constants derived from design tokens.
///
/// Maps raw pixel values from [design/tokens.json] to named roles.
class AppSpacing {
  AppSpacing._();

  static const xs  = 4.0;
  static const s   = 8.0;
  static const m   = 16.0;
  static const l   = 24.0;
  static const xl  = 32.0;
  static const xxl = 40.0;
}
```

- [ ] **Step 4: Create app_border_radius.dart**

```dart
// lib/core/ui_kit/theme/app_border_radius.dart

/// Semantic border radius constants derived from design tokens.
class AppBorderRadius {
  AppBorderRadius._();

  static const s    = 8.0;
  static const m    = 12.0;
  static const l    = 16.0;
  static const xl   = 20.0;
  static const full = 999.0;
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/theme/
git commit -m "feat(wail-10): add static token foundation (fonts, spacing, radii)"
```

---

## Task 3: AppColors

**Files:**
- Create: `lib/core/ui_kit/theme/app_colors.dart`

Named hex constants. If the Figma export (Task 1) produced semantic names that differ from those below, rename accordingly. Names below are derived from each color's role in the screen designs.

- [ ] **Step 1: Create app_colors.dart**

```dart
// lib/core/ui_kit/theme/app_colors.dart
import 'package:flutter/painting.dart';

/// Design system color constants.
///
/// All values sourced from [design/tokens.json] (Figma export).
/// Names reflect semantic role, not raw hue.
class AppColors {
  AppColors._();

  // --- Backgrounds ---
  static const background     = Color(0xFF020815); // app background
  static const surface        = Color(0xFF1D2534); // cards, sheets
  static const surfaceVariant = Color(0xFF252B38); // elevated surface
  static const surfaceHigh    = Color(0xFF1F2A42); // highlighted surface

  // --- Borders / Dividers ---
  static const border         = Color(0xFF363B4B);
  static const borderStrong   = Color(0xFF3D475E);

  // --- Primary Brand ---
  static const primary        = Color(0xFF4285F4);
  static const primaryLight   = Color(0xFFA1C1FF);
  static const primarySubtle  = Color(0xFFD4E1FF);
  static const primaryLowest  = Color(0xFFE5EDFF);

  // --- Text ---
  static const textPrimary    = Color(0xFFFEFEFE);
  static const textSecondary  = Color(0xFF9EA3AE);
  static const textTertiary   = Color(0xFF7F8799);
  static const textDisabled   = Color(0xFF555A66);

  // --- Semantic ---
  static const error          = Color(0xFFD52D2D);
  static const errorVariant   = Color(0xFFEA4335);
  static const success        = Color(0xFF34A853);
  static const warning        = Color(0xFFFBBC05);

  // --- Neutrals ---
  static const black          = Color(0xFF000000);
  static const white          = Color(0xFFFFFFFF);
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/ui_kit/theme/app_colors.dart
git commit -m "feat(wail-10): add AppColors from design tokens"
```

---

## Task 4: AppTypography (TDD)

**Files:**
- Create: `lib/core/ui_kit/theme/app_typography.dart`
- Create: `test/core/ui_kit/theme/app_typography_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/core/ui_kit/theme/app_typography_test.dart
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/theme/app_typography.dart';
import 'package:waily/core/ui_kit/theme/app_fonts.dart';

void main() {
  group('AppTypography', () {
    test('s16w400 has correct fontSize and fontWeight', () {
      final style = AppTypography.s16w400();
      expect(style.fontSize, 16.0);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.fontFamily, AppFonts.helveticaNeue);
    });

    test('s16w400 height is lineHeightPx / fontSize', () {
      final style = AppTypography.s16w400();
      expect(style.height, closeTo(20.0 / 16.0, 0.001));
    });

    test('s16w400 letterSpacing matches design token', () {
      final style = AppTypography.s16w400();
      expect(style.letterSpacing, closeTo(-0.32, 0.001));
    });

    test('s32w500 has correct fontSize and fontWeight', () {
      final style = AppTypography.s32w500();
      expect(style.fontSize, 32.0);
      expect(style.fontWeight, FontWeight.w500);
    });

    test('s32w500 height is 36 / 32', () {
      final style = AppTypography.s32w500();
      expect(style.height, closeTo(36.0 / 32.0, 0.001));
    });

    test('color override is applied when provided', () {
      const red = Color(0xFFFF0000);
      final style = AppTypography.s16w400(color: red);
      expect(style.color, red);
    });

    test('color is null when not provided', () {
      final style = AppTypography.s16w400();
      expect(style.color, isNull);
    });

    test('s44w500 has correct fontSize', () {
      final style = AppTypography.s44w500();
      expect(style.fontSize, 44.0);
    });

    test('every style sets TextLeadingDistribution.even', () {
      final style = AppTypography.s16w400();
      expect(
        style.textHeightBehavior?.leadingDistribution,
        TextLeadingDistribution.even,
      );
    });
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/theme/app_typography_test.dart
```

Expected: compilation error — `AppTypography` not found.

- [ ] **Step 3: Create app_typography.dart**

```dart
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

  static const _behavior = TextHeightBehavior(
    leadingDistribution: TextLeadingDistribution.even,
  );

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
    color: color,
    textHeightBehavior: _behavior,
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
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/theme/app_typography_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/theme/app_typography.dart test/core/ui_kit/theme/
git commit -m "feat(wail-10): add AppTypography with TDD"
```

---

## Task 5: AppColorStyle + AppTextStyles ThemeExtensions (TDD)

**Files:**
- Create: `lib/core/ui_kit/extensions/app_color_style.dart`
- Create: `lib/core/ui_kit/extensions/app_text_styles.dart`
- Create: `test/core/ui_kit/extensions/app_color_style_test.dart`
- Create: `test/core/ui_kit/extensions/app_text_styles_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/core/ui_kit/extensions/app_color_style_test.dart
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_color_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppColorStyle', () {
    test('dark() background equals AppColors.background', () {
      expect(AppColorStyle.dark().background, AppColors.background);
    });

    test('dark() primary equals AppColors.primary', () {
      expect(AppColorStyle.dark().primary, AppColors.primary);
    });

    test('dark() error equals AppColors.error', () {
      expect(AppColorStyle.dark().error, AppColors.error);
    });

    test('copyWith overrides specified field', () {
      final original = AppColorStyle.dark();
      const newColor = Color(0xFF123456);
      final modified = original.copyWith(background: newColor);
      expect(modified.background, newColor);
      expect(modified.primary, original.primary);
    });

    test('copyWith without args returns equivalent object', () {
      final style = AppColorStyle.dark();
      final copy = style.copyWith();
      expect(copy.background, style.background);
      expect(copy.primary, style.primary);
    });

    test('lerp at t=0 returns this', () {
      final a = AppColorStyle.dark();
      final b = a.copyWith(background: const Color(0xFFFFFFFF));
      final result = a.lerp(b, 0.0);
      expect(result.background, a.background);
    });

    test('lerp at t=1 returns other', () {
      final a = AppColorStyle.dark();
      final b = a.copyWith(background: const Color(0xFFFFFFFF));
      final result = a.lerp(b, 1.0);
      expect(result.background, b.background);
    });
  });
}
```

```dart
// test/core/ui_kit/extensions/app_text_styles_test.dart
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_text_styles.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppTextStyles', () {
    test('s16w400 returns style with fontSize 16', () {
      expect(AppTextStyles.dark().s16w400().fontSize, 16.0);
    });

    test('s32w500 returns style with fontSize 32', () {
      expect(AppTextStyles.dark().s32w500().fontSize, 32.0);
    });

    test('default color is AppColors.textPrimary', () {
      final style = AppTextStyles.dark().s16w400();
      expect(style.color, AppColors.textPrimary);
    });

    test('color override replaces default', () {
      const red = Color(0xFFFF0000);
      final style = AppTextStyles.dark().s16w400(color: red);
      expect(style.color, red);
    });

    test('lerp at t=0 returns this textColor', () {
      final a = AppTextStyles.dark();
      final b = AppTextStyles.dark().copyWith(textColor: const Color(0xFFAAAAAA));
      final result = a.lerp(b, 0.0);
      expect(result.s16w400().color, AppColors.textPrimary);
    });
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/extensions/
```

Expected: compilation error — classes not found.

- [ ] **Step 3: Create app_color_style.dart**

```dart
// lib/core/ui_kit/extensions/app_color_style.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Theme-aware color roles for the dark Waily theme.
///
/// Example:
/// ```dart
/// Container(color: context.appColors.background)
/// ```
@immutable
class AppColorStyle extends ThemeExtension<AppColorStyle> {
  const AppColorStyle._({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.primaryLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.error,
    required this.success,
    required this.icon,
    required this.iconDisabled,
    required this.border,
    required this.divider,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color primaryLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color error;
  final Color success;
  final Color icon;
  final Color iconDisabled;
  final Color border;
  final Color divider;

  /// Dark theme color assignments.
  factory AppColorStyle.dark() => const AppColorStyle._(
    background:    AppColors.background,
    surface:       AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    primary:       AppColors.primary,
    primaryLight:  AppColors.primaryLight,
    textPrimary:   AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textDisabled:  AppColors.textDisabled,
    error:         AppColors.error,
    success:       AppColors.success,
    icon:          AppColors.textSecondary,
    iconDisabled:  AppColors.textDisabled,
    border:        AppColors.border,
    divider:       AppColors.surfaceVariant,
  );

  @override
  AppColorStyle copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? primary,
    Color? primaryLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? error,
    Color? success,
    Color? icon,
    Color? iconDisabled,
    Color? border,
    Color? divider,
  }) => AppColorStyle._(
    background:    background    ?? this.background,
    surface:       surface       ?? this.surface,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    primary:       primary       ?? this.primary,
    primaryLight:  primaryLight  ?? this.primaryLight,
    textPrimary:   textPrimary   ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textDisabled:  textDisabled  ?? this.textDisabled,
    error:         error         ?? this.error,
    success:       success       ?? this.success,
    icon:          icon          ?? this.icon,
    iconDisabled:  iconDisabled  ?? this.iconDisabled,
    border:        border        ?? this.border,
    divider:       divider       ?? this.divider,
  );

  @override
  AppColorStyle lerp(ThemeExtension<AppColorStyle>? other, double t) {
    if (other is! AppColorStyle) return this;
    return AppColorStyle._(
      background:    Color.lerp(background,    other.background,    t) ?? background,
      surface:       Color.lerp(surface,       other.surface,       t) ?? surface,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t) ?? surfaceVariant,
      primary:       Color.lerp(primary,       other.primary,       t) ?? primary,
      primaryLight:  Color.lerp(primaryLight,  other.primaryLight,  t) ?? primaryLight,
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textDisabled:  Color.lerp(textDisabled,  other.textDisabled,  t) ?? textDisabled,
      error:         Color.lerp(error,         other.error,         t) ?? error,
      success:       Color.lerp(success,       other.success,       t) ?? success,
      icon:          Color.lerp(icon,          other.icon,          t) ?? icon,
      iconDisabled:  Color.lerp(iconDisabled,  other.iconDisabled,  t) ?? iconDisabled,
      border:        Color.lerp(border,        other.border,        t) ?? border,
      divider:       Color.lerp(divider,       other.divider,       t) ?? divider,
    );
  }
}
```

- [ ] **Step 4: Create app_text_styles.dart**

```dart
// lib/core/ui_kit/extensions/app_text_styles.dart
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

  TextStyle s12w500({Color? color}) => AppTypography.s12w500(color: color ?? _textColor);
  TextStyle s14w400({Color? color}) => AppTypography.s14w400(color: color ?? _textColor);
  TextStyle s14w500({Color? color}) => AppTypography.s14w500(color: color ?? _textColor);
  TextStyle s16w400({Color? color}) => AppTypography.s16w400(color: color ?? _textColor);
  TextStyle s16w500({Color? color}) => AppTypography.s16w500(color: color ?? _textColor);
  TextStyle s18w400({Color? color}) => AppTypography.s18w400(color: color ?? _textColor);
  TextStyle s18w500({Color? color}) => AppTypography.s18w500(color: color ?? _textColor);
  TextStyle s20w500({Color? color}) => AppTypography.s20w500(color: color ?? _textColor);
  TextStyle s24w500({Color? color}) => AppTypography.s24w500(color: color ?? _textColor);
  TextStyle s28w500({Color? color}) => AppTypography.s28w500(color: color ?? _textColor);
  TextStyle s32w500({Color? color}) => AppTypography.s32w500(color: color ?? _textColor);
  TextStyle s44w500({Color? color}) => AppTypography.s44w500(color: color ?? _textColor);

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
```

- [ ] **Step 5: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/extensions/
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/core/ui_kit/extensions/app_color_style.dart \
        lib/core/ui_kit/extensions/app_text_styles.dart \
        test/core/ui_kit/extensions/
git commit -m "feat(wail-10): add AppColorStyle and AppTextStyles ThemeExtensions"
```

---

## Task 6: app_theme.dart + ThemeContextExtension + TestThemeWrapper

**Files:**
- Create: `lib/core/ui_kit/extensions/theme_context_extension.dart`
- Create: `lib/core/ui_kit/theme/app_theme.dart`
- Create: `test/core/ui_kit/helpers/test_theme_wrapper.dart`

No TDD for this task — these are wiring/infrastructure files verified indirectly by all subsequent widget tests.

- [ ] **Step 1: Create theme_context_extension.dart**

The remaining ThemeExtensions (`AppButtonStyle`, `AppInputStyle`, `AppCardStyle`) are not yet defined. Add their accessors now as forward declarations — the files will exist after Tasks 7–9.

```dart
// lib/core/ui_kit/extensions/theme_context_extension.dart
import 'package:flutter/material.dart';
import 'app_color_style.dart';
import 'app_text_styles.dart';
import 'app_button_style.dart';
import 'app_input_style.dart';
import 'app_card_style.dart';

/// BuildContext shortcuts for all UI kit ThemeExtensions.
///
/// Usage:
/// ```dart
/// context.appColors.background
/// context.appTextStyles.s16w500()
/// context.appButtonStyle.primaryBackground
/// ```
extension ThemeContextExtension on BuildContext {
  AppColorStyle  get appColors      => Theme.of(this).extension<AppColorStyle>()!;
  AppTextStyles  get appTextStyles  => Theme.of(this).extension<AppTextStyles>()!;
  AppButtonStyle get appButtonStyle => Theme.of(this).extension<AppButtonStyle>()!;
  AppInputStyle  get appInputStyle  => Theme.of(this).extension<AppInputStyle>()!;
  AppCardStyle   get appCardStyle   => Theme.of(this).extension<AppCardStyle>()!;
}
```

Note: this file imports `app_button_style.dart`, `app_input_style.dart`, `app_card_style.dart` which will be created in Tasks 7–9. The file will not compile until those tasks are done — that is expected. `app_theme.dart` and the TestThemeWrapper also depend on those files. Create them now and complete the compile in Task 9.

- [ ] **Step 2: Create app_button_style.dart stub (temporary)**

Create an empty stub so `theme_context_extension.dart` compiles after Task 6. It will be replaced entirely in Task 7.

```dart
// lib/core/ui_kit/extensions/app_button_style.dart
import 'package:flutter/material.dart';

@immutable
class AppButtonStyle extends ThemeExtension<AppButtonStyle> {
  const AppButtonStyle._();
  factory AppButtonStyle.dark() => const AppButtonStyle._();
  @override AppButtonStyle copyWith() => this;
  @override AppButtonStyle lerp(ThemeExtension<AppButtonStyle>? other, double t) => this;
}
```

- [ ] **Step 3: Create app_input_style.dart stub**

```dart
// lib/core/ui_kit/extensions/app_input_style.dart
import 'package:flutter/material.dart';

@immutable
class AppInputStyle extends ThemeExtension<AppInputStyle> {
  const AppInputStyle._();
  factory AppInputStyle.dark() => const AppInputStyle._();
  @override AppInputStyle copyWith() => this;
  @override AppInputStyle lerp(ThemeExtension<AppInputStyle>? other, double t) => this;
}
```

- [ ] **Step 4: Create app_card_style.dart stub**

```dart
// lib/core/ui_kit/extensions/app_card_style.dart
import 'package:flutter/material.dart';

@immutable
class AppCardStyle extends ThemeExtension<AppCardStyle> {
  const AppCardStyle._();
  factory AppCardStyle.dark() => const AppCardStyle._();
  @override AppCardStyle copyWith() => this;
  @override AppCardStyle lerp(ThemeExtension<AppCardStyle>? other, double t) => this;
}
```

- [ ] **Step 5: Create app_theme.dart**

```dart
// lib/core/ui_kit/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../extensions/app_color_style.dart';
import '../extensions/app_text_styles.dart';
import '../extensions/app_button_style.dart';
import '../extensions/app_input_style.dart';
import '../extensions/app_card_style.dart';
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
  ],
);
```

- [ ] **Step 6: Create test_theme_wrapper.dart**

```dart
// test/core/ui_kit/helpers/test_theme_wrapper.dart
import 'package:flutter/material.dart';
import 'package:waily/core/ui_kit/theme/app_theme.dart';

/// Wraps [child] in a [MaterialApp] configured with [darkTheme].
///
/// Use this in every UI kit widget test:
/// ```dart
/// await tester.pumpWidget(TestThemeWrapper(child: WailyButton(...)));
/// ```
class TestThemeWrapper extends StatelessWidget {
  const TestThemeWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}
```

- [ ] **Step 7: Verify compilation**

```bash
fvm flutter analyze lib/core/ui_kit/
```

Expected: no errors (stubs satisfy all imports).

- [ ] **Step 8: Commit**

```bash
git add lib/core/ui_kit/theme/app_theme.dart \
        lib/core/ui_kit/extensions/ \
        test/core/ui_kit/helpers/
git commit -m "feat(wail-10): add app_theme, ThemeContextExtension, TestThemeWrapper"
```

---

## Task 7: AppButtonStyle (TDD)

**Files:**
- Replace: `lib/core/ui_kit/extensions/app_button_style.dart` (was a stub)

- [ ] **Step 1: Write the failing test**

Add to `test/core/ui_kit/extensions/app_color_style_test.dart` a new file or create:

```dart
// test/core/ui_kit/extensions/app_button_style_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_button_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';

void main() {
  group('AppButtonStyle', () {
    test('dark() primaryBackground is AppColors.primary', () {
      expect(AppButtonStyle.dark().primaryBackground, AppColors.primary);
    });

    test('dark() primaryForeground is AppColors.textPrimary', () {
      expect(AppButtonStyle.dark().primaryForeground, AppColors.textPrimary);
    });

    test('dark() disabledBackground is AppColors.surfaceVariant', () {
      expect(AppButtonStyle.dark().disabledBackground, AppColors.surfaceVariant);
    });

    test('dark() borderRadius is AppBorderRadius.l', () {
      expect(AppButtonStyle.dark().borderRadius, AppBorderRadius.l);
    });

    test('copyWith overrides primaryBackground', () {
      final style = AppButtonStyle.dark();
      final modified = style.copyWith(primaryBackground: AppColors.error);
      expect(modified.primaryBackground, AppColors.error);
      expect(modified.primaryForeground, style.primaryForeground);
    });
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/extensions/app_button_style_test.dart
```

Expected: fail — `AppButtonStyle` stub has no field `primaryBackground`.

- [ ] **Step 3: Replace stub with full AppButtonStyle**

```dart
// lib/core/ui_kit/extensions/app_button_style.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_border_radius.dart';

/// Button style tokens for the dark Waily theme.
///
/// Consumed by [WailyButton] to build [ButtonStyle] without Material defaults.
@immutable
class AppButtonStyle extends ThemeExtension<AppButtonStyle> {
  const AppButtonStyle._({
    required this.primaryBackground,
    required this.primaryForeground,
    required this.secondaryBackground,
    required this.secondaryForeground,
    required this.outlinedBorderColor,
    required this.outlinedForeground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.borderRadius,
    required this.padding,
    required this.textStyle,
  });

  final Color primaryBackground;
  final Color primaryForeground;
  final Color secondaryBackground;
  final Color secondaryForeground;
  final Color outlinedBorderColor;
  final Color outlinedForeground;
  final Color disabledBackground;
  final Color disabledForeground;
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle textStyle;

  factory AppButtonStyle.dark() => AppButtonStyle._(
    primaryBackground:  AppColors.primary,
    primaryForeground:  AppColors.textPrimary,
    secondaryBackground: AppColors.surface,
    secondaryForeground: AppColors.textPrimary,
    outlinedBorderColor: AppColors.primary,
    outlinedForeground:  AppColors.primary,
    disabledBackground:  AppColors.surfaceVariant,
    disabledForeground:  AppColors.textDisabled,
    borderRadius: AppBorderRadius.l,
    padding: const EdgeInsets.symmetric(
      vertical: AppSpacing.m,
      horizontal: AppSpacing.l,
    ),
    textStyle: AppTypography.s16w500(),
  );

  @override
  AppButtonStyle copyWith({
    Color? primaryBackground,
    Color? primaryForeground,
    Color? secondaryBackground,
    Color? secondaryForeground,
    Color? outlinedBorderColor,
    Color? outlinedForeground,
    Color? disabledBackground,
    Color? disabledForeground,
    double? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
  }) => AppButtonStyle._(
    primaryBackground:  primaryBackground  ?? this.primaryBackground,
    primaryForeground:  primaryForeground  ?? this.primaryForeground,
    secondaryBackground: secondaryBackground ?? this.secondaryBackground,
    secondaryForeground: secondaryForeground ?? this.secondaryForeground,
    outlinedBorderColor: outlinedBorderColor ?? this.outlinedBorderColor,
    outlinedForeground:  outlinedForeground  ?? this.outlinedForeground,
    disabledBackground:  disabledBackground  ?? this.disabledBackground,
    disabledForeground:  disabledForeground  ?? this.disabledForeground,
    borderRadius: borderRadius ?? this.borderRadius,
    padding:      padding      ?? this.padding,
    textStyle:    textStyle    ?? this.textStyle,
  );

  @override
  AppButtonStyle lerp(ThemeExtension<AppButtonStyle>? other, double t) {
    if (other is! AppButtonStyle) return this;
    return AppButtonStyle._(
      primaryBackground:  Color.lerp(primaryBackground,  other.primaryBackground,  t) ?? primaryBackground,
      primaryForeground:  Color.lerp(primaryForeground,  other.primaryForeground,  t) ?? primaryForeground,
      secondaryBackground: Color.lerp(secondaryBackground, other.secondaryBackground, t) ?? secondaryBackground,
      secondaryForeground: Color.lerp(secondaryForeground, other.secondaryForeground, t) ?? secondaryForeground,
      outlinedBorderColor: Color.lerp(outlinedBorderColor, other.outlinedBorderColor, t) ?? outlinedBorderColor,
      outlinedForeground:  Color.lerp(outlinedForeground,  other.outlinedForeground,  t) ?? outlinedForeground,
      disabledBackground:  Color.lerp(disabledBackground,  other.disabledBackground,  t) ?? disabledBackground,
      disabledForeground:  Color.lerp(disabledForeground,  other.disabledForeground,  t) ?? disabledForeground,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding:      EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      textStyle:    TextStyle.lerp(textStyle, other.textStyle, t) ?? textStyle,
    );
  }
}
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/extensions/app_button_style_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/extensions/app_button_style.dart \
        test/core/ui_kit/extensions/app_button_style_test.dart
git commit -m "feat(wail-10): add AppButtonStyle ThemeExtension"
```

---

## Task 8: WailyButton (TDD)

**Files:**
- Create: `lib/core/ui_kit/components/buttons/waily_button.dart`
- Create: `test/core/ui_kit/components/waily_button_test.dart`

- [ ] **Step 1: Write failing widget tests**

```dart
// test/core/ui_kit/components/waily_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_button.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyButton', () {
    testWidgets('primary variant renders ElevatedButton with label', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyButton(label: 'Continue', onPressed: () {}),
      ));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('secondary variant renders ElevatedButton', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyButton(
          label: 'Skip',
          onPressed: () {},
          variant: WailyButtonVariant.secondary,
        ),
      ));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('outlined variant renders OutlinedButton', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyButton(
          label: 'Cancel',
          onPressed: () {},
          variant: WailyButtonVariant.outlined,
        ),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: const WailyButton(label: 'Disabled', onPressed: null),
      ));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('tap calls onPressed callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyButton(label: 'Tap me', onPressed: () => tapped = true),
      ));
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/components/waily_button_test.dart
```

Expected: compilation error — `WailyButton` not found.

- [ ] **Step 3: Create waily_button.dart**

```dart
// lib/core/ui_kit/components/buttons/waily_button.dart
import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Button display variants.
enum WailyButtonVariant { primary, secondary, outlined }

/// App-wide button widget.
///
/// Reads all visual properties from [AppButtonStyle] — no Material defaults.
///
/// Example:
/// ```dart
/// WailyButton(label: 'Continue', onPressed: _onContinue)
/// WailyButton(label: 'Cancel', onPressed: _onCancel, variant: WailyButtonVariant.outlined)
/// ```
class WailyButton extends StatelessWidget {
  const WailyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = WailyButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final WailyButtonVariant variant;

  ButtonStyle _buildStyle({
    required Color background,
    required Color foreground,
    required Color disabledBackground,
    required Color disabledForeground,
    required double borderRadius,
    required EdgeInsets padding,
    required TextStyle textStyle,
    BorderSide? side,
  }) => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.disabled) ? disabledBackground : background,
    ),
    foregroundColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.disabled) ? disabledForeground : foreground,
    ),
    overlayColor:  WidgetStateProperty.all(Colors.transparent),
    elevation:     WidgetStateProperty.all(0),
    shadowColor:   WidgetStateProperty.all(Colors.transparent),
    shape: WidgetStateProperty.all(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: side ?? BorderSide.none,
    )),
    padding:   WidgetStateProperty.all(padding),
    textStyle: WidgetStateProperty.all(textStyle.copyWith(inherit: false)),
    splashFactory: NoSplash.splashFactory,
  );

  @override
  Widget build(BuildContext context) {
    final s = context.appButtonStyle;

    switch (variant) {
      case WailyButtonVariant.primary:
      case WailyButtonVariant.secondary:
        final bg = variant == WailyButtonVariant.primary
            ? s.primaryBackground
            : s.secondaryBackground;
        final fg = variant == WailyButtonVariant.primary
            ? s.primaryForeground
            : s.secondaryForeground;
        return ElevatedButton(
          onPressed: onPressed,
          style: _buildStyle(
            background: bg,
            foreground: fg,
            disabledBackground: s.disabledBackground,
            disabledForeground: s.disabledForeground,
            borderRadius: s.borderRadius,
            padding: s.padding,
            textStyle: s.textStyle,
          ),
          child: Text(label),
        );

      case WailyButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: _buildStyle(
            background: Colors.transparent,
            foreground: s.outlinedForeground,
            disabledBackground: Colors.transparent,
            disabledForeground: s.disabledForeground,
            borderRadius: s.borderRadius,
            padding: s.padding,
            textStyle: s.textStyle,
            side: BorderSide(color: s.outlinedBorderColor),
          ),
          child: Text(label),
        );
    }
  }
}
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/components/waily_button_test.dart
```

Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/components/buttons/ \
        test/core/ui_kit/components/waily_button_test.dart
git commit -m "feat(wail-10): add WailyButton widget with TDD"
```

---

## Task 9: AppInputStyle (TDD)

**Files:**
- Replace: `lib/core/ui_kit/extensions/app_input_style.dart` (was a stub)
- Create: `test/core/ui_kit/extensions/app_input_style_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/core/ui_kit/extensions/app_input_style_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_input_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';

void main() {
  group('AppInputStyle', () {
    test('dark() fillColor is AppColors.surface', () {
      expect(AppInputStyle.dark().fillColor, AppColors.surface);
    });

    test('dark() focusedBorderColor is AppColors.primary', () {
      expect(AppInputStyle.dark().focusedBorderColor, AppColors.primary);
    });

    test('dark() errorBorderColor is AppColors.error', () {
      expect(AppInputStyle.dark().errorBorderColor, AppColors.error);
    });

    test('dark() borderRadius is AppBorderRadius.m', () {
      expect(AppInputStyle.dark().borderRadius, AppBorderRadius.m);
    });

    test('copyWith overrides fillColor', () {
      final style = AppInputStyle.dark();
      final modified = style.copyWith(fillColor: AppColors.surfaceVariant);
      expect(modified.fillColor, AppColors.surfaceVariant);
      expect(modified.borderRadius, style.borderRadius);
    });
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/extensions/app_input_style_test.dart
```

Expected: fail — stub has no field `fillColor`.

- [ ] **Step 3: Replace stub with full AppInputStyle**

```dart
// lib/core/ui_kit/extensions/app_input_style.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_border_radius.dart';

/// Input field style tokens for the dark Waily theme.
///
/// Consumed by [WailyTextField] to build [InputDecoration] without Material defaults.
@immutable
class AppInputStyle extends ThemeExtension<AppInputStyle> {
  const AppInputStyle._({
    required this.fillColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.borderRadius,
    required this.contentPadding,
    required this.labelStyle,
    required this.inputStyle,
    required this.hintStyle,
  });

  final Color fillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final TextStyle labelStyle;
  final TextStyle inputStyle;
  final TextStyle hintStyle;

  factory AppInputStyle.dark() => AppInputStyle._(
    fillColor:           AppColors.surface,
    borderColor:         AppColors.border,
    focusedBorderColor:  AppColors.primary,
    errorBorderColor:    AppColors.error,
    borderRadius:        AppBorderRadius.m,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.m,
      vertical: AppSpacing.m,
    ),
    labelStyle: AppTypography.s14w400(color: AppColors.textSecondary),
    inputStyle: AppTypography.s16w400(color: AppColors.textPrimary),
    hintStyle:  AppTypography.s16w400(color: AppColors.textDisabled),
  );

  @override
  AppInputStyle copyWith({
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    double? borderRadius,
    EdgeInsets? contentPadding,
    TextStyle? labelStyle,
    TextStyle? inputStyle,
    TextStyle? hintStyle,
  }) => AppInputStyle._(
    fillColor:           fillColor           ?? this.fillColor,
    borderColor:         borderColor         ?? this.borderColor,
    focusedBorderColor:  focusedBorderColor  ?? this.focusedBorderColor,
    errorBorderColor:    errorBorderColor    ?? this.errorBorderColor,
    borderRadius:        borderRadius        ?? this.borderRadius,
    contentPadding:      contentPadding      ?? this.contentPadding,
    labelStyle:          labelStyle          ?? this.labelStyle,
    inputStyle:          inputStyle          ?? this.inputStyle,
    hintStyle:           hintStyle           ?? this.hintStyle,
  );

  @override
  AppInputStyle lerp(ThemeExtension<AppInputStyle>? other, double t) {
    if (other is! AppInputStyle) return this;
    return AppInputStyle._(
      fillColor:          Color.lerp(fillColor,          other.fillColor,          t) ?? fillColor,
      borderColor:        Color.lerp(borderColor,        other.borderColor,        t) ?? borderColor,
      focusedBorderColor: Color.lerp(focusedBorderColor, other.focusedBorderColor, t) ?? focusedBorderColor,
      errorBorderColor:   Color.lerp(errorBorderColor,   other.errorBorderColor,   t) ?? errorBorderColor,
      borderRadius:       t < 0.5 ? borderRadius : other.borderRadius,
      contentPadding:     EdgeInsets.lerp(contentPadding, other.contentPadding, t) ?? contentPadding,
      labelStyle:         TextStyle.lerp(labelStyle, other.labelStyle, t) ?? labelStyle,
      inputStyle:         TextStyle.lerp(inputStyle, other.inputStyle, t) ?? inputStyle,
      hintStyle:          TextStyle.lerp(hintStyle,  other.hintStyle,  t) ?? hintStyle,
    );
  }
}
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/extensions/app_input_style_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/extensions/app_input_style.dart \
        test/core/ui_kit/extensions/app_input_style_test.dart
git commit -m "feat(wail-10): add AppInputStyle ThemeExtension"
```

---

## Task 10: WailyTextField (TDD)

**Files:**
- Create: `lib/core/ui_kit/components/inputs/waily_text_field.dart`
- Create: `test/core/ui_kit/components/waily_text_field_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/core/ui_kit/components/waily_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_text_field.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyTextField', () {
    testWidgets('renders a TextField', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: const WailyTextField(),
      ));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: const WailyTextField(hint: 'Enter your email'),
      ));
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('displays error text when provided', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: const WailyTextField(errorText: 'Field is required'),
      ));
      expect(find.text('Field is required'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: const WailyTextField(obscureText: true),
      ));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changed;
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyTextField(onChanged: (v) => changed = v),
      ));
      await tester.enterText(find.byType(TextField), 'hello');
      expect(changed, 'hello');
    });
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/components/waily_text_field_test.dart
```

Expected: compilation error — `WailyTextField` not found.

- [ ] **Step 3: Create waily_text_field.dart**

```dart
// lib/core/ui_kit/components/inputs/waily_text_field.dart
import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// App-wide text input widget.
///
/// All visual properties read from [AppInputStyle] — no Material defaults.
/// State (controller, focus) is managed externally.
///
/// Example:
/// ```dart
/// WailyTextField(
///   label: 'Email',
///   hint: 'you@example.com',
///   controller: _emailController,
///   errorText: _emailError,
/// )
/// ```
class WailyTextField extends StatelessWidget {
  const WailyTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final s = context.appInputStyle;
    final radius = BorderRadius.circular(s.borderRadius);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: s.inputStyle,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: s.fillColor,
        labelStyle: s.labelStyle,
        hintStyle: s.hintStyle,
        contentPadding: s.contentPadding,
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.focusedBorderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.errorBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: s.errorBorderColor),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/components/waily_text_field_test.dart
```

Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/components/inputs/ \
        test/core/ui_kit/components/waily_text_field_test.dart
git commit -m "feat(wail-10): add WailyTextField widget with TDD"
```

---

## Task 11: AppCardStyle (TDD)

**Files:**
- Replace: `lib/core/ui_kit/extensions/app_card_style.dart` (was a stub)
- Create: `test/core/ui_kit/extensions/app_card_style_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/core/ui_kit/extensions/app_card_style_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_card_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';

void main() {
  group('AppCardStyle', () {
    test('dark() backgroundColor is AppColors.surface', () {
      expect(AppCardStyle.dark().backgroundColor, AppColors.surface);
    });

    test('dark() borderRadius is AppBorderRadius.l', () {
      expect(AppCardStyle.dark().borderRadius, AppBorderRadius.l);
    });

    test('dark() elevation is 0', () {
      expect(AppCardStyle.dark().elevation, 0.0);
    });

    test('copyWith overrides backgroundColor', () {
      final style = AppCardStyle.dark();
      final modified = style.copyWith(backgroundColor: AppColors.surfaceVariant);
      expect(modified.backgroundColor, AppColors.surfaceVariant);
      expect(modified.borderRadius, style.borderRadius);
    });
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/extensions/app_card_style_test.dart
```

Expected: fail — stub has no field `backgroundColor`.

- [ ] **Step 3: Replace stub with full AppCardStyle**

```dart
// lib/core/ui_kit/extensions/app_card_style.dart
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_border_radius.dart';

/// Card style tokens for the dark Waily theme.
///
/// Consumed by [WailyCard].
@immutable
class AppCardStyle extends ThemeExtension<AppCardStyle> {
  const AppCardStyle._({
    required this.backgroundColor,
    required this.shadowColor,
    required this.borderRadius,
    required this.padding,
    required this.elevation,
  });

  final Color backgroundColor;
  final Color shadowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;

  factory AppCardStyle.dark() => AppCardStyle._(
    backgroundColor: AppColors.surface,
    shadowColor:     AppColors.black.withValues(alpha: 0.2),
    borderRadius:    AppBorderRadius.l,
    padding:         const EdgeInsets.all(AppSpacing.m),
    elevation:       0.0,
  );

  @override
  AppCardStyle copyWith({
    Color? backgroundColor,
    Color? shadowColor,
    double? borderRadius,
    EdgeInsets? padding,
    double? elevation,
  }) => AppCardStyle._(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    shadowColor:     shadowColor     ?? this.shadowColor,
    borderRadius:    borderRadius    ?? this.borderRadius,
    padding:         padding         ?? this.padding,
    elevation:       elevation       ?? this.elevation,
  );

  @override
  AppCardStyle lerp(ThemeExtension<AppCardStyle>? other, double t) {
    if (other is! AppCardStyle) return this;
    return AppCardStyle._(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ?? backgroundColor,
      shadowColor:     Color.lerp(shadowColor,     other.shadowColor,     t) ?? shadowColor,
      borderRadius:    t < 0.5 ? borderRadius : other.borderRadius,
      padding:         EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      elevation:       lerpDouble(elevation, other.elevation, t) ?? elevation,
    );
  }
}

```

- [ ] **Step 4: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/extensions/app_card_style_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/extensions/app_card_style.dart \
        test/core/ui_kit/extensions/app_card_style_test.dart
git commit -m "feat(wail-10): add AppCardStyle ThemeExtension"
```

---

## Task 12: WailyCard (TDD)

**Files:**
- Create: `lib/core/ui_kit/components/cards/waily_card.dart`
- Create: `test/core/ui_kit/components/waily_card_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/core/ui_kit/components/waily_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/cards/waily_card.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyCard(child: const Text('Card content')),
      ));
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('contains a Material widget', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyCard(child: const SizedBox()),
      ));
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('custom padding override wraps child in Padding', (tester) async {
      const customPadding = EdgeInsets.all(32);
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyCard(
          padding: customPadding,
          child: const Text('Content'),
        ),
      ));
      final paddingWidgets = tester.widgetList<Padding>(
        find.ancestor(
          of: find.text('Content'),
          matching: find.byType(Padding),
        ),
      );
      final hasCustomPadding = paddingWidgets.any((p) => p.padding == customPadding);
      expect(hasCustomPadding, isTrue);
    });

    testWidgets('ClipRRect is present for border radius clipping', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyCard(child: const SizedBox()),
      ));
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/components/waily_card_test.dart
```

Expected: compilation error — `WailyCard` not found.

- [ ] **Step 3: Create waily_card.dart**

```dart
// lib/core/ui_kit/components/cards/waily_card.dart
import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// General-purpose card container.
///
/// Reads visual properties from [AppCardStyle]. Accepts any [child].
/// Use [padding] to override the theme default.
///
/// Example:
/// ```dart
/// WailyCard(
///   child: Column(children: [...]),
/// )
/// ```
class WailyCard extends StatelessWidget {
  const WailyCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;

  /// Overrides [AppCardStyle.padding] when provided.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final s = context.appCardStyle;
    final radius = BorderRadius.circular(s.borderRadius);

    return Material(
      color: s.backgroundColor,
      elevation: s.elevation,
      shadowColor: s.shadowColor,
      borderRadius: radius,
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: padding ?? s.padding,
          child: child,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/components/waily_card_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui_kit/components/cards/ \
        test/core/ui_kit/components/waily_card_test.dart
git commit -m "feat(wail-10): add WailyCard widget with TDD"
```

---

## Task 13: WailyIcon (TDD)

**Files:**
- Create: `assets/icons/placeholder.svg`
- Create: `lib/core/ui_kit/components/icons/waily_icon.dart`
- Create: `test/core/ui_kit/components/waily_icon_test.dart`

- [ ] **Step 1: Create placeholder SVG**

```bash
# Create the file with this exact content:
cat > assets/icons/placeholder.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10"/>
</svg>
EOF
```

Then regenerate flutter_gen typed accessors:

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `lib/core/gen/assets.gen.dart` updated with `Assets.icons.placeholder`.

- [ ] **Step 2: Write failing tests**

```dart
// test/core/ui_kit/components/waily_icon_test.dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waily/core/gen/assets.gen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyIcon', () {
    testWidgets('renders an SvgPicture', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyIcon(icon: Assets.icons.placeholder),
      ));
      await tester.pump();
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('applies provided size to SvgPicture width', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyIcon(icon: Assets.icons.placeholder, size: 48),
      ));
      await tester.pump();
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 48.0);
    });

    testWidgets('applies provided size to SvgPicture height', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(
        child: WailyIcon(icon: Assets.icons.placeholder, size: 32),
      ));
      await tester.pump();
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.height, 32.0);
    });
  });
}
```

Note: the import for `assets.gen.dart` path may vary. Verify the actual path in `lib/core/gen/` after build_runner runs, and adjust the import accordingly.

- [ ] **Step 3: Run to confirm fail**

```bash
fvm flutter test test/core/ui_kit/components/waily_icon_test.dart
```

Expected: compilation error — `WailyIcon` not found.

- [ ] **Step 4: Create waily_icon.dart**

```dart
// lib/core/ui_kit/components/icons/waily_icon.dart
import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../extensions/theme_context_extension.dart';

/// App icon widget backed by a typed [SvgGenImage] from flutter_gen.
///
/// Color defaults to [AppColorStyle.icon]. Override with [color].
///
/// Example:
/// ```dart
/// WailyIcon(icon: Assets.icons.home)
/// WailyIcon(icon: Assets.icons.close, size: 20, color: context.appColors.error)
/// ```
class WailyIcon extends StatelessWidget {
  const WailyIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  final SvgGenImage icon;

  /// Width and height in logical pixels. Defaults to 24.
  final double? size;

  /// Icon color. Defaults to [AppColorStyle.icon].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.appColors.icon;
    return icon.svg(
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
    );
  }
}
```

Adjust the `flutter_gen` import path if needed — check the actual file at `lib/core/gen/assets.gen.dart`.

- [ ] **Step 5: Run tests to confirm pass**

```bash
fvm flutter test test/core/ui_kit/components/waily_icon_test.dart
```

Expected: All tests pass. (`tester.pump()` gives flutter_svg time to process the asset.)

- [ ] **Step 6: Commit**

```bash
git add assets/icons/placeholder.svg \
        lib/core/gen/ \
        lib/core/ui_kit/components/icons/ \
        test/core/ui_kit/components/waily_icon_test.dart
git commit -m "feat(wail-10): add WailyIcon widget with TDD"
```

---

## Task 14: Wire darkTheme into main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Update MainApp to use darkTheme**

Replace the current `MaterialApp` in `lib/main.dart`:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'core/ui_kit/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run the app to verify no crash**

```bash
fvm flutter run
```

Expected: app launches with dark background (not white).

- [ ] **Step 3: Run analyze and all tests**

```bash
fvm flutter analyze
fvm flutter test
```

Expected: no analysis errors, all tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "feat(wail-10): wire darkTheme into MaterialApp"
```

---

## Task 15: Barrel Export + Final Verification

**Files:**
- Create: `lib/core/ui_kit/index.dart`

- [ ] **Step 1: Create index.dart**

```dart
// lib/core/ui_kit/index.dart

// Theme
export 'theme/app_fonts.dart';
export 'theme/app_spacing.dart';
export 'theme/app_border_radius.dart';
export 'theme/app_colors.dart';
export 'theme/app_typography.dart';
export 'theme/app_theme.dart';

// Extensions
export 'extensions/app_color_style.dart';
export 'extensions/app_text_styles.dart';
export 'extensions/app_button_style.dart';
export 'extensions/app_input_style.dart';
export 'extensions/app_card_style.dart';
export 'extensions/theme_context_extension.dart';

// Components
export 'components/buttons/waily_button.dart';
export 'components/inputs/waily_text_field.dart';
export 'components/cards/waily_card.dart';
export 'components/icons/waily_icon.dart';
```

- [ ] **Step 2: Run full test suite**

```bash
fvm flutter test --reporter expanded
```

Expected: all tests pass. Count should include tests for `AppTypography`, `AppColorStyle`, `AppTextStyles`, `AppButtonStyle`, `AppInputStyle`, `AppCardStyle`, `WailyButton`, `WailyTextField`, `WailyCard`, `WailyIcon`.

- [ ] **Step 3: Run analyzer**

```bash
fvm flutter analyze
```

Expected: No issues found.

- [ ] **Step 4: Format**

```bash
dart format .
```

- [ ] **Step 5: Final commit**

```bash
git add lib/core/ui_kit/index.dart
git commit -m "feat(wail-10): add barrel export and finalize UI kit"
```

- [ ] **Step 6: Push**

```bash
git push origin WAIL-10-ui-kit-components
```
