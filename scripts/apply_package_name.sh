#!/bin/bash
set -e

# Apply Package Name from Environment Variable
# This script reads APP_PACKAGE_NAME from environment and refactors Android code

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Apply Android Package Name from Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

OLD_PACKAGE="com.follow.clash"
ANDROID_DIR="$(cd "$(dirname "$0")/.." && pwd)/android"

# Try to read package name from different sources
NEW_PACKAGE=""

# 1. Try environment variable
if [ -n "$APP_PACKAGE_NAME" ]; then
    NEW_PACKAGE="$APP_PACKAGE_NAME"
    echo -e "${GREEN}✓${NC} Found APP_PACKAGE_NAME in environment: $NEW_PACKAGE"
fi

# 2. Try env.json if exists
if [ -z "$NEW_PACKAGE" ] && [ -f "env.json" ]; then
    if command -v jq &> /dev/null; then
        ENV_PKG=$(jq -r '.APP_PACKAGE_NAME // empty' env.json 2>/dev/null)
        if [ -n "$ENV_PKG" ]; then
            NEW_PACKAGE="$ENV_PKG"
            echo -e "${GREEN}✓${NC} Found APP_PACKAGE_NAME in env.json: $NEW_PACKAGE"
        fi
    fi
fi

# 3. Try command line argument
if [ -z "$NEW_PACKAGE" ] && [ -n "$1" ]; then
    NEW_PACKAGE="$1"
    echo -e "${GREEN}✓${NC} Using package name from argument: $NEW_PACKAGE"
fi

# 4. Use default
if [ -z "$NEW_PACKAGE" ]; then
    NEW_PACKAGE="$OLD_PACKAGE"
    echo -e "${YELLOW}⚠${NC} No package name specified, using default: $NEW_PACKAGE"
fi

# Validate package name
if [[ ! "$NEW_PACKAGE" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    echo -e "${RED}✗ Error: Invalid package name format: $NEW_PACKAGE${NC}"
    echo "  Package name must match pattern: com.example.app"
    exit 1
fi

if [ "$OLD_PACKAGE" == "$NEW_PACKAGE" ]; then
    echo -e "${YELLOW}⚠ Package name unchanged, skipping refactoring${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Old package: ${RED}$OLD_PACKAGE${NC}"
echo -e "  New package: ${GREEN}$NEW_PACKAGE${NC}"
echo -e "  Android dir: $ANDROID_DIR"
echo ""

# Call the main refactoring script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/refactor_package_name.sh" ]; then
    bash "$SCRIPT_DIR/refactor_package_name.sh" "$NEW_PACKAGE"
else
    echo -e "${RED}✗ Error: refactor_package_name.sh not found${NC}"
    exit 1
fi
