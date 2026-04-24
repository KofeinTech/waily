# Flutter / Dart Rules
## Stack

Flutter (FVM), Riverpod, GoRouter, Freezed, Dio + Retrofit, flutter_gen, flutter_svg

## Architecture

Feature-based clean architecture. Each feature is self-contained:

```
lib/features/<name>/
  presentation/
    providers/        # Riverpod providers (call use cases, not repos)
    screens/          # Full-page widgets
    widgets/          # Feature-scoped UI components
  domain/
    entities/         # Freezed domain models (pure Dart, no Flutter)
    repositories/     # Abstract interfaces only
    use_cases/        # Business logic (one class per action, params in same file)
  data/
    repositories/     # Concrete implementations of domain interfaces
    models/           # API/local data models with toEntity()
    sources/          # Dio/Retrofit clients, SharedPreferences, local DB
```

Shared: `lib/core/` (theme, router, constants, utils, l10n)

### Layer rules

- **presentation/** -- Flutter-dependent, no business logic. Providers call use cases only, never repos directly. Only in-widget state: intrinsic animations.
- **domain/** -- Pure Dart, no Flutter imports. Entities may have derived getters. Each use case file includes its params class.
- **data/** -- Implements domain contracts. Models contain `toEntity()` at repository level. Sources are raw data access only.
- No feature imports from another feature's internal code.

## Assets

- All paths via **flutter_gen** -- never hardcode asset path strings
- SVGs via **flutter_svg** (integrates with flutter_gen for typed `SvgGenImage`)
- Assets organized: `assets/icons/<feature>/`, `assets/images/<feature>/`

## Theme

- All text styles via `TextTheme`, all colors via `ColorScheme` -- never hardcode in widgets
- Defined in `core/theme/`, accessed via `Theme.of(context)`

## Conventions

- No setState in features -- Riverpod only (exception: intrinsic widget animations)
- All data models use Freezed with @freezed
- Repository pattern: interface in domain, implementation in data
- Widget tests required for every new feature
- No hardcoded strings -- use constants or l10n
- No hardcoded asset paths -- use flutter_gen
- Barrel files (index.dart) for public exports
- Mockito with `@GenerateMocks` for test mocks

## Commands

- `fvm flutter run` / `fvm flutter test` / `fvm flutter analyze`
- `dart format .`
- `dart run build_runner build` after changing Freezed/Riverpod/Retrofit/Mockito models

## Quality Gates

- `flutter analyze` + `flutter test` must pass before commit (enforced by hooks)
- `dart format` runs automatically after every file edit
