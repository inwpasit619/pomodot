#!/usr/bin/env bash
# One command: check Core's imports → universal release build → assemble
# dist/Pomodot.app → ad-hoc sign the whole bundle → verify the signature.
set -euo pipefail

cd "$(dirname "$0")/.."

# Core holds rules only. It must never import a UI or notification framework
# (Cocoa counts too: it brings in AppKit). Also catches `import struct SwiftUI.View`.
if grep -rnE '^[[:space:]]*(@[A-Za-z_]+[[:space:]]+)*import[[:space:]]+((typealias|struct|class|enum|protocol|let|var|func)[[:space:]]+)?(AppKit|SwiftUI|UserNotifications|Cocoa)\b' Sources/Core; then
    echo "error: Sources/Core imports AppKit, SwiftUI, UserNotifications or Cocoa (see above)" >&2
    exit 1
fi

arch_flags=(-c release --arch arm64 --arch x86_64)
swift build "${arch_flags[@]}"
bin_dir="$(swift build "${arch_flags[@]}" --show-bin-path)"

app="dist/Pomodot.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

cp "$bin_dir/Pomodot" "$app/Contents/MacOS/Pomodot"
scripts/make-icon.sh "$app/Contents/Resources/Pomodot.icns"

plist="$app/Contents/Info.plist"
cp Packaging/Info.plist "$plist"
plutil -replace CFBundleShortVersionString -string "$(tr -d '[:space:]' < VERSION)" "$plist"
plutil -replace CFBundleVersion -string "$(git rev-list --count HEAD)" "$plist"
plutil -lint "$plist" >/dev/null

# Sign the .app itself (never --deep when signing), then verify the whole bundle.
codesign --force --sign - "$app"
codesign --verify --strict --deep "$app"

echo "Built and verified $app"
