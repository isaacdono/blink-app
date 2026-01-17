# Quick Start Guide - Blink App Linux

## 🚀 Get Started in 5 Minutes

### 1. Install Dependencies
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install python3 libnotify-bin xprintidle

# Fedora/RHEL
sudo dnf install python3 libnotify zenity xprintidle
```

### 2. Run Setup
```bash
cd ~/Documents/blink-app/linux
bash setup.sh
```

### 3. Start the App
```bash
# Option A: Run now
python3 ~/Documents/blink-app/linux/blink-app.py

# Option B: Run in background
~/Documents/blink-app/linux/blink.sh &

# Option C: Will auto-start on next login (from setup.sh)
```

### 4. Done! ✅
You'll see a notification every 20 minutes reminding you to rest your eyes.

## 📝 What Happens
- Every 20 minutes → Desktop notification appears
- Look at something 20 feet away → For 20 seconds
- Screen goes dark → Timer resets when screen wakes
- Screen wakes → Timer resets automatically

## ⚙️ Testing
```bash
# Test notifications work
notify-send "Test" "If you see this, notifications work!"

# Test screen idle detection
xprintidle
# (Should show time in milliseconds since last input)
```

## 🛑 Stop the App
```bash
pkill -f "python3.*blink-app.py"
```

## 📖 More Info
See `README.md` in this directory for complete documentation.
