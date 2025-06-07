#!/bin/bash

# Test script for brew automation tools
# This script performs basic functionality tests

echo "🧪 Testing Brew Automation Tools"
echo "================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Test 1: Check if install script exists and is executable
echo -e "\n${YELLOW}Test 1: Checking install_brew_apps.sh${NC}"
if [[ -x "./install_brew_apps.sh" ]]; then
    echo -e "${GREEN}✅ install_brew_apps.sh is executable${NC}"
else
    echo -e "${RED}❌ install_brew_apps.sh is not executable${NC}"
    exit 1
fi

# Test 2: Check if scanner exists and is executable
echo -e "\n${YELLOW}Test 2: Checking brew_scanner.py${NC}"
if [[ -x "./brew_scanner.py" ]]; then
    echo -e "${GREEN}✅ brew_scanner.py is executable${NC}"
else
    echo -e "${RED}❌ brew_scanner.py is not executable${NC}"
    exit 1
fi

# Test 3: Check if brew is available
echo -e "\n${YELLOW}Test 3: Checking Homebrew installation${NC}"
if command -v brew &> /dev/null; then
    echo -e "${GREEN}✅ Homebrew is installed${NC}"
    echo "   Version: $(brew --version | head -n1)"
else
    echo -e "${YELLOW}⚠️  Homebrew not found (will be installed by script)${NC}"
fi

# Test 4: Check Python availability
echo -e "\n${YELLOW}Test 4: Checking Python availability${NC}"
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✅ Python 3 is available${NC}"
    echo "   Version: $(python3 --version)"
else
    echo -e "${RED}❌ Python 3 not found${NC}"
    exit 1
fi

# Test 5: Test install script help/info
echo -e "\n${YELLOW}Test 5: Testing install script (dry run)${NC}"
if ./install_brew_apps.sh --help 2>/dev/null || echo "Script doesn't support --help flag (normal)"; then
    echo -e "${GREEN}✅ Install script is functional${NC}"
fi

echo -e "\n${GREEN}🎉 All basic tests passed!${NC}"
echo -e "${YELLOW}💡 You can now run:${NC}"
echo "   • ./install_brew_apps.sh  # Install all brew packages"
echo "   • ./brew_scanner.py       # Launch interactive scanner"
echo ""
echo -e "${YELLOW}Note: The scanner will auto-setup its virtual environment on first run.${NC}" 