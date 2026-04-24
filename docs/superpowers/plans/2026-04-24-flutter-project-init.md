# Flutter Project Initialization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Ticket:** [WAIL-9](https://improvs.atlassian.net/browse/WAIL-9)
**Branch:** `WAIL-9-project-setup`
**Spec:** `docs/superpowers/specs/2026-04-24-flutter-project-init-design.md`

**Goal:** Bootstrap a Flutter 3.38.6 mobile app in `/mnt/c/Work/waily` targeting iOS + Android with bundle id `com.improvs.waily`, FVM-pinned SDK, all CLAUDE.md-mandated deps declared (but not wired), and the feature-based folder skeleton in place.

**Architecture:** `flutter create . --empty --platforms=ios,android --org com.improvs --project-name waily` generates the platform scaffold. `pubspec.yaml` is then populated with the full CLAUDE.md dep set — zero imports in code, so codegen runs clean. `lib/features/`, `lib/core/*/`, `lib/shared/*/` are created with `.gitkeep` sentinels. Platform configs are tuned for iOS 12 / Android API 21. `.gitignore` is augmented (not replaced) because the existing file already covers most Flutter entries.

**Tech Stack:** Flutter 3.38.6 (FVM-pinned), Dart, Gradle (Android), CocoaPods (iOS), build_runner / freezed / json_serializable / injectable_generator / retrofit_generator / flutter_gen_runner.

---

## Pre-flight context

Before Task 1, the repo contains uncommitted changes from a previous session (`.claude/rules/*.md`, `CLAUDE.md`, `.gitignore`, `design/**`, `export_figma.py`). The user chose "bring these to the new branch" during `/improvs:start`, so Task 1 commits them as a separate preparatory commit. They are unrelated to the Flutter bootstrap and should not mix with it in history.

The branch `WAIL-9-project-setup` is already created locally. Remote push is blocked by a 403 from `KofeinTech/waily.git` — out of scope for this ticket; developer resolves access before `/improvs:finish`.

---

### Task 1: Commit pre-existing work-in-progress

**Files:**
- Stage: `.gitignore`, `CLAUDE.md`, `.claude/rules/flutter-rules.md`, `.claude/rules/security-rules.md`, `export_figma.py`, `design/**`

- [ ] **Step 1: Verify what's modified**

Run:
```bash
git status --short
```
Expected: list matches the pre-flight context description (design assets, rules, CLAUDE.md, .gitignore, export script). If anything unexpected appears, stop and consult the developer.

- [ ] **Step 2: Stage the pre-existing changes**

Run:
```bash
git add .gitignore CLAUDE.md .claude/rules/ export_figma.py design/
```

- [ ] **Step 3: Verify the working tree is clean after staging**

Run:
```bash
git status --short
```
Expected: no unstaged `M`/`??` lines — only the staged entries remain.

- [ ] **Step 4: Commit**

Run:
```bash
git commit -m "chore: sync design exports, rules, and gitignore updates"
```

- [ ] **Step 5: Verify commit exists on branch**

Run:
```bash
git log --oneline -3
```
Expected: top commit is "chore: sync design exports, rules, and gitignore updates".

---

### Task 2: Pin Flutter SDK via FVM

**Files:**
- Create: `.fvmrc`

- [ ] **Step 1: Confirm FVM is installed**

Run:
```bash
fvm --version
```
Expected: version string prints (e.g. `3.x.x`). If `command not found`, install via `dart pub global activate fvm` or the Windows installer, then re-run.

- [ ] **Step 2: Install the pinned Flutter SDK**

Run:
```bash
fvm install 3.38.6
```
Expected: FVM downloads and caches Flutter 3.38.6. Output ends with "Flutter SDK 3.38.6 installed."

- [ ] **Step 3: Pin the project to 3.38.6**

Run (from repo root):
```bash
fvm use 3.38.6
```
Expected: creates `.fvmrc` with `{"flutter":"3.38.6"}` and a `.fvm/` symlink to the SDK. `.fvm/flutter_sdk` is ignored by the existing `.gitignore` — verify with `git status`.

- [ ] **Step 4: Verify the pinned toolchain runs**

Run:
```bash
fvm flutter --version
```
Expected: first line reports `Flutter 3.38.6`.

- [ ] **Step 5: Commit the pin**

Run:
```bash
git add .fvmrc
git commit -m "chore(flutter): pin SDK to 3.38.6 via FVM"
```

---

### Task 3: Generate Flutter project scaffolding

