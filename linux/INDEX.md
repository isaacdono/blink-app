# 📑 File Directory - Blink App Linux

Complete file listing and descriptions for the 20/20/20 Eye Rest Reminder.

## 📂 File Manifest

### 🚀 Getting Started (Read These First!)
- **`START_HERE.md`** - **👈 START WITH THIS** - Overview and quick start guide
- **`QUICKSTART.md`** - 5-minute setup instructions for the impatient

### 📚 Documentation
- **`README.md`** - Complete reference guide with all options and troubleshooting
- **`IMPLEMENTATION.md`** - Technical implementation details
- **`INDEX.md`** - This file - directory and file descriptions

### 💻 Application Code
- **`blink-app.py`** (7.2 KB) - Main Python application
  - Implements 20/20/20 eye rest timer
  - Screen state monitoring
  - Notification system
  - Multiple notification backends

### 🔧 Configuration & Installation
- **`blink.sh`** (325 B) - Launcher script
  - Simple bash wrapper
  - Launches blink-app.py
  - Stores PID for management

- **`setup.sh`** (2.4 KB) - Installation and setup script
  - Checks dependencies
  - Makes scripts executable
  - Configures auto-start
  - Installs desktop entry

- **`blink-app.desktop`** (377 B) - Desktop entry file
  - Application menu integration
  - Auto-start configuration
  - GNOME/KDE/Xfce compatible

- **`blink-app.service`** (424 B) - Systemd user service (optional)
  - Alternative to desktop entry
  - For systemd-based systems
  - Advanced users only

### 🧪 Testing & Validation
- **`test.sh`** (3.6 KB) - Comprehensive test script
  - Validates all dependencies
  - Checks file permissions
  - Tests notifications
  - Tests screen detection
  - Provides diagnostic information

---

## 📖 Reading Guide

### For Quick Setup (5 minutes)
1. Read: `QUICKSTART.md`
2. Run: `setup.sh`
3. Done! ✓

### For Complete Understanding (20 minutes)
1. Read: `START_HERE.md`
2. Read: `README.md`
3. Run: `setup.sh`
4. Run: `test.sh`

### For Advanced Configuration (30+ minutes)
1. Read: `README.md` (everything)
2. Read: `IMPLEMENTATION.md`
3. Edit: `blink-app.py` (customization)
4. Read: `blink-app.service` (systemd setup)

### For Troubleshooting
1. Check: `README.md` - Troubleshooting section
2. Run: `test.sh` - Diagnostic validation
3. Check: `IMPLEMENTATION.md` - How it works

---

## 📊 File Statistics

| File | Type | Size | Purpose |
|------|------|------|---------|
| blink-app.py | Python | 7.2K | Main application |
| blink.sh | Bash | 325B | Launcher |
| setup.sh | Bash | 2.4K | Setup script |
| test.sh | Bash | 3.6K | Testing |
| blink-app.desktop | Desktop | 377B | Menu integration |
| blink-app.service | Systemd | 424B | Service file |
| README.md | Doc | 6.5K | Full reference |
| START_HERE.md | Doc | 7.4K | Quick overview |
| QUICKSTART.md | Doc | 1.3K | Fast setup |
| IMPLEMENTATION.md | Doc | 5.8K | Tech details |

**Total: 10 files, ~56 KB**

---

## 🎯 Quick Reference

### Installation
```bash
cd ~/Documents/blink-app/linux
bash setup.sh
```

### Run the App
```bash
python3 ~/Documents/blink-app/linux/blink-app.py
# or
~/Documents/blink-app/linux/blink.sh &
```

### Test Everything
```bash
bash ~/Documents/blink-app/linux/test.sh
```

### View Logs
```bash
python3 ~/Documents/blink-app/linux/blink-app.py 2>&1 | tee ~/blink-app.log
```

### Stop the App
```bash
pkill -f "python3.*blink-app"
```

### Disable Auto-Start
```bash
rm ~/.config/autostart/blink-app.desktop
```

---

## 🔧 Technical Details

### Dependencies
- **Python 3.6+** - Runtime environment
- **libnotify-bin** - System notifications
- **xprintidle** - Screen idle detection
- **Optional: zenity** - Fallback GUI dialogs

### How It Works
1. Main loop checks time every 5 seconds
2. Every 20 minutes, shows notification
3. Monitors screen state via xprintidle
4. Resets timer when screen wakes
5. Skips notifications when screen is dark

### Notification Methods (in order)
1. DBus → Most reliable
2. notify-send → Standard Linux
3. zenity → Guaranteed visible fallback

---

## 💾 Directory Structure

```
/home/isaac/Documents/blink-app/
├── linux/
│   ├── blink-app.py              ← Main app
│   ├── blink.sh                  ← Launcher
│   ├── setup.sh                  ← Setup
│   ├── test.sh                   ← Tests
│   ├── blink-app.desktop         ← Desktop entry
│   ├── blink-app.service         ← Systemd service
│   ├── README.md                 ← Full docs
│   ├── START_HERE.md             ← Overview (👈 start here)
│   ├── QUICKSTART.md             ← Quick setup
│   ├── IMPLEMENTATION.md         ← Tech details
│   └── INDEX.md                  ← This file
├── app/                          ← Flutter app
├── android/                      ← Android build
├── ios/                          ← iOS build
├── web/                          ← Web build
└── README.md                     ← Project root docs
```

---

## ✅ Verification Checklist

After setup, verify:
- [ ] Python 3 installed: `python3 --version`
- [ ] notify-send installed: `which notify-send`
- [ ] xprintidle installed: `which xprintidle`
- [ ] Scripts executable: `ls -l blink*.py blink*.sh setup.sh`
- [ ] Desktop entry created: `cat ~/.config/autostart/blink-app.desktop`
- [ ] Notification test: `notify-send "Test" "Test notification"`
- [ ] Screen detection: `xprintidle` (should show idle time)

---

## 📞 Support

For issues:
1. Run: `test.sh` - Check for problems
2. Read: `README.md` - Troubleshooting section
3. Check: `IMPLEMENTATION.md` - How it works
4. View: Logs with `python3 blink-app.py 2>&1`

---

## 🎉 Summary

You have a **complete Linux 20/20/20 eye rest reminder** with:
- ✅ Full documentation
- ✅ Automated setup
- ✅ Testing tools
- ✅ Multiple configuration options
- ✅ Professional notifications
- ✅ Smart screen detection

**Start with: `START_HERE.md` or run `setup.sh`**

Happy eye resting! 👀
