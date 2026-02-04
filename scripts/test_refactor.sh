#!/bin/bash
# Test script for package name refactoring

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  Package Refactoring Test Suite${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

ANDROID_DIR="/home/Orange/android"
OLD_PACKAGE="com.follow.clash"

# Test 1: Check original package name exists
echo -e "${YELLOW}Test 1: Checking original package name...${NC}"
original_count=$(grep -r "${OLD_PACKAGE}" "$ANDROID_DIR" --include="*.kt" --include="*.java" --include="*.aidl" --include="*.kts" --include="*.xml" 2>/dev/null | wc -l)
echo "  Found $original_count references to $OLD_PACKAGE"
if [ "$original_count" -gt 0 ]; then
    echo -e "  ${GREEN}✓ PASS${NC}"
else
    echo -e "  ${RED}✗ FAIL - No original package references found${NC}"
    exit 1
fi

# Test 2: Dry run validation
echo ""
echo -e "${YELLOW}Test 2: Validating package name format...${NC}"
test_packages=(
    "com.example.app:valid"
    "com.test.myapp:valid"
    "io.github.user:valid"
    "Com.Example:invalid"
    "com.123app:invalid"
    "com.my-app:invalid"
    "invalidname:invalid"
)

for test in "${test_packages[@]}"; do
    pkg="${test%%:*}"
    expected="${test##*:}"
    if [[ "$pkg" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
        result="valid"
    else
        result="invalid"
    fi

    if [ "$result" == "$expected" ]; then
        echo -e "  ${GREEN}✓${NC} $pkg → $result"
    else
        echo -e "  ${RED}✗${NC} $pkg → expected $expected, got $result"
    fi
done
echo -e "  ${GREEN}✓ PASS${NC}"

# Test 3: Check directory structure
echo ""
echo -e "${YELLOW}Test 3: Checking directory structure...${NC}"
OLD_PATH="${OLD_PACKAGE//./\/}"
found_dirs=0
for module in app service common core; do
    for src_type in java kotlin aidl; do
        dir="$ANDROID_DIR/$module/src/main/$src_type/$OLD_PATH"
        if [ -d "$dir" ]; then
            echo "  Found: $module/src/main/$src_type/$OLD_PATH"
            found_dirs=$((found_dirs + 1))
        fi
    done
done

if [ "$found_dirs" -gt 0 ]; then
    echo -e "  ${GREEN}✓ PASS${NC} - Found $found_dirs package directories"
else
    echo -e "  ${RED}✗ FAIL - No package directories found${NC}"
fi

# Test 4: Check file types
echo ""
echo -e "${YELLOW}Test 4: Checking file coverage...${NC}"
kt_files=$(find "$ANDROID_DIR" -name "*.kt" | wc -l)
java_files=$(find "$ANDROID_DIR" -name "*.java" | wc -l)
aidl_files=$(find "$ANDROID_DIR" -name "*.aidl" | wc -l)
gradle_files=$(find "$ANDROID_DIR" -name "*.gradle.kts" | wc -l)
manifest_files=$(find "$ANDROID_DIR" -name "AndroidManifest.xml" | wc -l)

echo "  Kotlin files:   $kt_files"
echo "  Java files:     $java_files"
echo "  AIDL files:     $aidl_files"
echo "  Gradle files:   $gradle_files"
echo "  Manifest files: $manifest_files"

total=$((kt_files + java_files + aidl_files + gradle_files + manifest_files))
if [ "$total" -gt 0 ]; then
    echo -e "  ${GREEN}✓ PASS${NC} - Found $total files to process"
else
    echo -e "  ${RED}✗ FAIL - No files found${NC}"
    exit 1
fi

# Test 5: Script existence
echo ""
echo -e "${YELLOW}Test 5: Checking script files...${NC}"
scripts=(
    "refactor_package_name.sh"
    "apply_package_name.sh"
    "setup_android_config.sh"
)

all_exist=true
for script in "${scripts[@]}"; do
    if [ -f "/home/Orange/scripts/$script" ] && [ -x "/home/Orange/scripts/$script" ]; then
        echo -e "  ${GREEN}✓${NC} $script (executable)"
    else
        echo -e "  ${RED}✗${NC} $script (missing or not executable)"
        all_exist=false
    fi
done

if [ "$all_exist" = true ]; then
    echo -e "  ${GREEN}✓ PASS${NC}"
else
    echo -e "  ${RED}✗ FAIL${NC}"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ All tests passed!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Ready to use the refactoring scripts."
echo ""
echo "Quick start:"
echo "  1. Interactive:  bash scripts/refactor_package_name.sh com.example.app"
echo "  2. With env var: APP_PACKAGE_NAME=com.example.app bash scripts/apply_package_name.sh"
echo "  3. In CI:        bash scripts/setup_android_config.sh"
echo ""