**Files:**
- Create (via `flutter create`): `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, `test/widget_test.dart`, `android/`, `ios/`, `.metadata`
- Preserved: `.claude/`, `CLAUDE.md`, `design/`, `export_figma.py`, `.gitignore`, `docs/`, `.fvmrc`

- [ ] **Step 1: Pre-check for conflicts**

Run:
```bash
ls /mnt/c/Work/waily | grep -E '^(pubspec.yaml|lib|ios|android|test|analysis_options.yaml|.metadata)$'
```
Expected: no output. If any of these already exist, investigate before continuing — `flutter create` may silently skip them.

- [ ] **Step 2: Run flutter create**

Run (from repo root):
```bash
fvm flutter create . \
  --platforms=ios,android \
  --org com.improvs \
  --project-name waily \
  --empty
```
Expected: last line reads "All done!". `ios/` and `android/` directories appear; `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, `test/widget_test.dart` are created. Existing files in `.claude/`, `design/`, etc. are untouched (verify with `git status`).

- [ ] **Step 3: Verify bundle id / package name landed in native configs**

Run:
```bash
grep -R "com.improvs.waily" android/app ios/Runner.xcodeproj
```
Expected: at least one hit in `android/app/build.gradle` (or `build.gradle.kts`) and several in `ios/Runner.xcodeproj/project.pbxproj`.

- [ ] **Step 4: Verify main.dart is empty-mode (no counter demo)**

Run:
```bash
grep -c "FloatingActionButton\|counter" lib/main.dart
```
Expected: `0`. The `--empty` flag should omit the counter template.

- [ ] **Step 5: Stage and commit scaffolding**

Run:
```bash
git add -A
git status --short
```
Expected: many new files — iOS, Android, lib/main.dart, pubspec.yaml, etc. No deletions.

Then:
```bash
git commit -m "feat(flutter): scaffold iOS/Android project via flutter create --empty"
```

---

### Task 4: Add runtime dependencies to pubspec.yaml

**Files:**
- Modify: `pubspec.yaml` — dependencies section

- [ ] **Step 1: Inspect the generated pubspec.yaml**

Run:
```bash
cat pubspec.yaml
```
Expected: baseline pubspec with `name: waily`, `environment: sdk: '>=X.X.X <4.0.0'`, dependencies section containing only `flutter: sdk: flutter` and `cupertino_icons`.

- [ ] **Step 2: Replace the dependencies block**

Edit `pubspec.yaml`, locate the `dependencies:` block, and replace it with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # State management (not wired in this ticket)
  flutter_bloc: ^8.1.6

  # Dependency injection (not wired in this ticket)
  injectable: ^2.5.0
  get_it: ^8.0.0

  # Navigation (not wired in this ticket)
  go_router: ^14.6.1

  # Functional types for use case returns
  dartz: ^0.10.1

  # HTTP client + codegen (no clients created in this ticket)
  dio: ^5.7.0
  retrofit: ^4.4.1

  # Codegen annotations
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Assets
  flutter_svg: ^2.0.16

  # Logging (base class reference in CLAUDE.md)
  talker: ^4.4.1
  talker_flutter: ^4.4.1
```

Use exact patch-bumped versions in the `^X.Y.Z` form so `pub get` resolves deterministically today; the implementer may bump within a minor range if the registry shows a newer compatible release.

- [ ] **Step 3: Run pub get**

Run:
```bash
fvm flutter pub get
```
Expected: exit 0. Output ends with "Got dependencies!" or "Changed N dependencies!" with no ERROR lines.

- [ ] **Step 4: Commit**

Run:
```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat(deps): add runtime dependencies per CLAUDE.md stack"
```

---

### Task 5: Add dev dependencies to pubspec.yaml

**Files:**
- Modify: `pubspec.yaml` — dev_dependencies section

- [ ] **Step 1: Replace dev_dependencies block**

Edit `pubspec.yaml`, locate `dev_dependencies:` and replace with:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  # Codegen
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  injectable_generator: ^2.6.2
  retrofit_generator: ^9.1.2
  flutter_gen_runner: ^5.8.0

  # Mocks
  mockito: ^5.4.4
  build_verify: ^3.1.0
```

- [ ] **Step 2: Run pub get**

Run:
```bash
fvm flutter pub get
```
Expected: exit 0. No dependency resolution errors.

- [ ] **Step 3: Smoke-test build_runner**

