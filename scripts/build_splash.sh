#!/usr/bin/env bash
# Build the native splash end-to-end:
#   1. Generate logo + tagline composite PNG and gradient background PNG.
#   2. Run flutter_native_splash:create.
#   3. Restore the real gradient PNG (the package re-samples
#      `background_image:` down to a 1×1 colour, killing the gradient).
#   4. Restore the iOS LaunchScreen view backgroundColor (the package
#      always rewrites it to white, which causes a white flash before
#      Flutter takes over).

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "==> Generating splash PNGs"
python3 scripts/build_splash_logo.py

echo "==> Running flutter_native_splash:create"
fvm dart run flutter_native_splash:create --path=flutter_native_splash.yaml

echo "==> Restoring real gradient background PNGs"
GRAD="assets/splash/bg_gradient.png"
cp "$GRAD" ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png
cp "$GRAD" ios/Runner/Assets.xcassets/LaunchBackground.imageset/darkbackground.png
cp "$GRAD" android/app/src/main/res/drawable/background.png
cp "$GRAD" android/app/src/main/res/drawable-night/background.png
cp "$GRAD" android/app/src/main/res/drawable-v21/background.png
cp "$GRAD" android/app/src/main/res/drawable-night-v21/background.png

echo "==> Patching iOS LaunchScreen view backgroundColor"
SB="ios/Runner/Base.lproj/LaunchScreen.storyboard"
sed -i.bak \
  's/<color key="backgroundColor" red="1" green="1" blue="1" alpha="1"/<color key="backgroundColor" red="0.00784313725490196" green="0.03137254901960784" blue="0.08235294117647059" alpha="1"/' \
  "$SB"
rm -f "$SB.bak"

echo "==> Replacing Android post-splash logo with no-tagline variant"
# Per design, Android shows just the WAILY wordmark (no tagline) in the
# legacy launch_background.xml. flutter_native_splash uses the global
# `image:` for this, which is the iOS composite — so swap it out per
# density bucket from the Android-specific PNG.
ANDROID_LOGO="assets/splash/logo_android.png"
declare -a DENSITIES=(
  "drawable-mdpi:103:32"
  "drawable-hdpi:155:48"
  "drawable-xhdpi:206:64"
  "drawable-xxhdpi:309:96"
  "drawable-xxxhdpi:412:128"
)
for spec in "${DENSITIES[@]}"; do
  IFS=":" read -r dir w h <<< "$spec"
  for variant in "" "-night"; do
    target="android/app/src/main/res/drawable${variant}-${dir#drawable-}/splash.png"
    if [[ -f "$target" ]]; then
      sips --resampleHeightWidth "$h" "$w" "$ANDROID_LOGO" --out "$target" >/dev/null
    fi
  done
done

echo "==> Done. Run \`flutter clean && flutter run\` and reinstall the app on simulators."
