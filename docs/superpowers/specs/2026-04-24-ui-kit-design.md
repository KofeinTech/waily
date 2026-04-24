# WAIL-10 — UI Kit: Design Tokens and Reusable Components

**Ticket:** [WAIL-10](https://improvs.atlassian.net/browse/WAIL-10) — Create UI kit with design tokens and reusable components
**Branch:** `WAIL-10-ui-kit-components`
**Status:** Design approved 2026-04-24

## 1. Summary

Build a greenfield UI kit in `lib/core/ui_kit/` following the ThemeExtension-per-component pattern mandated by CLAUDE.md. The kit covers design tokens (colors, typography, spacing, border radius) and four reusable components: `WailyButton`, `WailyCard`, `WailyTextField`, `WailyIcon`. Dark theme only — no light theme stubs. Widget tests serve as the component showcase. Colors are imported from the Figma Design Tokens node before any code is written.

## 2. Prerequisites

Before implementation begins:

```bash
/improvs:figma-export https://www.figma.com/design/fHb7WGklKtujnCbzxnLDdx/Waily-Mobile-App?node-id=206-63502
```

This exports named design tokens from Figma into `design/`. The resulting semantic color names drive `AppColors` and `AppColorStyle`. Do not invent color names — use whatever Figma names come out of the export.

## 3. File Structure

```
lib/core/ui_kit/
  theme/
    app_theme.dart              # ThemeData (dark only)
    app_colors.dart             # AppColors — hex constants from Figma export
    app_typography.dart         # AppTypography — static TextStyle methods
    app_fonts.dart              # AppFonts — font family name constants
    app_spacing.dart            # AppSpacing — semantic double constants
    app_border_radius.dart      # AppBorderRadius — semantic double constants
  extensions/
    app_color_style.dart        # ThemeExtension<AppColorStyle>
    app_text_styles.dart        # ThemeExtension<AppTextStyles>
    app_button_style.dart       # ThemeExtension<AppButtonStyle>
    app_input_style.dart        # ThemeExtension<AppInputStyle>
    app_card_style.dart         # ThemeExtension<AppCardStyle>
    theme_context_extension.dart # BuildContext shortcuts
  components/
    buttons/
      waily_button.dart
    inputs/
      waily_text_field.dart
    cards/
      waily_card.dart
    icons/
      waily_icon.dart
  index.dart                    # barrel export

test/core/ui_kit/
  components/
    waily_button_test.dart
    waily_text_field_test.dart
    waily_card_test.dart
    waily_icon_test.dart
  extensions/
    app_color_style_test.dart
    app_text_styles_test.dart
  helpers/
    test_theme_wrapper.dart     # shared MaterialApp wrapper with darkTheme
```

## 4. Design Tokens

### 4.1 AppFonts

```dart
class AppFonts {
  static const helveticaNeue = 'Helvetica Neue';
}
```

Helvetica Neue is a system font on iOS — no bundling required. On Android, Flutter falls back to Roboto automatically. No other font families are included in this ticket.

### 4.2 AppTypography

Static methods, one per distinct style from `design/tokens.json` (Helvetica Neue entries only). Naming convention: `s{fontSize}w{fontWeight}`.

Every method accepts an optional `color` override. Every style sets `textHeightBehavior` with `leadingDistribution: TextLeadingDistribution.even` to match Figma line-height rendering exactly. Line height is expressed as a ratio: `height = lineHeightPx / fontSize`.

```dart
// Example — s32w500
static TextStyle s32w500({Color? color}) => TextStyle(
  fontFamily: AppFonts.helveticaNeue,
  fontSize: 32,
  fontWeight: FontWeight.w500,
  height: 36 / 32,
  letterSpacing: -0.96,
  color: color,
  textHeightBehavior: const TextHeightBehavior(
    leadingDistribution: TextLeadingDistribution.even,
  ),
);
```

Styles to implement (from tokens.json, Helvetica Neue only):

| Method | size | weight | lineHeight | letterSpacing |
|--------|------|--------|------------|---------------|
| s12w500 | 12 | 500 | 16/12 | -0.12 |
| s14w400 | 14 | 400 | 18/14 | -0.14 |
| s14w500 | 14 | 500 | 18/14 | -0.14 |
| s16w400 | 16 | 400 | 20/16 | -0.32 |
| s16w500 | 16 | 500 | 20/16 | -0.32 |
| s18w400 | 18 | 400 | 22/18 | -0.18 |
| s18w500 | 18 | 500 | 22/18 | -0.18 |
| s20w500 | 20 | 500 | 24/20 | -0.20 |
| s24w500 | 24 | 500 | 28/24 | -0.48 |
| s28w500 | 28 | 500 | 32/28 | -0.84 |
| s32w500 | 32 | 500 | 36/32 | -0.96 |
| s44w500 | 44 | 500 | 48/44 | -1.32 |

### 4.3 AppSpacing

Named semantic constants derived from the spacing values in `tokens.json`. Not every raw value gets a constant — only values that map to a semantic role.

```dart
class AppSpacing {
  static const xs  = 4.0;
  static const s   = 8.0;
  static const m   = 16.0;
  static const l   = 24.0;
  static const xl  = 32.0;
  static const xxl = 40.0;
}
```

### 4.4 AppBorderRadius

```dart
class AppBorderRadius {
  static const s    = 8.0;
  static const m    = 12.0;
  static const l    = 16.0;
  static const xl   = 20.0;
  static const full = 999.0;
}
```

### 4.5 AppColors

Static hex constants. Names come directly from the Figma Design Tokens export (`node-id=206-63502`). This file cannot be written until the export runs. The implementation step runs the export first and derives this file from the output.

### 4.6 ThemeExtension classes

Each ThemeExtension follows the same pattern: a private constructor taking raw values, a `dark()` factory that constructs from `AppColors`, `copyWith`, and `lerp`.

**AppColorStyle** — semantic color roles:
- `background`, `surface`, `surfaceVariant`
- `primary`, `primaryVariant`
- `textPrimary`, `textSecondary`, `textDisabled`
- `error`, `success`
- `icon`, `iconDisabled`
- `border`, `divider`

Exact values are assigned after the Figma token export.

**AppTextStyles** — delegates every method to `AppTypography`, applying the ThemeExtension's default `_textColor`:
```dart
TextStyle s32w500({Color? color}) =>
    AppTypography.s32w500(color: color ?? _textColor);
```

**AppButtonStyle** — holds:
- `primaryBackground`, `primaryForeground`
- `secondaryBackground`, `secondaryForeground`
- `outlinedBorderColor`, `outlinedForeground`
- `disabledBackground`, `disabledForeground`
- `borderRadius` (double)
- `verticalPadding`, `horizontalPadding` (double)
- `textStyle` (TextStyle)

**AppInputStyle** — holds:
- `fillColor`, `borderColor`, `focusedBorderColor`, `errorColor`
- `borderRadius` (double)
- `contentPadding` (EdgeInsets)
- `labelStyle`, `inputStyle`, `hintStyle` (TextStyle)

**AppCardStyle** — holds:
- `backgroundColor`, `shadowColor`
- `borderRadius` (double)
- `padding` (EdgeInsets)
- `elevation` (double)

## 5. Theme Configuration

`app_theme.dart` exposes a single `darkTheme` constant of type `ThemeData`:

```dart
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

No `lightTheme`. No `themeMode` toggle. The app always uses `darkTheme`.

## 6. Components

### 6.1 WailyButton

```dart
enum WailyButtonVariant { primary, secondary, outlined }

class WailyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final WailyButtonVariant variant;
}
```

Reads `context.appButtonStyle` and `context.appTextStyles`. Renders `ElevatedButton` (primary/secondary) or `OutlinedButton` (outlined) with `ButtonStyle` constructed entirely from `AppButtonStyle` values — no Material defaults leak through. Disabled state is inferred from `onPressed == null`.

### 6.2 WailyTextField

```dart
class WailyTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
}
```

Reads `context.appInputStyle`. Renders `TextField` with `InputDecoration` constructed entirely from `AppInputStyle` — no Material defaults. No `setState` inside — state is managed by the caller.

### 6.3 WailyCard

```dart
class WailyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding; // overrides AppCardStyle.padding when provided
}
```

Reads `context.appCardStyle`. Renders a `Material` widget (for elevation/shadow) wrapping a `Container` with `ClipRRect`. Accepts any `child`.

### 6.4 WailyIcon

```dart
class WailyIcon extends StatelessWidget {
  final SvgGenImage icon;
  final double? size;
  final Color? color; // defaults to context.appColors.icon
}
```

Thin wrapper over `flutter_svg`. Renders via `icon.svg(width: size, height: size, colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn))`. Does not use a ThemeExtension — reads color directly from `context.appColors`.

## 7. BuildContext Extension

```dart
extension ThemeContextExtension on BuildContext {
  AppColorStyle  get appColors      => Theme.of(this).extension<AppColorStyle>()!;
  AppTextStyles  get appTextStyles  => Theme.of(this).extension<AppTextStyles>()!;
  AppButtonStyle get appButtonStyle => Theme.of(this).extension<AppButtonStyle>()!;
  AppInputStyle  get appInputStyle  => Theme.of(this).extension<AppInputStyle>()!;
  AppCardStyle   get appCardStyle   => Theme.of(this).extension<AppCardStyle>()!;
}
```

All accessors use `!` — if a ThemeExtension is missing, it is a programming error that should surface immediately in development.

## 8. Widget Tests

`TestThemeWrapper` in `test/core/ui_kit/helpers/test_theme_wrapper.dart`:
```dart
class TestThemeWrapper extends StatelessWidget {
  final Widget child;
  const TestThemeWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: darkTheme,
    home: Scaffold(body: child),
  );
}
```

Each component test file covers:
- Smoke test: widget renders without error
- All variants/states (e.g., WailyButton: primary, secondary, outlined, disabled)
- Key widget presence checks (`find.text`, `find.byType`)

No golden tests in this ticket — pixel-perfect comparison deferred to `/improvs:figma-check` during implementation.

## 9. Acceptance Criteria Mapping

| AC | Implementation |
|----|----------------|
| Design tokens defined (colors, spacing, border radius, shadows) | `AppColors`, `AppSpacing`, `AppBorderRadius`, `AppColorStyle` |
| Typography system implemented | `AppTypography`, `AppTextStyles` |
| Common UI components created | `WailyButton`, `WailyCard`, `WailyTextField`, `WailyIcon` |
| Theme configuration supports dark mode | `darkTheme` in `app_theme.dart` |
| Demo/showcase page displays all components | Widget tests in `test/core/ui_kit/` |
| UI kit documented with usage examples | Dartdoc `/// Example:` blocks on each public widget and ThemeExtension |

## 10. Out of Scope

- Light theme
- AppBar, BottomNavigationBar (separate ticket)
- Animation components
- Custom icon font
- Golden/screenshot tests
- feature-specific widgets