Run:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```
Expected: exit 0. Output reports "Succeeded after Xs with N outputs" or "Nothing to do" (no code currently requires codegen). No ERROR lines.

- [ ] **Step 4: Commit**

Run:
```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat(deps): add dev_dependencies for codegen and testing"
```

---

### Task 6: Configure flutter and flutter_gen blocks in pubspec.yaml

**Files:**
- Modify: `pubspec.yaml` — `flutter:` and new `flutter_gen:` block

- [ ] **Step 1: Edit the flutter block**

Locate the `flutter:` block at the bottom of `pubspec.yaml`. Replace its contents with:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/images/
```

- [ ] **Step 2: Append the flutter_gen block at the top level of pubspec.yaml**

After the closing of the `flutter:` block, append:

```yaml
flutter_gen:
  output: lib/core/gen/
  line_length: 120
  assets:
    enabled: true
    outputs:
      class_name: Assets
    exclude:
      - assets/**/.gitkeep
  integrations:
    flutter_svg: true
```

- [ ] **Step 3: Create the target dirs referenced by the asset manifest**

Run:
```bash
mkdir -p assets/icons assets/images
```

Flutter will emit a warning if `assets/icons/` or `assets/images/` are completely empty at pub get. The next task creates `.gitkeep` sentinels; if the implementer sees a hard error here, add `.gitkeep` files first and re-run.

- [ ] **Step 4: Run pub get**

Run:
```bash
fvm flutter pub get
```
Expected: exit 0. A warning about empty asset directories is acceptable; a hard error is not (fall through to Task 7 first in that case).

- [ ] **Step 5: Commit**

Run:
```bash
git add pubspec.yaml
git commit -m "feat(pubspec): configure assets and flutter_gen blocks"
```

---

### Task 7: Create lib/ feature-based folder skeleton

**Files:**
- Create: `lib/features/.gitkeep`, `lib/core/ui_kit/.gitkeep`, `lib/core/router/.gitkeep`, `lib/core/constants/.gitkeep`, `lib/core/l10n/.gitkeep`, `lib/shared/validators/.gitkeep`, `lib/shared/extensions/.gitkeep`, `lib/shared/formatters/.gitkeep`
- Create: `assets/icons/.gitkeep`, `assets/images/.gitkeep`

- [ ] **Step 1: Create lib/ skeleton**

Run:
```bash
mkdir -p \
  lib/features \
  lib/core/ui_kit lib/core/router lib/core/constants lib/core/l10n \
  lib/shared/validators lib/shared/extensions lib/shared/formatters

touch \
  lib/features/.gitkeep \
  lib/core/ui_kit/.gitkeep lib/core/router/.gitkeep lib/core/constants/.gitkeep lib/core/l10n/.gitkeep \
  lib/shared/validators/.gitkeep lib/shared/extensions/.gitkeep lib/shared/formatters/.gitkeep
```

- [ ] **Step 2: Create assets/ skeleton sentinels**

Run:
```bash
touch assets/icons/.gitkeep assets/images/.gitkeep
```

- [ ] **Step 3: Verify tree**

Run:
```bash
find lib assets -type f -name '.gitkeep' | sort
```
Expected output (10 lines — 8 in `lib/`, 2 in `assets/`):
```
assets/icons/.gitkeep
assets/images/.gitkeep
lib/core/constants/.gitkeep
lib/core/l10n/.gitkeep
lib/core/router/.gitkeep
lib/core/ui_kit/.gitkeep
lib/features/.gitkeep
lib/shared/extensions/.gitkeep
lib/shared/formatters/.gitkeep
lib/shared/validators/.gitkeep
```

- [ ] **Step 4: Commit**

Run:
```bash
git add lib/ assets/
git commit -m "feat(structure): scaffold feature-based folder skeleton with .gitkeep sentinels"
```

---

### Task 8: Augment .gitignore with Flutter platform artifacts

**Files:**
- Modify: `.gitignore` (append section)

**Context:** The existing `.gitignore` already covers Flutter build artefacts (`.dart_tool/`, `build/`, `*.g.dart`, `*.freezed.dart`, `*.mocks.dart`), FVM (`.fvm/flutter_sdk`), secrets (`*.key`, `*.pem`, etc.), and coverage. Missing are iOS/Android platform-specific entries that `flutter create` would normally add.

- [ ] **Step 1: Check what's currently ignored for platforms**

