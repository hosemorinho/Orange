#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LEAF_DIR="$ROOT_DIR/leaf"
IOS_FRAMEWORKS_DIR="$ROOT_DIR/ios/Frameworks"

echo "[iOS] Building leaf.xcframework..."
cd "$LEAF_DIR"
bash scripts/build_apple_xcframework.sh

mkdir -p "$IOS_FRAMEWORKS_DIR"
rm -rf "$IOS_FRAMEWORKS_DIR/leaf.xcframework"
cp -R "$LEAF_DIR/target/apple/release/leaf.xcframework" "$IOS_FRAMEWORKS_DIR/"

echo "[iOS] leaf.xcframework copied to ios/Frameworks/leaf.xcframework"
