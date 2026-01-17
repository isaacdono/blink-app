# Blink App - Linux Eye Rest Reminder

A lightweight Linux desktop application that implements the **20/20/20 rule** for eye health:
- Every **20 minutes**, take a break
- Look at something **20 feet away**
- For **20 seconds**

## Features

✨ **Core Features:**
- 🔔 Shows a notification every 20 minutes to rest your eyes
- 🖥️ Automatically detects screen idle/sleep states and resets the timer
- ⚡ Lightweight and low resource consumption
- 🚀 Auto-starts on boot (after setup)
- 🔕 Non-intrusive desktop notifications

## Requirements

### Minimum Requirements
- Linux with X11 or Wayland display server
- Python 3.6+

### Required System Packages

**On Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install python3 libnotify-bin xprintidle
```

**On Fedora/RHEL:**
```bash
sudo dnf install python3 libnotify zenity xprintidle
```

**On Arch Linux:**
```bash
sudo pacman -S python libnotify xprintidle zenity
```

### Optional but Recommended
- `dbus` - For better notification support (usually pre-installed)
- `zenity` - Fallback for notifications if others fail

## Installation

### Quick Setup
```bash
cd /home/isaac/Documents/blink-app/linux
chmod +x setup.sh
./setup.sh
```

The setup script will:
1. Check for required dependencies
2. Make scripts executable
3. Install autostart configuration
4. Prompt to install missing dependencies if needed

### Manual Setup
```bash
cd /home/isaac/Documents/blink-app/linux
chmod +x blink.sh blink-app.py

# Copy desktop entry to autostart
mkdir -p ~/.config/autostart
cp blink-app.desktop ~/.config/autostart/
```

## Usage

### Start the Application

**Option 1: Using the launcher script**
```bash
~/Documents/blink-app/linux/blink.sh
```

**Option 2: Direct Python execution**
```bash
python3 ~/Documents/blink-app/linux/blink-app.py
```

**Option 3: Automatic startup (after setup)**
The app will automatically start when you log in.

### Stop the Application
```bash
# Kill the process
pkill -f "python3.*blink-app.py"

# Or if you know the PID
kill $(cat ~/.blink-app.pid)
```

### Run in Background
```bash
# Run as daemon in background
~/Documents/blink-app/linux/blink.sh &

# Or with nohup to persist after logout
nohup python3 ~/Documents/blink-app/linux/blink-app.py &
```

### Run with Systemd User Service (Advanced)

Create `~/.config/systemd/user/blink-app.service`:
```ini
[Unit]
Description=Blink Eye Rest Reminder
After=graphical-session-start.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /home/isaac/Documents/blink-app/linux/blink-app.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=graphical-session.target
```

Then enable it:
```bash
systemctl --user enable blink-app.service
systemctl --user start blink-app.service
```

## How It Works

### Timer Logic
1. **Initial Start**: Timer is set for 20 minutes
2. **Every 20 minutes**: A notification appears reminding you to rest your eyes
3. **Screen wakes**: If the screen goes to sleep/dark, the timer resets when the screen wakes up
4. **Continuous monitoring**: The app checks screen state every 5 seconds

### Screen State Detection
The app uses `xprintidle` to detect screen activity:
- **Active** (idle < 5 seconds): Runs normally, shows reminders
- **Idle/Dark** (idle > 5 seconds): Timer pauses, won't show reminders
- **Wake event**: When screen wakes, timer resets

### Notification Fallback Chain
The app tries multiple notification methods in order:
1. **DBus** (most reliable, uses system notification daemon)
2. **notify-send** (standard Linux notifications)
3. **zenity** (GUI dialog as last resort)

## Configuration

### Modify the Interval (Advanced)
Edit `blink-app.py` and change:
```python
INTERVAL_SECONDS = 20 * 60  # Change 20 to your desired minutes
```

### Modify Notification Duration
Edit `blink-app.py` and change:
```python
NOTIFICATION_DURATION = 20  # seconds
```

## Troubleshooting

### Notifications Not Showing
1. Check if `notify-send` is installed:
   ```bash
   which notify-send
   ```

2. Test notification manually:
   ```bash
   notify-send "Test" "If you see this, notifications work"
   ```

3. If it doesn't work, install `libnotify-bin`:
   ```bash
   sudo apt-get install libnotify-bin  # Ubuntu/Debian
   sudo dnf install libnotify           # Fedora/RHEL
   ```

### Screen Detection Not Working
1. Verify `xprintidle` is installed:
   ```bash
   which xprintidle
   ```

2. Test it manually:
   ```bash
   xprintidle  # Should output idle time in milliseconds
   ```

3. If it doesn't work, install it:
   ```bash
   sudo apt-get install x11-utils  # Ubuntu/Debian
   sudo dnf install xorg-x11-utils # Fedora/RHEL
   ```

### App Not Auto-Starting on Boot
1. Verify the desktop entry exists:
   ```bash
   ls -la ~/.config/autostart/blink-app.desktop
   ```

2. Verify the file has correct permissions:
   ```bash
   chmod +x ~/.config/autostart/blink-app.desktop
   ```

3. Check the Exec path in the desktop file:
   ```bash
   cat ~/.config/autostart/blink-app.desktop | grep Exec
   ```

4. For GNOME, check autostart settings in Settings > Details > Startup Applications

### High CPU Usage
- This should not happen. If it does, it might be due to:
  - Check `xprintidle` behavior: `watch -n 1 'xprintidle; echo'`
  - Restart the application
  - Report the issue with system details

### Wayland Support
- For Wayland, you may need alternative screen detection
- Current version is optimized for X11
- Zenity notifications should still work on Wayland

## Disabling Autostart

### Option 1: Desktop Entry
```bash
rm ~/.config/autostart/blink-app.desktop
```

### Option 2: Via Settings
- GNOME: Settings → Details → Startup Applications → Toggle "Blink" off
- KDE: System Settings → Startup and Shutdown → Autostart → Disable "Blink"

### Option 3: Systemd
```bash
systemctl --user disable blink-app.service
```

## Logs and Debugging

To run with debug output:
```bash
python3 ~/Documents/blink-app/linux/blink-app.py 2>&1 | tee ~/blink-app.log
```

The app outputs:
- `[TIMESTAMP] Timer reset. Next reminder at: ...` - Timer events
- `[TIMESTAMP] Showing reminder...` - Notification events
- `[TIMESTAMP] Screen woke up - resetting timer` - Screen state changes
- Error messages if something fails

## System Resources

- **CPU**: < 1% (minimal, mostly idle)
- **Memory**: ~30-50 MB
- **Disk**: ~10 KB (app only)

## License

Part of the Blink App project - Eye rest reminder application

## Support & Contributing

For issues, improvements, or feature requests, please refer to the main project repository.

---

**Remember: Your eyes are precious! Take regular breaks! 👀**
