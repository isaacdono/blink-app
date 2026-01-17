#!/bin/bash
# Setup script for Blink App - Eye Rest Reminder

set -e

echo "🔧 Setting up Blink App - Eye Rest Reminder..."

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make scripts executable
chmod +x "$SCRIPT_DIR/blink.sh"
chmod +x "$SCRIPT_DIR/blink-app.py"

echo "✓ Made scripts executable"

# Check for required dependencies
echo "📦 Checking dependencies..."

MISSING_DEPS=()

# Check for xprintidle (X11 idle time detection)
if ! command -v xprintidle &> /dev/null; then
    MISSING_DEPS+=("xprintidle")
fi

# Check for notify-send (notifications)
if ! command -v notify-send &> /dev/null; then
    MISSING_DEPS+=("libnotify-bin")
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    MISSING_DEPS+=("python3")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "⚠️  Missing dependencies detected:"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "   - $dep"
    done
    
    echo ""
    echo "To install on Ubuntu/Debian:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install ${MISSING_DEPS[@]}"
    echo ""
    echo "To install on Fedora/RHEL:"
    echo "  sudo dnf install ${MISSING_DEPS[@]}"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✓ All dependencies found"
fi

# Install autostart entry
AUTOSTART_DIR="$HOME/.config/autostart"
if [ ! -d "$AUTOSTART_DIR" ]; then
    mkdir -p "$AUTOSTART_DIR"
    echo "✓ Created autostart directory"
fi

# Create or update the desktop entry with correct paths
cat > "$AUTOSTART_DIR/blink-app.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Blink - Eye Rest Reminder
Comment=20/20/20 Eye Rest Reminder - Reminds you to rest your eyes every 20 minutes
Exec=python3 $SCRIPT_DIR/blink-app.py
Icon=eye
Categories=Utility;Health;
Terminal=false
Hidden=false
StartupNotify=false

X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel
EOF

echo "✓ Installed autostart entry to: $AUTOSTART_DIR/blink-app.desktop"

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the app now, run:"
echo "  $SCRIPT_DIR/blink.sh"
echo ""
echo "Or to run directly:"
echo "  python3 $SCRIPT_DIR/blink-app.py"
echo ""
echo "The app will now start automatically on the next boot."
echo ""
echo "To disable autostart:"
echo "  rm $AUTOSTART_DIR/blink-app.desktop"
