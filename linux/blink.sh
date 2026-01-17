#!/bin/bash
# Blink App - Linux Eye Rest Reminder Launcher

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the Python application detached from terminal
nohup python3 "$SCRIPT_DIR/blink-app.py" > /dev/null 2>&1 &

# Store the PID for potential future management
echo $! > "$HOME/.blink-app.pid"
exit 0