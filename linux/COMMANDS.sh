#!/bin/bash
# BLINK APP - COMMAND REFERENCE CARD
# Quick reference for all common commands

cat << 'EOF'

╔═══════════════════════════════════════════════════════════════════╗
║         BLINK APP - LINUX 20/20/20 EYE REST REMINDER              ║
║                    QUICK COMMAND REFERENCE                        ║
╚═══════════════════════════════════════════════════════════════════╝

📍 LOCATION: ~/Documents/blink-app/linux/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 SETUP & INSTALLATION

  Install Dependencies (Ubuntu/Debian):
    sudo apt-get update && sudo apt-get install python3 libnotify-bin xprintidle

  Install Dependencies (Fedora/RHEL):
    sudo dnf install python3 libnotify zenity xprintidle

  Run Setup Script (Automated):
    cd ~/Documents/blink-app/linux && bash setup.sh

  Manual Setup:
    chmod +x ~/Documents/blink-app/linux/{blink.sh,blink-app.py,setup.sh}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶️  RUNNING THE APP

  Start Directly:
    python3 ~/Documents/blink-app/linux/blink-app.py

  Start in Background:
    ~/Documents/blink-app/linux/blink.sh &

  Start with Nohup (survives logout):
    nohup python3 ~/Documents/blink-app/linux/blink-app.py &

  Start with Output Logging:
    python3 ~/Documents/blink-app/linux/blink-app.py 2>&1 | tee ~/blink-app.log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏹️  STOPPING THE APP

  Kill by Name:
    pkill -f "python3.*blink-app"

  Kill by PID:
    kill $(cat ~/.blink-app.pid)

  Kill All Python Processes (CAUTION!):
    pkill python3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧪 TESTING & VALIDATION

  Run All Tests:
    bash ~/Documents/blink-app/linux/test.sh

  Test Notifications:
    notify-send "Test Notification" "If you see this, it works!"

  Test Screen Idle Detection:
    xprintidle

  Check Python Version:
    python3 --version

  Check Dependencies:
    which python3 notify-send xprintidle

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔌 AUTO-START MANAGEMENT

  Enable Auto-Start (Desktop Entry):
    bash ~/Documents/blink-app/linux/setup.sh  # Automatic

  View Auto-Start Entry:
    cat ~/.config/autostart/blink-app.desktop

  Disable Auto-Start (Desktop Entry):
    rm ~/.config/autostart/blink-app.desktop

  Enable Auto-Start (Systemd):
    mkdir -p ~/.config/systemd/user
    cp ~/Documents/blink-app/linux/blink-app.service ~/.config/systemd/user/
    systemctl --user enable blink-app.service
    systemctl --user start blink-app.service

  Disable Auto-Start (Systemd):
    systemctl --user disable blink-app.service
    systemctl --user stop blink-app.service

  Check Systemd Status:
    systemctl --user status blink-app.service

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📖 DOCUMENTATION

  Quick Start (5 min):
    cat ~/Documents/blink-app/linux/QUICKSTART.md

  Full Overview:
    cat ~/Documents/blink-app/linux/START_HERE.md

  Complete Reference:
    cat ~/Documents/blink-app/linux/README.md

  Technical Details:
    cat ~/Documents/blink-app/linux/IMPLEMENTATION.md

  File Directory:
    cat ~/Documents/blink-app/linux/INDEX.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️  CUSTOMIZATION

  Change Reminder Interval:
    # Edit blink-app.py and change line 20:
    # INTERVAL_SECONDS = 20 * 60  (change 20 to desired minutes)
    nano ~/Documents/blink-app/linux/blink-app.py

  Change Notification Duration:
    # Edit blink-app.py and change line 22:
    # NOTIFICATION_DURATION = 20  (change 20 to desired seconds)
    nano ~/Documents/blink-app/linux/blink-app.py

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 TROUBLESHOOTING

  No Notifications?
    1. Check notify-send: which notify-send
    2. Install if missing: sudo apt install libnotify-bin
    3. Test: notify-send "Test" "Test message"

  Screen Detection Not Working?
    1. Check xprintidle: which xprintidle
    2. Install if missing: sudo apt install x11-utils
    3. Test: xprintidle

  App Won't Auto-Start?
    1. Check entry exists: cat ~/.config/autostart/blink-app.desktop
    2. Verify path in entry matches your setup
    3. Check GNOME Settings: Settings → Details → Startup Apps

  High CPU Usage?
    1. Restart the app: pkill -f blink-app
    2. Run fresh: python3 ~/Documents/blink-app/linux/blink-app.py

  App Crashes?
    1. Verify Python: python3 --version
    2. Run test: bash ~/Documents/blink-app/linux/test.sh
    3. Check logs: python3 ~/Documents/blink-app/linux/blink-app.py 2>&1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 SYSTEM INFO

  View System Status:
    systemctl --user status blink-app.service

  View Logs:
    journalctl --user -u blink-app.service -f

  Check Running Processes:
    ps aux | grep blink-app

  Monitor Resource Usage:
    top -p $(pgrep -f "python3.*blink-app")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 FILE LISTING

  List All Files:
    ls -lah ~/Documents/blink-app/linux/

  View File Sizes:
    du -h ~/Documents/blink-app/linux/*

  Count Total Files:
    ls -1 ~/Documents/blink-app/linux/ | wc -l

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 USEFUL ONE-LINERS

  Check if app is running:
    pgrep -f "python3.*blink-app" && echo "Running" || echo "Not running"

  Get app PID:
    pgrep -f "python3.*blink-app"

  Count how long app has been running:
    ps -p $(pgrep -f "python3.*blink-app") -o etime=

  Monitor app in real-time:
    watch -n 1 'pgrep -f blink-app && echo "Running" || echo "Stopped"'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ QUICK START CHECKLIST

  □ Install dependencies
  □ Run setup.sh
  □ Run test.sh
  □ Start the app
  □ Wait 20 minutes
  □ See notification
  □ Rest your eyes! 👀

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For complete information, see the README.md in the app directory.

EOF
