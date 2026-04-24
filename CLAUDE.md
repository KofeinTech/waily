# Waily Mobile

Flutter mobile app for Waily.

## Quick reference

- Jira: `improvs.atlassian.net/browse/WAIL`
- Branch naming: `WAIL-<number>-<description>`
- Commit format: `<type>(scope): description`
- Base branch: `develop`

## Stack

Flutter (FVM), flutter_bloc (Cubit), injectable, GoRouter, Freezed, Dio + Retrofit, flutter_gen, flutter_svg

## Architecture

Feature-based clean architecture. Each feature has `presentation/domain/data/` layers:

```
lib/features/<name>/
  presentation/bloc/, router/, extensions/, screens/, widgets/
  domain/entities/, repositories/ (interfaces), use_cases/
  data/repositories/ (implementations), sources/, models/, mappers/
```

Shared: `lib/core/` (ui_kit, router, constants, l10n) and `lib/shared/` (validators, extensions, formatters).

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

## Project structure


```
assets/
  icons/
    ...
  images/
    ...
lib/
  main.dart
  app.dart                    # App widget, GoRouter setup
  shared/
    validators/               # Form field validators
    extensions/               # Flutter extensions used across features
    formatters/               # Date and number formatters
  core/
    ui_kit/                   # Reusable UI components (buttons, inputs, app bars, etc.) with theming support
      theme/                  # Colors, typography, design tokens
      components/             # Buttons, inputs, app bars, etc. implemented as ThemeExtensions
        buttons/              # Button styles and widgets
        inputs/               # Input styles and widgets
        ...
    router/                   # GoRouter configuration
    constants/                # App-wide constants
    l10n/                     # Localisation — Flutter l10n generated code
  features/
    auth/
      presentation/
        bloc/                 # Cubit and State classes
        router/               # GoRouter sub-routes for this feature
        extensions/           # Flutter extensions specific to this feature
        screens/              # Full screens (pages)
        widgets/              # Feature-specific widgets
      domain/
        entities/             # Freezed domain models
        repositories/         # Abstract repository interfaces
        use_cases/            # Business logic
      data/
        repositories/         # Concrete repository implementations
        datasources/          # API clients, local storage
        models/               # API/local data models
        mappers/              # Dart extensions mapping API models -> entities
    profile/
      ...
    core/
      presentation/
        ...
      domain/
        managers/            # For cross-cutting concerns like notifications, analytics, etc. (abstract interfaces only, no implementations)
        ...
      data/
        gateway/             # AppGateway for calls with error handling
        managers/            # For cross-cutting concerns like notifications, analytics, etc. (concrete implementations, e.g. NotificationManagerImpl)
        ...
      ...
test/                       # mirrors lib/ structure
  features/
    auth/
      ...
.env                        # environment variables — never commit
.gitignore                  # local only, vulnerable or generated files not worth committing
build.yaml                  # build_runner codegen configuration
CLAUDE.md                   # Claude project config
pubspec.yaml                # dependencies, app version
README.md                   # project description for GitHub
```

### Layer responsibilities

**`presentation/`** — UI and state. Flutter-dependent, no business logic.

