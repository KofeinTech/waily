# {{PROJECT_NAME}}

Flutter mobile app for {{CLIENT_NAME}}.

## Quick reference

- Jira: `improvs.atlassian.net/browse/{{JIRA_KEY}}`
- Branch naming: `{{JIRA_KEY}}-<number>-<description>`
- Commit format: `<type>(scope): description`

## Stack

Flutter (FVM), Riverpod, GoRouter, Freezed, Dio + Retrofit, flutter_gen, flutter_svg

## Architecture

Feature-based clean architecture. Each feature has `presentation/domain/data/` layers:

```
lib/features/<name>/
  presentation/providers/, screens/, widgets/
  domain/entities/, repositories/ (interfaces), use_cases/
  data/repositories/ (implementations), models/, sources/
```

Shared: `lib/core/` (theme, router, constants, utils, l10n)

## Design

Figma designs are exported to `design/` folder via `/improvs:figma-export`:

```
design/
  screens/          -- one JSON per Figma frame (layout, colors, typography)
  tokens.json       -- design tokens (colors, spacing, typography, radii)
  assets/           -- SVG icons exported from Figma
  assets/images/    -- PNG images (photos, avatars, backgrounds)
```

Use `/improvs:figma-export <FIGMA_URL>` to export. Requires `FIGMA_API_KEY` env var.

### Building from design JSON -- mandatory rules

When implementing a screen from `design/screens/*.json`:

- **Spacing is exact**: copy `padding` and `itemSpacing` values directly from the JSON. Every `itemSpacing` becomes a `SizedBox` between children. Never approximate.
- **Alignment is exact**: read `primaryAxisAlignItems` / `counterAxisAlignItems` on every frame node and set matching `MainAxisAlignment` / `CrossAxisAlignment`. Read `textAlignHorizontal` on every TEXT node and set matching `TextAlign`. CENTER means center -- do not omit (Flutter defaults to start/left).
- **Component styling is exact**: for buttons and interactive elements, apply `cornerRadius`, `padding`, `fills`, and text style from the design node. Do not rely on Flutter Material defaults.
- **Images**: use the exported filenames from `design/assets/images/`. If a filename is generic (like `image-13`), check `imageContext` in the JSON for parent name and nearby text to understand what the image represents.
- After building, run `/improvs:figma-check` to verify before creating a PR.

## Run

```bash
fvm flutter run
fvm flutter test
fvm flutter analyze
dart format .
dart run build_runner build
```

## Testing

- Mockito with `@GenerateMocks` + build_runner for mocks
- Unit tests for use cases, repositories, entity methods
- Notifier tests with `ProviderContainer` + `Listener` mock
- Widget tests required for every new feature
- Integration tests in `integration_test/` against staging (no mocks)

## Project-specific notes

<!-- Add non-obvious discoveries, workarounds, API quirks here -->
