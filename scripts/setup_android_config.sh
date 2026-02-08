#!/bin/bash
# Setup Android Configuration from Environment Variables
# Designed for CI/CD environments - non-interactive
#
# NOTE: Only the applicationId is changed (via dart-define in build.gradle.kts).
# Source code package (com.follow.clash) is NEVER renamed — doing so breaks
# JNI function names and find_class paths in native C++ code.

set -e

ANDROID_DIR="$(cd "$(dirname "$0")/.." && pwd)/android"
APP_NAME=$(echo "${APP_NAME:-FlClash}" | xargs)
APP_PACKAGE_NAME=$(echo "${APP_PACKAGE_NAME:-com.follow.clash}" | tr -d '[:space:]')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Android Configuration Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Configuration:"
echo "  APP_NAME:         $APP_NAME"
echo "  APP_PACKAGE_NAME: $APP_PACKAGE_NAME (applicationId only, source unchanged)"
echo ""

# Update strings.xml with app name
# FlClash uses android/common/src/main/res/values/strings.xml with key "FlClash"
STRINGS_XML="$ANDROID_DIR/common/src/main/res/values/strings.xml"
if [ -f "$STRINGS_XML" ]; then
    echo "Updating app name in strings.xml..."
    sed -i "s|<string name=\"FlClash\">.*</string>|<string name=\"FlClash\">$APP_NAME</string>|g" "$STRINGS_XML"
    echo "✓ Updated app name in strings.xml"
fi

# Replace hardcoded "FlClash" brand strings in Android native code
if [ "$APP_NAME" != "FlClash" ]; then
    echo "Replacing hardcoded brand strings..."
    find "$ANDROID_DIR" -type f \( -name "*.kt" -o -name "*.java" -o -name "AndroidManifest.xml" \) \
        -exec sed -i "s|\"FlClash\"|\"$APP_NAME\"|g" {} +
    echo "✓ Replaced brand strings"
fi

# applicationId is set via --dart-define=APP_PACKAGE_NAME in build.gradle.kts.
# No source code renaming needed.
if [ "$APP_PACKAGE_NAME" != "com.follow.clash" ]; then
    echo ""
    echo "Note: applicationId will be set to '$APP_PACKAGE_NAME' at build time via dart-define."
    echo "      Source code package remains 'com.follow.clash' (no renaming needed)."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Android configuration setup completed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
