#!/bin/bash
# Setup Android Configuration from Environment Variables
# Designed for CI/CD environments - non-interactive

set -e

ANDROID_DIR="$(cd "$(dirname "$0")/.." && pwd)/android"
OLD_PACKAGE="com.follow.clash"

# Read configuration from environment or use defaults
NEW_PACKAGE="${APP_PACKAGE_NAME:-com.follow.clash}"
APP_NAME="${APP_NAME:-FlClash}"

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
    find "$ANDROID_DIR" -type f \( -name "*.kt" -o -name "*.java" -o -name "*.aidl" -o -name "*.kts" -o -name "AndroidManifest.xml" \) -exec sed -i "s/${OLD_PACKAGE//./\\.}/${NEW_PACKAGE}/g" {} +
    echo "✓ Updated source files"

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
