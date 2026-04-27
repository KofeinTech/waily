# Waily UI Kit

Reusable design system for the Waily Flutter app. Implements the Figma `UI Kit`
page 1:1 against the dark theme. The kit is dark-only by design — there is no
light theme.

## Import

```dart
import 'package:waily/core/ui_kit/index.dart';
```

The barrel exports every public widget, theme extension, and design token.

## Run the showcase

```bash
fvm flutter run -t lib/main_showcase.dart
```

This boots a separate entry-point that renders every widget variant on top of
the dark theme. Use it for visual QA and as living documentation. Production
builds use `lib/main.dart`.

## Design tokens

Located in `theme/`. All values are sourced from `design/tokens.json`.

| Token | Type | Notes |
|---|---|---|
| `AppColors` | `Color` constants | Backgrounds, primary brand, text, semantic, neutrals |
| `AppSpacing` | `double` constants | xxs / xs / s / sm / m / ml / l / xl / xxl |
| `AppBorderRadius` | `double` constants | s / m / ml / l / xl / full |
| `AppTypography` | `TextStyle` factories | Font-size + weight named factories (`s14w500` …) |
| `AppFonts` | font-family name | Helvetica Neue |

## Theme

The single dark theme lives in `theme/app_theme.dart` as `darkTheme`. It
registers a `ThemeExtension` per component (24 in total). Read theme values
from `BuildContext` via the getters in
`extensions/theme_context_extension.dart` — never `Theme.of(context)`:

```dart
context.appColors.background        // → AppColorStyle
context.appTextStyles.s16w500()     // → AppTextStyles
context.appButtonStyle              // → AppButtonStyle
context.appSlideButtonStyle         // → AppSlideButtonStyle
// …and so on for every component below
```

## Widgets

All widgets are stateless or `StatefulWidget` and read their visuals from a
matching `App<Name>Style` extension. Widgets never read Material defaults and
never hard-code colors.

### Buttons (`components/buttons/`)
- `WailyButton` — primary/secondary, two sizes, leading/trailing icons,
  loading state.
- `WailyIconButton` — icon-only, two sizes, pressed/disabled states.
- `WailyLink` — inline tappable text.
- `WailySegmentedButton` — translucent toggle pill with optional close icon.
- `WailySlideButton` — slide-to-confirm with liquid trail, haptic feedback,
  and `reset()` via `GlobalKey<WailySlideButtonState>`.

### Inputs (`components/inputs/`)
- `WailyTextField` — primary/secondary form field, label/hint/error.
- `WailyTextInput` — translucent search-style input with clear icon.
- `WailyChatInputField` — multi-line chat composer with mic/send affordances.
- `WailyMessageField` — chat message bubble (user / AI / copy).
- `WailySegmentedPicker<T>` — generic N-item picker.
- `WailyBigDropdown` — tappable card with title + subtitle + chevron.
- `WailyOption` — selectable card row (title + optional description).
- `WailyDigitBox` — single-digit OTP cell (default / filled / active /
  error).
- `WailyCheckbox` — circular two-state checkbox.
- `WailySwitcher` — animated stadium switch.
- `WailySelector` — text-only weight/color toggle for wheel pickers.

### Chips & indicators
- `WailyChip` — dark/light pill with optional value text and close icon.
- `WailyLoader` — three-dot animated loader.
- `WailyProgressBar` — determinate / indeterminate linear bar.

### Cards & containers (`components/cards/`, `components/containers/`)
- `WailyCard` — generic content surface.
- `WailyMenuItemContainer` — nav-bar tab with default/active states.
- `WailyHistoryCard` — daily / today / chat history rows
  (`WailyHistoryCard.daily(...)` and `WailyHistoryCard.chat(...)`).
- `WailyListElement` — tappable list row with optional value + chevron.
- `WailyChatTip` — tappable chat hint card (default / active / disabled).
- `WailyPickerCard` — selectable settings card with checkmark.

### Icon
- `WailyIcon` — typed `SvgGenImage` wrapper that paints the SVG with the
  resolved color.

## Usage example

```dart
import 'package:flutter/material.dart';
import 'package:waily/core/ui_kit/index.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            const WailyTextField(label: 'Email', hint: 'you@example.com'),
            const SizedBox(height: AppSpacing.m),
            WailyButton(
              label: 'Log in',
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.s),
            WailyLink(label: 'Forgot password?', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
```

## Customizing a component

Every component reads from a `ThemeExtension`. To override a token in a
single screen, copy the extension and inject it via `Theme(...)`:

```dart
Theme(
  data: Theme.of(context).copyWith(
    extensions: [
      ...Theme.of(context).extensions.values,
      context.appButtonStyle.copyWith(primaryBackground: AppColors.error),
    ],
  ),
  child: WailyButton(label: 'Delete', onPressed: _delete),
)
```

For app-wide overrides, edit the `<Style>.dark()` factory in
`extensions/app_*_style.dart`.

## Adding a new component

1. Create `lib/core/ui_kit/components/<group>/waily_<name>.dart`.
2. Create `lib/core/ui_kit/extensions/app_<name>_style.dart` with
   `copyWith` and `lerp`.
3. Register the style in `theme/app_theme.dart` and add a getter to
   `extensions/theme_context_extension.dart`.
4. Add an export line to `index.dart`.
5. Add a widget test in `test/core/ui_kit/components/waily_<name>_test.dart`
   and a style test in
   `test/core/ui_kit/extensions/app_<name>_style_test.dart`.
6. Add a showcase section in
   `lib/core/ui_kit/showcase/sections/<name>s_section.dart` and wire it into
   `showcase_home.dart`.
7. Run `fvm flutter test && fvm flutter analyze`.

## Tests

```bash
fvm flutter test
```

490+ widget and theme-extension tests cover every component's geometry, color
resolution, gesture outcomes, and disabled paths. Helpers live in
`test/core/ui_kit/helpers/test_theme_wrapper.dart`.
