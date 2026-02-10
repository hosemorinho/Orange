#!/usr/bin/env bash
set -eo pipefail

# Build leaf proxy core for Orange
# Usage:
#   ./scripts/build_leaf.sh android [arm64|arm|x86_64]
#   ./scripts/build_leaf.sh linux [amd64|arm64]
#   ./scripts/build_leaf.sh macos [arm64|amd64|universal]
#   ./scripts/build_leaf.sh windows [amd64]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LEAF_DIR="$PROJECT_DIR/leaf"
LEAF_FFI="leaf-ffi"

TARGET_PLATFORM="${1:?Usage: build_leaf.sh <android|linux|macos|windows> [arch]}"
ARCH="${2:-}"
MODE="${BUILD_MODE:---release}"
PROFILE="release"
if [ "$MODE" = "" ]; then
  PROFILE="debug"
fi

# Arch → Rust target mapping
declare -A ANDROID_TARGETS=(
  [arm64]="aarch64-linux-android"
  [arm]="armv7-linux-androideabi"
  [x86_64]="x86_64-linux-android"
)

declare -A ANDROID_JNI_DIRS=(
  [arm64]="arm64-v8a"
  [arm]="armeabi-v7a"
  [x86_64]="x86_64"
)

declare -A LINUX_TARGETS=(
  [amd64]="x86_64-unknown-linux-gnu"
  [arm64]="aarch64-unknown-linux-gnu"
)

declare -A MACOS_TARGETS=(
  [arm64]="aarch64-apple-darwin"
  [amd64]="x86_64-apple-darwin"
)

declare -A WINDOWS_TARGETS=(
  [amd64]="x86_64-pc-windows-msvc"
  [arm64]="aarch64-pc-windows-msvc"
)

build_android() {
  local arches=("${@}")
  if [ ${#arches[@]} -eq 0 ]; then
    arches=(arm64 arm x86_64)
  fi

  if [ -z "${NDK_HOME:-${ANDROID_NDK:-}}" ]; then
    echo "ERROR: NDK_HOME or ANDROID_NDK must be set" >&2
    exit 1
  fi
  NDK_HOME="${NDK_HOME:-$ANDROID_NDK}"

  local jni_base="$PROJECT_DIR/android/app/src/main/jniLibs"

  for arch in "${arches[@]}"; do
    local target="${ANDROID_TARGETS[$arch]}"
    local jni_dir="${ANDROID_JNI_DIRS[$arch]}"
    if [ -z "$target" ]; then
      echo "Unknown Android arch: $arch" >&2
      exit 1
    fi

    echo "==> Building leaf for Android $arch ($target)"
    rustup target add "$target"

    # Use leaf's own android build script for NDK toolchain setup
    cd "$LEAF_DIR"
    bash scripts/build_android.sh release "$target"

    # Copy .so to jniLibs
    local src="$LEAF_DIR/target/leaf-android-libs/libleaf-${target}.so"
    local dst="$jni_base/$jni_dir/libleaf.so"
    mkdir -p "$jni_base/$jni_dir"
    cp "$src" "$dst"
    echo "  Copied: $dst"
  done
}

build_desktop() {
  local platform="$1"
  local arch="$2"
  local -n target_map="$3"
  local target="${target_map[$arch]}"

  if [ -z "$target" ]; then
    echo "Unknown $platform arch: $arch" >&2
    exit 1
  fi

  echo "==> Building leaf for $platform $arch ($target)"
  rustup target add "$target"

  cd "$LEAF_DIR"
  cargo build -p "$LEAF_FFI" --target "$target" $MODE

  local ext
  case "$platform" in
    linux)  ext=".so" ;;
    macos)  ext=".dylib" ;;
    windows) ext=".dll" ;;
  esac

  local src="$LEAF_DIR/target/$target/$PROFILE/libleaf${ext}"
  if [ "$platform" = "windows" ]; then
    src="$LEAF_DIR/target/$target/$PROFILE/leaf${ext}"
  fi

  local out_dir="$PROJECT_DIR/libleaf/$platform"
  mkdir -p "$out_dir"
  local dst="$out_dir/libleaf${ext}"
  cp "$src" "$dst"
  echo "  Output: $dst"
}

build_macos_universal() {
  echo "==> Building leaf for macOS universal (arm64 + x86_64)"
  for arch in arm64 amd64; do
    local target="${MACOS_TARGETS[$arch]}"
    rustup target add "$target"
    cd "$LEAF_DIR"
    cargo build -p "$LEAF_FFI" --target "$target" $MODE
  done

  local out_dir="$PROJECT_DIR/libleaf/macos"
  mkdir -p "$out_dir"
  lipo -create \
    "$LEAF_DIR/target/aarch64-apple-darwin/$PROFILE/libleaf.dylib" \
    "$LEAF_DIR/target/x86_64-apple-darwin/$PROFILE/libleaf.dylib" \
    -output "$out_dir/libleaf.dylib"
  echo "  Output: $out_dir/libleaf.dylib (universal)"
}

case "$TARGET_PLATFORM" in
  android)
    if [ -n "$ARCH" ]; then
      build_android "$ARCH"
    else
      build_android
    fi
    ;;
  linux)
    ARCH="${ARCH:-amd64}"
    build_desktop linux "$ARCH" LINUX_TARGETS
    ;;
  macos)
    if [ "$ARCH" = "universal" ]; then
      build_macos_universal
    else
      ARCH="${ARCH:-arm64}"
      build_desktop macos "$ARCH" MACOS_TARGETS
    fi
    ;;
  windows)
    ARCH="${ARCH:-amd64}"
    build_desktop windows "$ARCH" WINDOWS_TARGETS
    ;;
  *)
    echo "Unknown platform: $TARGET_PLATFORM" >&2
    echo "Usage: build_leaf.sh <android|linux|macos|windows> [arch]" >&2
    exit 1
    ;;
esac

echo "==> Build complete!"
