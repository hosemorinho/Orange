#!/bin/bash
set -e

# Android Package Name Refactoring Script
# This script refactors the Android package name from com.follow.clash to a new package name

OLD_PACKAGE="com.follow.clash"
NEW_PACKAGE="${1:-com.follow.clash}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Android Package Name Refactoring Script${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Validate new package name
if [[ ! "$NEW_PACKAGE" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    echo -e "${RED}Error: Invalid package name format: $NEW_PACKAGE${NC}"
    echo "Package name must be in format: com.example.app"
    exit 1
fi

if [ "$OLD_PACKAGE" == "$NEW_PACKAGE" ]; then
    echo -e "${YELLOW}Warning: New package name is the same as old package name${NC}"
    echo "Nothing to do."
    exit 0
fi

echo -e "${YELLOW}Old package:${NC} $OLD_PACKAGE"
echo -e "${YELLOW}New package:${NC} $NEW_PACKAGE"
echo ""

# Ask for confirmation
read -p "Continue with refactoring? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

ANDROID_DIR="/home/Orange/android"

echo ""
echo -e "${GREEN}Step 1: Creating backup...${NC}"
BACKUP_DIR="/tmp/android_backup_$(date +%Y%m%d_%H%M%S)"
cp -r "$ANDROID_DIR" "$BACKUP_DIR"
echo -e "  ✓ Backup created at: $BACKUP_DIR"

echo ""
echo -e "${GREEN}Step 2: Updating source files...${NC}"

# Convert package names to paths
OLD_PATH="${OLD_PACKAGE//./\/}"
NEW_PATH="${NEW_PACKAGE//./\/}"

# Function to update file content
update_file_content() {
    local file="$1"
    if [ -f "$file" ]; then
        # Use sed to replace package name in file content
        sed -i "s/${OLD_PACKAGE//./\\.}/${NEW_PACKAGE}/g" "$file"
        echo -e "  ${GREEN}✓${NC} Updated: $(basename $file)"
    fi
}

# Update all Kotlin files
echo -e "${YELLOW}  → Updating Kotlin files...${NC}"
while IFS= read -r file; do
    update_file_content "$file"
done < <(find "$ANDROID_DIR" -name "*.kt" -type f)

# Update all Java files
echo -e "${YELLOW}  → Updating Java files...${NC}"
while IFS= read -r file; do
    update_file_content "$file"
done < <(find "$ANDROID_DIR" -name "*.java" -type f)

# Update all AIDL files
echo -e "${YELLOW}  → Updating AIDL files...${NC}"
while IFS= read -r file; do
    update_file_content "$file"
done < <(find "$ANDROID_DIR" -name "*.aidl" -type f)

# Update all build.gradle.kts files
echo -e "${YELLOW}  → Updating build.gradle.kts files...${NC}"
while IFS= read -r file; do
    update_file_content "$file"
done < <(find "$ANDROID_DIR" -name "*.gradle.kts" -type f)

# Update all AndroidManifest.xml files
echo -e "${YELLOW}  → Updating AndroidManifest.xml files...${NC}"
while IFS= read -r file; do
    update_file_content "$file"
done < <(find "$ANDROID_DIR" -name "AndroidManifest.xml" -type f)

# Update google-services.json if exists
if [ -f "$ANDROID_DIR/app/google-services.json" ]; then
    echo -e "${YELLOW}  → Updating google-services.json...${NC}"
    update_file_content "$ANDROID_DIR/app/google-services.json"
fi

echo ""
echo -e "${GREEN}Step 3: Renaming package directories...${NC}"

# Function to move directory structure
move_package_dirs() {
    local base_dir="$1"
    local old_dir="$base_dir/$OLD_PATH"
    local new_dir="$base_dir/$NEW_PATH"

    if [ -d "$old_dir" ]; then
        echo -e "  ${YELLOW}→${NC} Moving: $old_dir"

        # Create new directory structure
        mkdir -p "$(dirname "$new_dir")"

        # Move the directory
        mv "$old_dir" "$new_dir"

        # Clean up empty parent directories
        local parent_dir="$(dirname "$old_dir")"
        while [ "$parent_dir" != "$base_dir" ] && [ -d "$parent_dir" ] && [ -z "$(ls -A "$parent_dir")" ]; do
            rmdir "$parent_dir"
            parent_dir="$(dirname "$parent_dir")"
        done

        echo -e "  ${GREEN}✓${NC} Moved to: $new_dir"
    fi
}

# Move package directories in all modules
for module in app service common core; do
    module_dir="$ANDROID_DIR/$module"
    if [ -d "$module_dir" ]; then
        echo -e "${YELLOW}  Module: $module${NC}"

        # Move src/main/java directories
        if [ -d "$module_dir/src/main/java" ]; then
            move_package_dirs "$module_dir/src/main/java"
        fi

        # Move src/main/kotlin directories
        if [ -d "$module_dir/src/main/kotlin" ]; then
            move_package_dirs "$module_dir/src/main/kotlin"
        fi

        # Move src/main/aidl directories
        if [ -d "$module_dir/src/main/aidl" ]; then
            move_package_dirs "$module_dir/src/main/aidl"
        fi
    fi
done

echo ""
echo -e "${GREEN}Step 4: Verifying changes...${NC}"

# Check if old package name still exists in files
remaining=$(grep -r "${OLD_PACKAGE}" "$ANDROID_DIR" --include="*.kt" --include="*.java" --include="*.aidl" --include="*.kts" --include="*.xml" 2>/dev/null | wc -l)

if [ "$remaining" -gt 0 ]; then
    echo -e "${YELLOW}Warning: Found $remaining remaining references to old package name${NC}"
    echo "Files with remaining references:"
    grep -r "${OLD_PACKAGE}" "$ANDROID_DIR" --include="*.kt" --include="*.java" --include="*.aidl" --include="*.kts" --include="*.xml" -l 2>/dev/null | head -10
else
    echo -e "  ${GREEN}✓${NC} All references updated successfully"
fi

# Count new package references
new_refs=$(grep -r "${NEW_PACKAGE}" "$ANDROID_DIR" --include="*.kt" --include="*.java" --include="*.aidl" --include="*.kts" --include="*.xml" 2>/dev/null | wc -l)
echo -e "  ${GREEN}✓${NC} New package name appears in $new_refs locations"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Refactoring completed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Backup location:${NC} $BACKUP_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the changes with: git diff"
echo "  2. Test the build: flutter build apk"
echo "  3. If successful, commit: git add -A && git commit"
echo "  4. If failed, restore: rm -rf android && cp -r $BACKUP_DIR android"
echo ""
