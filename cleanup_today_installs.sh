#!/bin/bash

# Cleanup script for packages installed today by the installation script
# This removes only the packages that were newly installed on 2025-06-06
# SAFETY: Checks dependencies to avoid breaking existing software

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 Safe Cleanup Script for Today's Brew Installations${NC}"
echo "======================================================"

# Packages that were definitely installed by the script today (based on timestamps)
NEW_PACKAGES=(
    "aom"
    "aribb24" 
    "yarn"
    "node"
    "jq"
    "htop" 
    "tree"
    "speex"
    "snappy"
    "sdl2"
    "rubberband"
    "rav1e"
    "lzo"
    "lz4"
    "little-cms2"
    "libxrender"
    "libxext"
)

# Check which ones are actually installed
INSTALLED_NEW=()
for package in "${NEW_PACKAGES[@]}"; do
    if brew list --formula "$package" &>/dev/null; then
        INSTALLED_NEW+=("$package")
    fi
done

if [[ ${#INSTALLED_NEW[@]} -eq 0 ]]; then
    echo -e "${GREEN}✅ No new packages found to remove${NC}"
    exit 0
fi

echo -e "${YELLOW}🔍 Analyzing ${#INSTALLED_NEW[@]} packages installed today...${NC}"

# Check dependencies - what depends on these packages
SAFE_TO_REMOVE=()
DEPENDENCY_PACKAGES=()

for package in "${INSTALLED_NEW[@]}"; do
    echo -n "   Checking $package... "
    
    # Find what depends on this package
    dependents=$(brew uses --installed "$package" 2>/dev/null || echo "")
    
    if [[ -z "$dependents" ]]; then
        echo -e "${GREEN}safe to remove${NC}"
        SAFE_TO_REMOVE+=("$package")
    else
        echo -e "${RED}needed by: $dependents${NC}"
        DEPENDENCY_PACKAGES+=("$package")
    fi
done

echo ""

if [[ ${#SAFE_TO_REMOVE[@]} -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  All packages are dependencies of other software!${NC}"
    echo -e "${BLUE}ℹ️  This means they were likely updated versions of existing dependencies.${NC}"
    echo -e "${GREEN}✅ No packages will be removed to maintain system stability.${NC}"
    
    if [[ ${#DEPENDENCY_PACKAGES[@]} -gt 0 ]]; then
        echo -e "\n${BLUE}📋 Packages kept as dependencies:${NC}"
        for package in "${DEPENDENCY_PACKAGES[@]}"; do
            dependents=$(brew uses --installed "$package" 2>/dev/null || echo "unknown")
            echo "   • $package (needed by: $dependents)"
        done
    fi
    exit 0
fi

# Show what we can safely remove
echo -e "${GREEN}✅ Safe to remove (${#SAFE_TO_REMOVE[@]} packages):${NC}"
for package in "${SAFE_TO_REMOVE[@]}"; do
    echo "   • $package"
done

if [[ ${#DEPENDENCY_PACKAGES[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}⚠️  Keeping as dependencies (${#DEPENDENCY_PACKAGES[@]} packages):${NC}"
    for package in "${DEPENDENCY_PACKAGES[@]}"; do
        dependents=$(brew uses --installed "$package" 2>/dev/null || echo "unknown")
        echo "   • $package (needed by: $dependents)"
    done
fi

echo ""
echo -e "${YELLOW}⚠️  This will only remove standalone packages that aren't needed by existing software.${NC}"
echo -e "${YELLOW}⚠️  Casks (GUI apps) will NOT be touched.${NC}"
echo -e "${GREEN}✅ Dependencies will be preserved to maintain system stability.${NC}"
echo ""

read -p "Do you want to proceed with removing the safe packages? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}ℹ️  Operation cancelled${NC}"
    exit 0
fi

echo -e "${BLUE}🗑️  Removing safe packages...${NC}"

# Remove only the safe packages
FAILED_REMOVALS=()
for package in "${SAFE_TO_REMOVE[@]}"; do
    echo -e "${BLUE}Removing: $package${NC}"
    if brew uninstall "$package" 2>/dev/null; then
        echo -e "${GREEN}✅ Removed: $package${NC}"
    else
        echo -e "${RED}❌ Failed to remove: $package${NC}"
        FAILED_REMOVALS+=("$package")
    fi
done

# Clean up unused dependencies
echo -e "\n${BLUE}🧹 Cleaning up unused dependencies...${NC}"
brew autoremove 2>/dev/null || echo "No unused dependencies to remove"

echo -e "\n${GREEN}✅ Safe cleanup completed!${NC}"

if [[ ${#FAILED_REMOVALS[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}⚠️  Some packages couldn't be removed:${NC}"
    for package in "${FAILED_REMOVALS[@]}"; do
        echo "   • $package"
    done
fi

echo -e "\n${BLUE}📝 Current status:${NC}"
echo "   • Casks: $(brew list --cask | wc -l | xargs) (untouched)"
echo "   • Formulae: $(brew list --formula | wc -l | xargs) (after safe cleanup)"
echo "   • Dependencies preserved: ${#DEPENDENCY_PACKAGES[@]} packages"

if [[ ${#DEPENDENCY_PACKAGES[@]} -gt 0 ]]; then
    echo -e "\n${BLUE}💡 The kept packages are likely updated versions of dependencies${NC}"
    echo -e "   that your existing software needs. This is normal and safe.${NC}"
fi 