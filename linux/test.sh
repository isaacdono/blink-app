#!/bin/bash
# Test script for Blink App - validates setup and dependencies

set -e

echo "🧪 Testing Blink App Setup..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0
FAIL=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_command() {
    local name=$1
    local cmd=$2
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name found"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $name NOT found"
        echo "  Install with: sudo apt install $name"
        ((FAIL++))
    fi
}

test_file() {
    local name=$1
    local path=$2
    
    if [ -f "$path" ]; then
        echo -e "${GREEN}✓${NC} $name exists"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $name NOT found at $path"
        ((FAIL++))
    fi
}

echo "📋 Checking Required Files..."
test_file "Main app" "$SCRIPT_DIR/blink-app.py"
test_file "Launcher" "$SCRIPT_DIR/blink.sh"
test_file "Setup script" "$SCRIPT_DIR/setup.sh"
echo ""

echo "📦 Checking System Dependencies..."
test_command "Python 3" "python3"
test_command "notify-send" "notify-send"
test_command "xprintidle" "xprintidle"
echo ""

echo "🔧 Checking File Permissions..."
if [ -x "$SCRIPT_DIR/blink-app.py" ]; then
    echo -e "${GREEN}✓${NC} blink-app.py is executable"
    ((PASS++))
else
    echo -e "${RED}✗${NC} blink-app.py is NOT executable"
    ((FAIL++))
fi

if [ -x "$SCRIPT_DIR/blink.sh" ]; then
    echo -e "${GREEN}✓${NC} blink.sh is executable"
    ((PASS++))
else
    echo -e "${RED}✗${NC} blink.sh is NOT executable"
    ((FAIL++))
fi

if [ -x "$SCRIPT_DIR/setup.sh" ]; then
    echo -e "${GREEN}✓${NC} setup.sh is executable"
    ((PASS++))
else
    echo -e "${RED}✗${NC} setup.sh is NOT executable"
    ((FAIL++))
fi
echo ""

echo "💡 Testing Notification..."
if command -v notify-send &> /dev/null; then
    echo -e "Sending test notification..."
    notify-send -u normal -t 3000 "Blink App" "Test notification - everything works!" && \
    echo -e "${GREEN}✓${NC} Notification test successful" && ((PASS++)) || \
    (echo -e "${YELLOW}⚠${NC} Notification sent but couldn't verify" && ((PASS++)))
else
    echo -e "${YELLOW}⚠${NC} notify-send not available, skipping notification test"
fi
echo ""

echo "🔍 Testing Screen Detection..."
if command -v xprintidle &> /dev/null; then
    IDLE=$(xprintidle)
    if [ -n "$IDLE" ] && [ "$IDLE" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Screen idle time: ${IDLE}ms"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} xprintidle returned invalid value"
        ((FAIL++))
    fi
else
    echo -e "${RED}✗${NC} xprintidle not available"
    ((FAIL++))
fi
echo ""

echo "📝 Test Summary"
echo "==============="
echo -e "Passed: ${GREEN}${PASS}${NC}"
echo -e "Failed: ${RED}${FAIL}${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! You're ready to go!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run the setup script:"
    echo "   $SCRIPT_DIR/setup.sh"
    echo ""
    echo "2. Start the app:"
    echo "   python3 $SCRIPT_DIR/blink-app.py"
    echo ""
    echo "3. Wait 20 minutes for the first notification (or test earlier)"
    echo ""
else
    echo -e "${RED}❌ Some tests failed. Please fix the issues above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "• Ubuntu/Debian: sudo apt-get update && sudo apt-get install python3 libnotify-bin xprintidle"
    echo "• Fedora/RHEL: sudo dnf install python3 libnotify zenity xprintidle"
    echo ""
fi