- `bloc/`    — Manage feature state. Call use cases, expose results to screens and widgets. No data processing logic here.
- `router/`  — GoRouter sub-routes for this feature. Keep all route definitions for the feature here.
- `extensions/` — Flutter extensions specific to this feature (e.g. formatting helpers tied to the feature's entities).
- `screens/` — Full-page widgets, feature-specific. Compose widgets and react to cubit state.
- `widgets/` — Smaller UI components scoped to the feature. Reusable within the feature but not shared globally.

**`domain/`** — Pure Dart. No Flutter, no external dependencies. The core of the feature.

- `entities/` — Plain Dart classes (Freezed). The canonical data shape used across all layers. Minimal to no external dependencies. May contain additional getters or methods to derive or format data for UI consumption.
- `repositories/` — Abstract contracts (interfaces) that define what data operations the feature needs. No implementation here.
- `use_cases/` — Encapsulate business logic. Called by cubits, they coordinate one or more repositories to produce a result. Each use case file also contains its params class.

**`data/`** — Data sourcing. Implements the contracts defined in `domain/`.

- `repositories/` — Concrete implementations of domain repository interfaces. Fetch from sources and convert models to entities.
- `models/` — Data containers for API JSON or local DB (DAO). Contain a `toEntity()` method; conversion happens at the repository level, never above.
- `sources/` — Raw data access: Dio API clients, SharedPreferences, local DB, etc. No business logic.

**`core/l10n/`** — Localisation. Uses Flutter's built-in l10n generation (`flutter gen-l10n`). `.arb` files are the source of truth; generated Dart code is consumed across the app.

Every feature gets its own directory under `lib/features/`. No feature should depend directly on another feature's internal code.

## Assets

- Assets live in the top-level `assets/` folder, next to `lib/`
- Separated by kind (`icons/`, `images/`, etc.), then by feature inside each kind
- All asset paths are generated via **flutter_gen** — never hardcode asset path strings
- SVG files are rendered with **flutter_svg**, which integrates with flutter_gen to provide typed `SvgGenImage` accessors

## State management

Use Cubit for state management. Cubits call use cases — never repositories directly.
Example:

```dart
@injectable
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;

  AuthCubit(this.signInUseCase) : super(const AuthState.initial());

  Future<void> signIn(SignInParams params) async {
    emit(const AuthState.loading());

    final result = await signInUseCase(params);
    
    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (success) => emit(const AuthState.success()),
    );
  }
}
```

## Data Layer: Repository Implementation

Implements the domain repository and utilizes the datasource and mappers.
Location: `lib/features/[feature]/data/repositories/[feature]_repository_impl.dart`.

*   **Annotations:** Use `@LazySingleton(as: FeatureRepository)`.
*   **Logic:** Calls the datasource and uses `.toEntity()` for mapping.

```dart
@LazySingleton(as: FeatureRepository)
class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureApiDatasource _apiDatasource;

  FeatureRepositoryImpl(this._apiDatasource);

  @override
  Future<List<FeatureEntity>> getFeatures() async {
    final request = const FeatureRequest(); // Construct request parameters as needed
    final response = await _apiDatasource.getItems(request);
    return response.items.map((item) => item.toEntity()).toList();
  }
}
```

### Data Layer: Datasource Implementation
Location: `lib/features/[feature]/data/sources/[feature]_api_datasource_impl.dart`.
*   **Inheritance:** Must inherit from `AppGateway`.
*   **Dependencies:** Injects `AppGateway`.
*   **Annotations:** Uses `@Injectable(as: FeatureApiDatasource)`.
*   **Error Handling:** Uses `safeCall<T>` or `voidSafeCall`.

```dart
@Injectable(as: FeatureApiDatasource)
class FeatureApiDatasourceImpl extends AppGateway implements FeatureApiDatasource {
  final ApiClient _apiClient;
  FeatureApiDatasourceImpl(this._apiClient);

  @override
  Future<FeatureResponse> getItems(FeatureRequest request) async {
    return safeCall<FeatureResponse>(() async {
      final response = await _apiClient.get(
        path: '/api/feature',
        params: request.toJson(),
      );
      return FeatureResponse.fromJson(response.data['data']);
    });
  }
}
```

### Data Layer: AppGateway

Location: `lib/features/core/data/gateway/app_gateway.dart`.

Abstract class that provides error handling for calls. Use `safeCall<T>` for methods that return data and `voidSafeCall` for methods that don't.


## Data Layer: Mappers

Mappers are implemented as **Dart Extensions** to transform API models into Domain Entities.
Location: `lib/features/[feature]/data/mappers/`.

```dart
extension FeatureMapper on FeatureResponse {
  FeatureEntity toEntity() {
    return FeatureEntity(
      id: id,
      name: name,
    );
  }
}
```

## Notification Manager

Use `NotificationManager` with `AppNotificationCubit` inside `AppNotificationBuilder` to display notifications from anywhere in the app, including use cases. This approach lets you trigger UI notifications (such as snackbars or dialogs) directly from business logic without tightly coupling it to Flutter.
Location: `lib/features/core/data/managers/notification_manager_impl.dart`.

```dart
@Singleton(as: NotificationManager)
class NotificationManagerImpl extends NotificationManager {
  final StreamController<AppNotification> _notificationController =
  StreamController<AppNotification>.broadcast();

  @override
  Stream<AppNotification> get notificationStream =>
      _notificationController.stream;

  @override
  void sendNotification(AppNotification notification) {
    _notificationController.add(notification);
  }

  @override
  @disposeMethod
  void dispose() {
    _notificationController.close();
  }
}
```



## Use Cases

Location: `lib/features/core/domain/use_cases/async_use_case.dart`.

```dart
abstract class AsyncUseCase<P, R> {
  final Talker talker;
  final NotificationManager notificationManager;
  final bool isSilent;

  AsyncUseCase(
    this.talker,
    this.notificationManager, {

    /// If true, notification will not be shown.
    this.isSilent = false,
  });

  @protected
  Future<R> onExecute(P params);

  Future<Either<Exception, R>> call(P params) async {
    try {
      final result = await onExecute(params);

      return Right(result);
    } catch (error, stackTrace) {
      talker.handle(
        error,
        stackTrace,
        'Unhandled Exception in ${runtimeType.toString()} with params: $params',
      );



      if (error is NotificationException && !isSilent) {
        notificationManager.sendNotification(error.notification);


        return Left(error);
      } else if (error is Exception) {
        return Left(error);
      } else {
        return Left(Exception(error.toString()));
      }
    }
  }
}
```

Location: `lib/features/core/domain/use_cases/sync_use_case.dart`.

```dart
abstract class SyncUseCase<P, R> {
  final Talker talker;
  final NotificationManager notificationManager;
  final bool isSilent;

  SyncUseCase(
    this.talker,
    this.notificationManager, {

    /// If true, notification will not be shown.
    this.isSilent = false,
  });

  @protected
  R onExecute(P params);

  Either<Exception, R> call(P params) {
    try {
      final result = onExecute(params);

      return Right(result);
    } catch (error, stackTrace) {
      talker.handle(
        error,
        stackTrace,
        'Unhandled Exception in ${runtimeType.toString()} with params: $params',
      );

      if (error is NotificationException && !isSilent) {
        notificationManager.sendNotification(error.notification);


        return Left(error);
      } else if (error is Exception) {
        return Left(error);
      } else {
        return Left(Exception(error.toString()));
      }
    }
  }
}
```

Example of a concrete use case implementation:

```dart
@lazySingleton
class LoginUseCase extends AsyncUseCase<LoginUseCaseParams, void> {
  final AuthRepository _authRepository;

  LoginUseCase(super.talker, super.notificationManager, this._authRepository);

  @override
  Future<void> onExecute(LoginUseCaseParams params) async => _authRepository.login(
    username: params.username,
    password: params.password,
  );
}

class LoginUseCaseParams {
  final String username;
  final String password;

  LoginUseCaseParams({required this.username, required this.password});
}

```

## Data models

All data models use Freezed. Example:

```dart
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Theme

Themes are defined in `lib/core/ui_kit/theme` and are registered as **Material 3 `ThemeExtension`**.

```dart
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: AppFonts.yourFont,
  useMaterial3: true,
  extensions: [
    AppTextStyles.dark(),
    AppColorStyle.dark(),
    AppButtonStyle.dark(),
    AppInputStyle.dark(),
    AppBarStyle.dark(),
    // ... other component styles
  ],
);
```

Each style class implements a `.dark()` factory (and `.light()` if applicable), plus `copyWith` and `lerp`.

## Accessing the theme in widgets

All values are accessible via `BuildContext` from `ThemeContextExtension` —
without the boilerplate `Theme.of(context)`:

```dart
context.appColors          // AppColorStyle
context.appTextStyles      // AppTextStyles
context.appButtonStyle
context.appInputStyle
context.appBarStyle
// ... Similarly, for each component
```


## Typography example

```dart
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final Color _textColor;
  const AppTextStyles._(this._textColor);

  factory AppTextStyles.dark() => const AppTextStyles._(AppColors.yourColor);
  
  TextStyle s64w500({Color? color}) => AppTypography.s64w500(color: color ?? _textColor);

  TextStyle s40w600({Color? color}) => AppTypography.s40w600(color: color ?? _textColor);
  TextStyle s32w600({Color? color}) => AppTypography.s32w600(color: color ?? _textColor);
  TextStyle s32w500({Color? color}) => AppTypography.s32w500(color: color ?? _textColor);
  TextStyle s20w600({Color? color}) => AppTypography.s20w600(color: color ?? _textColor);
  TextStyle s20w500({Color? color}) => AppTypography.s20w500(color: color ?? _textColor);
  TextStyle s14w600({Color? color}) => AppTypography.s14w600(color: color ?? _textColor);
  TextStyle s11w400({Color? color}) => AppTypography.s11w400(color: color ?? _textColor);
  TextStyle s10w500({Color? color}) => AppTypography.s10w500(color: color ?? _textColor);

  @override
  AppTextStyles copyWith({Color? textColor}) {
    return AppTextStyles._(textColor ?? _textColor);
  }

  @override
  AppTextStyles lerp(covariant ThemeExtension<AppTextStyles>? other, double t) {
    if (other == null || other.runtimeType != AppTextStyles) {
      return this;
    }

    final typedOther = other as AppTextStyles;
    final newTextColor = Color.lerp(_textColor, typedOther._textColor, t) ?? _textColor;

    return AppTextStyles._(newTextColor);
  }
}
```


## Icon

Use `SvgGenImage` from flutter_gen for SVG icons. Example: (Assets.images.checker.svg())

```dart
final SvgGenImage myIcon = Assets.icons.myIcon;
```

Use `AssetGenImage` from flutter_gen for raster images. Example: (Assets.images.checker.image())

```dart
final AssetGenImage myImage = Assets.images.myImage;
```

Use `AssetsLottiesGenerated` for Lottie animations. Example: (Assets.lotties.loader.lottie())

```dart
final LottieGenImage myAnimation = Assets.lotties.myAnimation;
```

## Run

```bash
fvm flutter run
fvm flutter test
fvm flutter analyze
dart format .
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

- Mockito with `@GenerateMocks` + build_runner for mocks
- Unit tests for use cases, repositories, entity methods
- Cubit tests with `bloc_test` (`blocTest<FeatureCubit, FeatureState>`)
- Widget tests required for every new feature

## Project-specific notes

<!-- Add non-obvious discoveries, workarounds, API quirks here -->
