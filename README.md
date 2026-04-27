# waily

Flutter mobile app for Waily.

## Setup

1. Install Flutter via FVM (`fvm install` reads `.fvmrc`).
2. Copy the env template:
   ```bash
   cp .env.example .env
   ```
3. Edit `.env` with the values for your environment (see "Environment configuration" below).
4. Fetch dependencies:
   ```bash
   fvm flutter pub get
   ```
5. Run the app:
   ```bash
   fvm flutter run
   ```

## Environment configuration

The app reads runtime configuration from a single `.env` file in the project root. The file is gitignored — each developer keeps their own copy.

`.env.example` is the committed template. To get started:

```bash
cp .env.example .env
```

### Keys

| Key              | Type   | Description                                                |
|------------------|--------|------------------------------------------------------------|
| `TYPE`           | string | `DEV` or `PROD`. `DEV` shows the corner banner; any other value is treated as dev. |
| `API_BASE_URL`   | string | Base URL of the Waily backend.                             |
| `ENABLE_LOGGING` | bool   | `true` enables verbose logging; `false` (or missing) disables it. |

### Reading values in code

```dart
import 'package:waily/core/env/env.dart';

final url = kEnv.apiBaseUrl;
final loggingOn = kEnv.enableLogging;
final isDev = kEnvHelper.isDev;
```

### Adding a new key

1. Add a typed getter to `lib/core/env/env_variables.dart` (`_EnvVariables`).
2. Add the field to `_EnvData` (constructor, field, `props`).
3. Wire it into the `_env` getter at the bottom of the same file.
4. Update `.env.example` with a placeholder.

### Hot reload caveat

`flutter_dotenv` reads `.env` from the asset bundle. After editing `.env`, you must perform a hot **restart** (capital R in `flutter run`) — hot reload (`r`) does not re-read the file.

## Testing

```bash
fvm flutter test
fvm flutter analyze
```

## Architecture

See `CLAUDE.md` for the full project conventions (clean architecture, Cubit state management, theming, asset generation).
