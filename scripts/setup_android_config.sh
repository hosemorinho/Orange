#!/bin/bash
# Setup Android Configuration from Environment Variables
# Designed for CI/CD environments - non-interactive

set -e

ANDROID_DIR="$(cd "$(dirname "$0")/.." && pwd)/android"
OLD_PACKAGE="com.follow.clash"

# Read configuration from environment or use defaults
# Trim whitespace/newlines from environment variables (matching setup.dart behavior)
NEW_PACKAGE=$(echo "${APP_PACKAGE_NAME:-com.follow.clash}" | tr -d '[:space:]')
APP_NAME=$(echo "${APP_NAME:-Orange}" | xargs)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Android Configuration Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Configuration:"
echo "  APP_NAME: $APP_NAME"
echo "  APP_PACKAGE_NAME: $NEW_PACKAGE"
echo ""

# Update strings.xml with app name
STRINGS_XML="$ANDROID_DIR/app/src/main/res/values/strings.xml"
if [ -f "$STRINGS_XML" ]; then
    echo "Updating app_name in strings.xml..."
    sed -i "s|<string name=\"app_name\">.*</string>|<string name=\"app_name\">$APP_NAME</string>|g" "$STRINGS_XML"
    sed -i "s|<string name=\"app_name_debug\">.*</string>|<string name=\"app_name_debug\">$APP_NAME Debug</string>|g" "$STRINGS_XML"
    echo "✓ Updated app name in strings.xml"
fi

# Only refactor package if it's different
if [ "$OLD_PACKAGE" != "$NEW_PACKAGE" ]; then
    echo ""
    echo "Package name change detected, refactoring..."
    echo "  From: $OLD_PACKAGE"
    echo "  To:   $NEW_PACKAGE"
    echo ""

    # Convert package names to paths
    OLD_PATH="${OLD_PACKAGE//./\/}"
    NEW_PATH="${NEW_PACKAGE//./\/}"

    # Update all source files
    echo "Updating source file contents..."
    # Escape special characters for sed
    OLD_PACKAGE_ESCAPED="${OLD_PACKAGE//./\\.}"
    NEW_PACKAGE_ESCAPED=$(printf '%s\n' "$NEW_PACKAGE" | sed 's/[&/\]/\\&/g')
    find "$ANDROID_DIR" -type f \( -name "*.kt" -o -name "*.java" -o -name "*.aidl" -o -name "*.kts" -o -name "AndroidManifest.xml" \) -exec sed -i "s|${OLD_PACKAGE_ESCAPED}|${NEW_PACKAGE_ESCAPED}|g" {} +
    echo "✓ Updated source files"

    # NOTE:
    # android/core/src/main/cpp/core.cpp contains hard-coded JNI symbol names
    # (Java_com_follow_clash_core_...) and class paths (com/follow/clash/core/*).
    # When package is refactored, these native bindings must be updated too,
    # otherwise Core.invokeAction / quickSetup can throw UnsatisfiedLinkError at
    # runtime and lead to remote service disconnects.
    echo "Synchronizing core JNI symbols..."
    CORE_CPP="$ANDROID_DIR/core/src/main/cpp/core.cpp"
    if [ -f "$CORE_CPP" ]; then
        OLD_PACKAGE_JNI="${OLD_PACKAGE//./_}"
        NEW_PACKAGE_JNI="${NEW_PACKAGE//./_}"
        OLD_PACKAGE_SLASH="${OLD_PACKAGE//./\/}"
        NEW_PACKAGE_SLASH="${NEW_PACKAGE//./\/}"

        sed -i "s|Java_${OLD_PACKAGE_JNI}_core_Core_|Java_${NEW_PACKAGE_JNI}_core_Core_|g" "$CORE_CPP"
        sed -i "s|${OLD_PACKAGE_SLASH}/core/TunInterface|${NEW_PACKAGE_SLASH}/core/TunInterface|g" "$CORE_CPP"
        sed -i "s|${OLD_PACKAGE_SLASH}/core/InvokeInterface|${NEW_PACKAGE_SLASH}/core/InvokeInterface|g" "$CORE_CPP"
        echo "✓ Synchronized JNI symbols in core.cpp"
    else
        echo "⚠ core.cpp not found, skipped JNI symbol synchronization"
    fi

    # Move package directories
    echo ""
    echo "Renaming package directories..."
    for module in app service common core; do
        module_dir="$ANDROID_DIR/$module"
        if [ ! -d "$module_dir" ]; then
            continue
        fi

        for src_type in java kotlin aidl; do
            base_dir="$module_dir/src/main/$src_type"
            if [ ! -d "$base_dir" ]; then
                continue
            fi

            old_dir="$base_dir/$OLD_PATH"
            new_dir="$base_dir/$NEW_PATH"

            if [ -d "$old_dir" ]; then
                echo "  Moving: $module/src/main/$src_type/$OLD_PATH"
                mkdir -p "$(dirname "$new_dir")"
                mv "$old_dir" "$new_dir"

                # Clean up empty directories
                parent_dir="$(dirname "$old_dir")"
                while [ "$parent_dir" != "$base_dir" ] && [ -d "$parent_dir" ] && [ -z "$(ls -A "$parent_dir")" ]; do
                    rmdir "$parent_dir"
                    parent_dir="$(dirname "$parent_dir")"
                done
            fi
        done
    done
    echo "✓ Renamed package directories"

    # Verify
    remaining=$(grep -r "${OLD_PACKAGE}" "$ANDROID_DIR" --include="*.kt" --include="*.java" --include="*.aidl" --include="*.kts" --include="*.xml" 2>/dev/null | wc -l || echo 0)
    new_refs=$(grep -r "${NEW_PACKAGE}" "$ANDROID_DIR" --include="*.kt" --include="*.java" --include="*.aidl" --include="*.kts" --include="*.xml" 2>/dev/null | wc -l || echo 0)

    echo ""
    echo "Verification:"
    echo "  Remaining old refs: $remaining"
    echo "  New package refs: $new_refs"

    if [ "$remaining" -gt 0 ]; then
        echo "⚠ Warning: Some old package references may remain"
    else
        echo "✓ Package refactoring completed successfully"
    fi
else
    echo "Package name unchanged, skipping refactoring"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Android configuration setup completed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Sanity check for JNI binding consistency
if [ "$OLD_PACKAGE" != "$NEW_PACKAGE" ]; then
    CORE_CPP="$ANDROID_DIR/core/src/main/cpp/core.cpp"
    NEW_PACKAGE_JNI="${NEW_PACKAGE//./_}"
    if [ -f "$CORE_CPP" ]; then
        if ! grep -q "Java_${NEW_PACKAGE_JNI}_core_Core_" "$CORE_CPP"; then
            echo "✗ JNI symbols not updated correctly in core.cpp"
            exit 1
        fi
    fi
fi
