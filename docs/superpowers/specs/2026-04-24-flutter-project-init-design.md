# WAIL-9 — Flutter project initialization

**Ticket:** [WAIL-9](https://improvs.atlassian.net/browse/WAIL-9) — Initialize Flutter project with base configuration
**Branch:** `WAIL-9-project-setup`
**Status:** Design approved 2026-04-24

## 1. Summary

Bootstrap a Flutter 3.38.6 mobile app in `/mnt/c/Work/waily` targeting iOS and Android using `flutter create --empty`. Add the full CLAUDE.md-mandated dependency set to `pubspec.yaml` but do not wire any Cubits, themes, routes, or DI — wiring lives in follow-up tickets. Pin the Flutter SDK via FVM so every developer builds against the same toolchain.

The repo currently contains `.claude/`, `CLAUDE.md`, `design/` (Figma exports), `export_figma.py`, and a 432-byte `.gitignore`. All of these must survive the bootstrap untouched.

## 2. Scaffolding commands

```bash
fvm install 3.38.6
fvm use 3.38.6                           # writes .fvmrc

fvm flutter create . \
  --platforms=ios,android \
  --org com.improvs \
  --project-name waily \
  --empty

fvm flutter pub get
```

Produced artefacts: `ios/`, `android/`, `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart` (empty Scaffold placeholder), `test/widget_test.dart`. Android `applicationId` and iOS `CFBundleIdentifier` = `com.improvs.waily`.

## 3. pubspec.yaml dependency set

**Runtime dependencies.** Declared so `pub get` resolves; most are unused until follow-up tickets.

- `flutter_bloc` — state management
- `injectable` + `get_it` — dependency injection
- `go_router` — navigation
- `dartz` — `Either` for use case returns
- `dio` + `retrofit` — HTTP client and codegen
- `freezed_annotation` + `json_annotation` — model codegen annotations
- `flutter_svg` — SVG rendering
- `talker` — logging (referenced by the `AsyncUseCase` base class defined in CLAUDE.md)

**Dev dependencies.**

- `build_runner`
- `freezed`, `json_serializable`
- `injectable_generator`
- `retrofit_generator`
- `flutter_gen_runner`
- `flutter_lints`
- `mockito`

**Codegen config.** No custom `build.yaml` in this ticket — defaults are sufficient. Two separate `pubspec.yaml` blocks are configured:

1. `flutter: > assets:` — lists `assets/icons/` and `assets/images/` so Flutter bundles them at build time.
2. `flutter_gen:` — enables SVG integration and points at the same two directories so `dart run build_runner build` emits typed `Assets.icons.*` and `Assets.images.*` accessors.

Listing empty directories in the `flutter: > assets:` block may emit a warning on `pub get`. If it hard-fails on the pinned SDK version, the implementer adds a `.keep.png` sentinel per directory.

## 4. Folder structure

```
lib/
  main.dart                  # runApp(MainApp()) showing empty Scaffold
  features/.gitkeep
  core/
    ui_kit/.gitkeep
    router/.gitkeep
    constants/.gitkeep
    l10n/.gitkeep
  shared/
    validators/.gitkeep
    extensions/.gitkeep
    formatters/.gitkeep
test/
  widget_test.dart           # smoke test: MainApp builds without error
assets/
  icons/.gitkeep
  images/.gitkeep
```

Placeholders use `.gitkeep` so git tracks empty directories. No barrel files, no Cubits, no `ThemeExtension` classes, no routes — those belong to follow-up tickets.

## 5. .gitignore strategy

Replace the existing 432-byte `.gitignore` with Flutter's standard template (from `flutter create`) plus Improvs additions:

- `.fvm/flutter_sdk` (keep `.fvmrc`, ignore the pinned SDK symlink)
- `.env`, `.env.*`
- `*.key`, `*.pem`, `*.p12`, `*.jks`
- `coverage/`
- `.dart_tool/`
- `ios/Pods/`
- `android/key.properties`
- `*.log`

This satisfies both AC-5 and the security rule that secrets, signing material, and SDK copies never land in git.

## 6. Platform configuration

After `flutter create`:

**Android** (`android/app/build.gradle`)
- `namespace "com.improvs.waily"`
- `applicationId "com.improvs.waily"`
- `minSdkVersion 21`
- `targetSdkVersion` = Flutter's current default (do not override)

**Android** (`android/app/src/main/AndroidManifest.xml`)
- `android:label="Waily"`

**iOS** (`ios/Podfile`)
- `platform :ios, '12.0'`

**iOS** (`ios/Runner.xcodeproj/project.pbxproj`)
- `IPHONEOS_DEPLOYMENT_TARGET = 12.0` in all build configurations

**iOS** (`ios/Runner/Info.plist`)
- `CFBundleDisplayName = Waily`

No Info.plist permission strings, no signing configuration, no app icons. Those arrive with feature tickets that need them.

## 7. Verification

| AC | Verification step |
|----|-------------------|
| Package + bundle id | grep `com.improvs.waily` in `android/app/build.gradle` and `ios/Runner.xcodeproj/project.pbxproj` |
| Runs on iOS + Android | `fvm flutter run -d <ios-sim>` and `fvm flutter run -d <android-emu>` both show an empty Scaffold without errors |
| pubspec essentials | `fvm flutter pub get` exits 0; `fvm flutter pub run build_runner build --delete-conflicting-outputs` exits 0 |
| Folder structure | `find lib -type d` shows `features/`, `core/{ui_kit,router,constants,l10n}/`, `shared/{validators,extensions,formatters}/` |
| .gitignore | `git check-ignore .env` prints the path; Flutter build artefacts are ignored |

All five ACs have a deterministic verification command. `/improvs:finish` can run these checks as part of the completion gate.

## 8. Explicitly out of scope

- No Cubits, no state wiring
- No `ThemeExtension` classes (`AppColors`, `AppTextStyles`, etc.)
- No `GoRouter` configuration
- No `@InjectableInit()` entry point
- No API clients (`ApiClient`, datasources, `AppGateway`)
- No localisation `.arb` files
- No widget tests beyond the generated smoke test
- No app icons, splash assets, or signing config

The `pubspec.yaml` asset manifest points at empty `assets/icons/` and `assets/images/` folders, so follow-up tickets can drop files in without reconfiguring the manifest.

## 9. Isolation and clarity

Each unit of this setup can be reasoned about independently:

- **Scaffolding commands** — determined by inputs only (SDK version, bundle id, platforms). No dependency on pubspec content.
- **pubspec** — has declared dependencies but zero imports in code. Future DI/bloc wiring tickets add imports without touching platform configs.
- **Platform configs** — touch native files only, never Dart code.
- **Folder placeholders** — `.gitkeep` files only. Safe to replace with real files when features arrive.
- **.gitignore** — standalone file, no dependency on any other unit.

No cross-unit coupling beyond the explicit contracts above (bundle id appears in pubspec AND native configs; SDK version appears in `.fvmrc` AND pubspec `environment:` block — both are trivial to keep in sync).

## 10. Open risks

- **Flutter CLI not available in WSL** — developer runs the `fvm flutter create` command from Windows PowerShell or a WSL shell with Flutter properly installed. This is an environment concern, not a design concern; the command itself is unchanged. If WSL shell runs into the `bash\r` issue noted during discovery, fall back to PowerShell.
- **Existing remote 403** — the branch `WAIL-9-project-setup` did not push to `KofeinTech/waily`. Out of scope for this ticket; access must be resolved separately before `/improvs:finish` can push.
