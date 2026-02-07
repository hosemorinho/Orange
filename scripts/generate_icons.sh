#!/bin/bash
# generate_icons.sh — Download source icon from URL and generate all platform icons
# Usage: ./scripts/generate_icons.sh <ICON_URL>
#
# Requires: ImageMagick (convert), cwebp (optional, falls back to convert)

set -euo pipefail

ICON_URL="${1:?Usage: generate_icons.sh <ICON_URL>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TMP_DIR="$(mktemp -d)"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo "==> Downloading source icon from URL..."
curl -fsSL "$ICON_URL" -o "$TMP_DIR/source.png"

# Verify it's a valid image
if ! file "$TMP_DIR/source.png" | grep -qiE 'image|PNG|JPEG|bitmap'; then
  echo "ERROR: Downloaded file is not a valid image"
  exit 1
fi

# Convert to PNG if needed (in case source is JPEG/WebP/etc)
convert "$TMP_DIR/source.png" -strip "$TMP_DIR/icon_src.png"

echo "==> Generating assets/images/ icons..."
mkdir -p "$PROJECT_DIR/assets/images"
convert "$TMP_DIR/icon_src.png" -resize 1024x1024 "$PROJECT_DIR/assets/images/icon.png"

# Generate ICO (multi-size: 16, 32, 48, 64, 128, 256)
convert "$TMP_DIR/icon_src.png" \
  \( -clone 0 -resize 16x16 \) \
  \( -clone 0 -resize 32x32 \) \
  \( -clone 0 -resize 48x48 \) \
  \( -clone 0 -resize 64x64 \) \
  \( -clone 0 -resize 128x128 \) \
  \( -clone 0 -resize 256x256 \) \
  -delete 0 "$PROJECT_DIR/assets/images/icon.ico"

echo "==> Generating Android mipmap icons..."
declare -A ANDROID_SIZES=(
  ["mdpi"]=48
  ["hdpi"]=72
  ["xhdpi"]=96
  ["xxhdpi"]=144
  ["xxxhdpi"]=192
)

ANDROID_RES="$PROJECT_DIR/android/app/src/main/res"

for dpi in "${!ANDROID_SIZES[@]}"; do
  size="${ANDROID_SIZES[$dpi]}"
  dir="$ANDROID_RES/mipmap-$dpi"
  mkdir -p "$dir"

  # Generate PNG first
  convert "$TMP_DIR/icon_src.png" -resize "${size}x${size}" "$TMP_DIR/ic_${dpi}.png"

  # Convert to WebP
  if command -v cwebp &>/dev/null; then
    cwebp -q 90 "$TMP_DIR/ic_${dpi}.png" -o "$dir/ic_launcher.webp" 2>/dev/null
    cwebp -q 90 "$TMP_DIR/ic_${dpi}.png" -o "$dir/ic_launcher_round.webp" 2>/dev/null
  else
    convert "$TMP_DIR/ic_${dpi}.png" "$dir/ic_launcher.webp"
    convert "$TMP_DIR/ic_${dpi}.png" "$dir/ic_launcher_round.webp"
  fi
done

# Generate banner for xhdpi (320x180)
convert "$TMP_DIR/icon_src.png" -resize 320x180 -gravity center -background none -extent 320x180 \
  "$ANDROID_RES/mipmap-xhdpi/ic_banner.png"

echo "==> Generating Windows icon..."
WINDOWS_RES="$PROJECT_DIR/windows/runner/resources"
mkdir -p "$WINDOWS_RES"
convert "$TMP_DIR/icon_src.png" \
  \( -clone 0 -resize 16x16 \) \
  \( -clone 0 -resize 32x32 \) \
  \( -clone 0 -resize 48x48 \) \
  \( -clone 0 -resize 64x64 \) \
  \( -clone 0 -resize 128x128 \) \
  \( -clone 0 -resize 256x256 \) \
  -delete 0 "$WINDOWS_RES/app_icon.ico"

echo "==> Generating macOS icon set..."
MACOS_ICONSET="$PROJECT_DIR/macos/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$MACOS_ICONSET"

for size in 16 32 64 128 256 512 1024; do
  convert "$TMP_DIR/icon_src.png" -resize "${size}x${size}" "$MACOS_ICONSET/app_icon_${size}.png"
done

echo "==> Generating Linux icon (already at assets/images/icon.png)..."
# Linux packaging configs already reference ./assets/images/icon.png

echo "==> All platform icons generated successfully!"