Run:
```bash
grep -E "^ios/|^android/|Pods|symlinks|ephemeral|GeneratedPluginRegistrant|xcuserdata|\.gradle" .gitignore || echo "NONE"
```
Expected: `NONE`. Confirms the platform entries are absent.

- [ ] **Step 2: Append platform-specific ignores**

Open `.gitignore` and append this block at the end. `gradlew` / `gradlew.bat` stay tracked (Flutter default; CI and fresh clones rely on them) — do not ignore them.

```
# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/App.framework
ios/Flutter/ephemeral/
ios/Flutter/flutter_export_environment.sh
ios/Runner/GeneratedPluginRegistrant.*
ios/Runner.xcworkspace/xcuserdata/
ios/Runner.xcodeproj/xcuserdata/
ios/Runner.xcodeproj/project.xcworkspace/xcuserdata/

# Android
android/.gradle/
android/captures/
android/.idea/
android/gradle/wrapper/gradle-wrapper.jar
android/app/release/
android/app/debug/
android/**/GeneratedPluginRegistrant.java
```

- [ ] **Step 3: Verify with git check-ignore**

Run:
```bash
git check-ignore -v ios/Pods android/.gradle .env .fvm/flutter_sdk
```
Expected: each path prints its matching rule from `.gitignore`. No silent misses.

- [ ] **Step 4: Commit**

Run:
```bash
git add .gitignore
git commit -m "chore(gitignore): add iOS/Android platform artifact ignores"
```

---

### Task 9: Configure Android platform (minSdk 21, app label)

**Files:**
- Modify: `android/app/build.gradle` (or `android/app/build.gradle.kts` depending on Flutter 3.38.6 defaults)
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Identify which gradle file Flutter generated**

Run:
```bash
ls android/app/ | grep -E 'build.gradle(\.kts)?'
```
Expected: either `build.gradle` (Groovy) or `build.gradle.kts` (Kotlin DSL). Flutter 3.38.6 defaults to the Kotlin DSL; older versions use Groovy. Remember the filename for the next step.

- [ ] **Step 2: Inspect current defaults**

Run:
```bash
grep -E "minSdk|targetSdk|namespace|applicationId" android/app/build.gradle* 2>/dev/null
```
Expected: see current values. Flutter 3.38.6 typically emits `minSdk flutter.minSdkVersion` (Groovy) or `minSdk = flutter.minSdkVersion` (Kotlin DSL), which defaults to a Flutter-provided constant.

- [ ] **Step 3: Override minSdkVersion to 21**

Edit `android/app/build.gradle` or `android/app/build.gradle.kts`:

For the Kotlin DSL (`.kts`), replace:
```kotlin
minSdk = flutter.minSdkVersion
```
with:
```kotlin
minSdk = 21
```

For the Groovy file, replace:
```gradle
minSdkVersion flutter.minSdkVersion
```
with:
```gradle
minSdkVersion 21
```

Leave `targetSdk` / `targetSdkVersion` as Flutter's default.

- [ ] **Step 4: Verify applicationId and namespace**

Run:
```bash
grep -E 'applicationId|namespace' android/app/build.gradle*
```
Expected: `applicationId "com.improvs.waily"` (Groovy) or `applicationId = "com.improvs.waily"` (Kotlin DSL); namespace same. `flutter create --org com.improvs --project-name waily` should have set these correctly — no manual change required.

- [ ] **Step 5: Set app label**

Edit `android/app/src/main/AndroidManifest.xml`. Locate the `<application>` tag and change:
```xml
android:label="waily"
```
to:
```xml
android:label="Waily"
```

