# Flutter / Dart Rules

## Stack

Flutter (FVM), flutter_bloc (Cubit), injectable, GoRouter, Freezed, Dio + Retrofit, flutter_gen, flutter_svg

## Architecture

Feature-based clean architecture. Each feature is self-contained:

```
lib/features/<name>/
  presentation/
    bloc/             # Cubit and State classes (call use cases, not repos)
    extensions/       # Flutter extensions specific to this feature
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

Shared: `lib/core/` (ui_kit, router, constants, utils, l10n) and `lib/shared/` (validators, extensions, formatters).

### Layer rules

- **presentation/** -- Flutter-dependent, no business logic. Cubits call use cases only, never repos directly. Only in-widget state: intrinsic animations.
- **domain/** -- Pure Dart, no Flutter imports. Entities may have derived getters. Each use case file includes its params class.
- **data/** -- Implements domain contracts. Models contain `toEntity()` at repository level. Sources are raw data access only.
- No feature imports from another feature's internal code.

## Dependency Injection

- Use `injectable` + `get_it`. Register classes with `@injectable`, `@lazySingleton`, `@singleton`.
- Repositories: `@LazySingleton(as: FeatureRepository)` on the impl.
- Datasources: `@Injectable(as: FeatureApiDatasource)` on the impl.
- Use cases: `@lazySingleton`.
- Cubits: `@injectable` (new instance per screen/provider scope).
- Run `dart run build_runner build --delete-conflicting-outputs` after changing annotations.

## Assets

- All paths via **flutter_gen** -- never hardcode asset path strings
- SVGs via **flutter_svg** (integrates with flutter_gen for typed `SvgGenImage`)
- Raster images via `AssetGenImage`, Lottie via `LottieGenImage`
- Assets live in top-level `assets/` folder, organized by kind then feature: `assets/icons/<feature>/`, `assets/images/<feature>/`

## Theme

- Theme lives in `lib/core/ui_kit/theme/` and is registered via Material 3 `ThemeExtension`
- Access everything through `BuildContext` extensions, not `Theme.of(context)`:
    - `context.appColors` (AppColorStyle)
    - `context.appTextStyles` (AppTextStyles)
    - `context.appButtonStyle`, `context.appInputStyle`, `context.appBarStyle`, etc.
- Each style class implements a `.dark()` factory (and `.light()` if applicable), plus `copyWith` and `lerp`
- Never hardcode colors or text styles inside widgets

## Conventions

- No setState in features -- Cubit only (exception: intrinsic widget animations)
- All data models use Freezed with `@freezed`
- Repository pattern: interface in `domain/`, implementation in `data/`
- Mappers implemented as Dart extensions on API models (`toEntity()`), invoked at repository level
- Datasources inherit from `AppGateway` and wrap calls with `safeCall<T>` / `voidSafeCall`
- Use cases extend `AsyncUseCase<P, R>` or `SyncUseCase<P, R>` and return `Either<Exception, R>` (dartz)
- Cross-cutting notifications go through `NotificationManager`; throw `NotificationException` from use cases to surface UI feedback
- Widget tests required for every new feature
- No hardcoded strings -- use constants or l10n (`.arb` via `flutter gen-l10n`)
- No hardcoded asset paths -- use flutter_gen
- Barrel files (`index.dart`) for public exports
- Mockito with `@GenerateMocks` for test mocks

## Commands

- `fvm flutter run` / `fvm flutter test` / `fvm flutter analyze`
- `dart format .`
- `fvm flutter pub run build_runner build --delete-conflicting-outputs` after changing Freezed / injectable / Retrofit / Mockito models

## Quality Gates

- `flutter analyze` + `flutter test` must pass before commit (enforced by hooks)
- `dart format` runs automatically after every file edit
