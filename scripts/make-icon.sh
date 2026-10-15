#!/usr/bin/env bash
# Renders Packaging/AppIcon.svg into Pomodot.icns with every size macOS asks for.
# Usage: scripts/make-icon.sh [output.icns]   (default: dist/Pomodot.icns)
set -euo pipefail

cd "$(dirname "$0")/.."
out="${1:-dist/Pomodot.icns}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

iconset="$work/Pomodot.iconset"
mkdir -p "$iconset" "$(dirname "$out")"

sips -s format png Packaging/AppIcon.svg --out "$work/icon-1024.png" >/dev/null

for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$work/icon-1024.png" --out "$iconset/icon_${size}x${size}.png" >/dev/null
    double=$((size * 2))
    sips -z "$double" "$double" "$work/icon-1024.png" --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$iconset" -o "$out"
echo "Made $out"