(Flutter's default label from `--project-name waily` is lowercase. The product name is "Waily".)

- [ ] **Step 6: Verify**

Run:
```bash
grep 'android:label' android/app/src/main/AndroidManifest.xml
grep -E "minSdk\s*=?\s*21" android/app/build.gradle*
```
Expected: label is `"Waily"`; minSdk is `21`.

- [ ] **Step 7: Commit**

Run:
```bash
git add android/
git commit -m "feat(android): set minSdk 21 and Waily app label"
```

---

### Task 10: Configure iOS platform (deployment target 12.0, display name)

**Files:**
- Modify: `ios/Podfile` — `platform :ios, '12.0'`
- Modify: `ios/Runner.xcodeproj/project.pbxproj` — `IPHONEOS_DEPLOYMENT_TARGET = 12.0`
- Modify: `ios/Runner/Info.plist` — `CFBundleDisplayName`

- [ ] **Step 1: Edit Podfile**

Edit `ios/Podfile`. Locate the line:
```ruby
# platform :ios, '13.0'
```
(or similar — commented out or set to a different version). Replace with:
```ruby
platform :ios, '12.0'
```

- [ ] **Step 2: Update all IPHONEOS_DEPLOYMENT_TARGET occurrences**

Run:
```bash
grep -c "IPHONEOS_DEPLOYMENT_TARGET" ios/Runner.xcodeproj/project.pbxproj
```
Expected: a small integer (typically 3 — Debug, Profile, Release). Remember the count.

Run:
```bash
sed -i.bak 's/IPHONEOS_DEPLOYMENT_TARGET = [0-9.]*/IPHONEOS_DEPLOYMENT_TARGET = 12.0/g' ios/Runner.xcodeproj/project.pbxproj
rm ios/Runner.xcodeproj/project.pbxproj.bak
```

Verify all occurrences are now `12.0`:
```bash
grep "IPHONEOS_DEPLOYMENT_TARGET" ios/Runner.xcodeproj/project.pbxproj
```
Expected: every line shows `IPHONEOS_DEPLOYMENT_TARGET = 12.0;`.

- [ ] **Step 3: Add / update CFBundleDisplayName in Info.plist**

Inspect `ios/Runner/Info.plist`:
```bash
grep -A1 'CFBundleDisplayName\|CFBundleName' ios/Runner/Info.plist
```

The default `CFBundleDisplayName` is `Waily` if `flutter create` capitalized it, or `waily` (lowercase) otherwise. If lowercase or missing, edit `ios/Runner/Info.plist` to add or replace:

```xml
<key>CFBundleDisplayName</key>
<string>Waily</string>
```

If `CFBundleDisplayName` already exists, update its value. If not, add the two lines inside the root `<dict>`.

- [ ] **Step 4: Run pod install to lock the platform change**

Requires macOS + CocoaPods. On Windows/Linux this step is skipped; the developer running this plan on macOS must execute:

```bash
cd ios && pod install && cd ..
```
Expected: `Podfile.lock` updates. If the plan is executed on Windows/Linux, skip this step and leave the `pod install` for the developer on their iOS build machine.

- [ ] **Step 5: Commit**

Run:
```bash
git add ios/
git commit -m "feat(ios): set deployment target 12.0 and Waily display name"
```

---

### Task 11: Verify build_runner codegen still runs clean after full configuration

**Files:**
- None modified

- [ ] **Step 1: Run pub get once more**

Run:
```bash
fvm flutter pub get
```
Expected: exit 0. No warnings about missing asset dirs (sentinels exist now).

- [ ] **Step 2: Run build_runner**

Run:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```
Expected: exit 0. `flutter_gen` produces `lib/core/gen/assets.gen.dart` with an empty (or near-empty) `Assets` class, since the asset directories only contain `.gitkeep` files that are excluded.

- [ ] **Step 3: Confirm the generated file is gitignored**

Run:
```bash
git check-ignore lib/core/gen/assets.gen.dart
```
Expected: prints the path (matches `*.g.dart` pattern — if the filename doesn't match, add `lib/core/gen/*.gen.dart` to `.gitignore` and re-run).

If `git check-ignore` exits non-zero (the file is NOT ignored), append this line to `.gitignore`:
```
lib/**/*.gen.dart
```

Stage and amend the `.gitignore` commit (Task 8) — or add as a new commit with message `chore(gitignore): ignore flutter_gen output`.

- [ ] **Step 4: Verify analyzer passes**

Run:
```bash
fvm flutter analyze
```
Expected: "No issues found!" If lints trip on the generated or scaffolded code, fix them or add narrowly-scoped `// ignore:` comments only if the lint is spurious. Do not broaden `analysis_options.yaml` to silence real issues.

- [ ] **Step 5: Run tests**

Run:
```bash
fvm flutter test
```
Expected: 1 smoke test passes (the generated `widget_test.dart`).

If the smoke test fails because `MainApp` name differs from what the test expects (Flutter `--empty` generates a placeholder test that may reference `const MainApp()` or similar), update the test to match whatever `main.dart` actually exports.

---

### Task 12: Run on iOS simulator

**Files:**
- None modified

**Requires:** macOS with Xcode + iOS simulator running.

- [ ] **Step 1: List devices**

Run:
```bash
fvm flutter devices
```
Expected: an iOS simulator appears in the list (e.g. "iPhone 15 (mobile) • <id> • ios • iOS 17.x"). If not, start a simulator via Xcode first.

- [ ] **Step 2: Launch on iOS**

Run:
```bash
fvm flutter run -d "iPhone 15"
```
(Substitute whichever simulator name is actually available.)
Expected: builds, installs, and launches. App shows an empty Scaffold (white or Material default background, no widgets). Hot reload prompt appears. Type `q` to quit.

- [ ] **Step 3: Document the verification**

Record in the ticket comment or PR description: "Verified on iOS simulator <simulator-name> running iOS <version>". No commit — verification is a record only.

---

### Task 13: Run on Android emulator

**Files:**
- None modified

**Requires:** Android SDK + at least one AVD configured.

- [ ] **Step 1: List devices**

Run:
```bash
fvm flutter devices
```
Expected: an Android emulator appears (e.g. "sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 14"). If not, start an emulator via `emulator -avd <name>` first.

- [ ] **Step 2: Launch on Android**

Run:
```bash
fvm flutter run -d emulator-5554
```
(Or whatever device id appears.)
Expected: Gradle builds (slow on first run — may take 2-5 minutes), app installs, launches. Empty Scaffold appears. App label on the home screen reads "Waily". Type `q` to quit.

- [ ] **Step 3: Document verification**

Record: "Verified on Android emulator <avd-name> API <level>". No commit.

---

### Task 14: Full acceptance criteria verification

**Files:**
- None modified

- [ ] **Step 1: AC-1 — package + bundle id**

Run:
```bash
grep -R "com.improvs.waily" android/app ios/Runner* | wc -l
```
Expected: at least 4 matches (AndroidManifest.xml, build.gradle*, Info.plist or project.pbxproj).

- [ ] **Step 2: AC-2 — runs on iOS and Android**

Confirmed by Task 12 and Task 13 above. If either failed, go back and fix before closing.

- [ ] **Step 3: AC-3 — pubspec essentials**

Run:
```bash
fvm flutter pub get && fvm dart run build_runner build --delete-conflicting-outputs
```
Expected: both commands exit 0.

Verify each mandated dep is declared:
```bash
for pkg in flutter_bloc injectable get_it go_router dartz dio retrofit freezed_annotation json_annotation flutter_svg talker build_runner freezed json_serializable injectable_generator retrofit_generator flutter_gen_runner mockito flutter_lints; do
  grep -q "^  $pkg:" pubspec.yaml || echo "MISSING: $pkg"
done
```
Expected: no output (all deps present).

- [ ] **Step 4: AC-4 — folder structure**

Run:
```bash
find lib -type d | sort
```
Expected (exact list):
```
lib
lib/core
lib/core/constants
lib/core/l10n
lib/core/router
lib/core/ui_kit
lib/features
lib/shared
lib/shared/extensions
lib/shared/formatters
lib/shared/validators
```

(Plus `lib/core/gen/` if build_runner has already run — acceptable.)

- [ ] **Step 5: AC-5 — gitignore**

Run:
```bash
for f in .env .fvm/flutter_sdk ios/Pods/test.txt android/.gradle/test.txt build/test.txt .dart_tool/test.txt; do
  git check-ignore "$f" > /dev/null && echo "IGNORED: $f" || echo "NOT IGNORED: $f"
done
```
Expected: every line reads `IGNORED:`. Any `NOT IGNORED` line is a failure — fix `.gitignore` and re-run.

- [ ] **Step 6: Final git log check**

Run:
```bash
git log --oneline main..HEAD 2>/dev/null || git log --oneline develop..HEAD
```
Expected: clean linear history with commits for each task (approximately):
1. chore: sync design exports, rules, and gitignore updates
2. chore(flutter): pin SDK to 3.38.6 via FVM
3. feat(flutter): scaffold iOS/Android project via flutter create --empty
4. feat(deps): add runtime dependencies per CLAUDE.md stack
5. feat(deps): add dev_dependencies for codegen and testing
6. feat(pubspec): configure assets and flutter_gen blocks
7. feat(structure): scaffold feature-based folder skeleton with .gitkeep sentinels
8. chore(gitignore): add iOS/Android platform artifact ignores
9. feat(android): set minSdk 21 and Waily app label
10. feat(ios): set deployment target 12.0 and Waily display name

- [ ] **Step 7: Ready for /improvs:finish**

At this point: all 5 AC verified, all tasks committed, branch tip represents a clean bootstrap. Push remains blocked by the 403 — developer resolves that before running `/improvs:finish`, which will create the PR.
