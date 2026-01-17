#!/usr/bin/env python3
"""
20/20/20 Eye Rest Reminder for Linux
Reminds users to rest their eyes every 20 minutes following the 20/20/20 rule:
- Every 20 minutes, look at something 20 feet away for 20 seconds
"""

import sys
import time
import threading
import subprocess
import os
from datetime import datetime, timedelta
from pathlib import Path

try:
    import dbus
    DBUS_AVAILABLE = True
except ImportError:
    DBUS_AVAILABLE = False

# Constants
INTERVAL_SECONDS = 20 * 60  # 20 minutes
NOTIFICATION_DURATION = 20  # seconds to display notification


class ScreenMonitor:
    """Monitors screen activity using X11 or Wayland"""
    
    def __init__(self):
        self.last_activity = time.time()
        self.screen_is_active = True
        self.is_running = True
        
    def get_x11_idle_time(self):
        """Get idle time from X11 using xprintidle"""
        try:
            result = subprocess.run(
                ['xprintidle'],
                capture_output=True,
                text=True,
                timeout=1
            )
            if result.returncode == 0:
                idle_ms = int(result.stdout.strip())
                return idle_ms / 1000.0  # Convert to seconds
        except (subprocess.TimeoutExpired, FileNotFoundError, ValueError):
            pass
        return None
    
    def check_screen_state(self):
        """Check if screen is active"""
        idle_time = self.get_x11_idle_time()
        
        if idle_time is not None:
            # If idle time < 5 seconds, screen is active
            if idle_time < 5:
                if not self.screen_is_active:
                    # Screen woke up, reset timer
                    self.last_activity = time.time()
                    self.screen_is_active = True
                    return "wake"
                return "active"
            else:
                # Screen is idle/dark
                self.screen_is_active = False
                return "idle"
        
        return "unknown"


class NotificationManager:
    """Handles system notifications"""
    
    def show_notification(self, title, message, duration=NOTIFICATION_DURATION):
        """Show a system notification"""
        methods = [
            self._notify_dbus,
            self._notify_notify_send,
            self._notify_zenity,
        ]
        
        for method in methods:
            if method(title, message, duration):
                return True
        
        return False
    
    def _notify_dbus(self, title, message, duration):
        """Use DBus to show notification (most reliable)"""
        if not DBUS_AVAILABLE:
            return False
        
        try:
            bus = dbus.SessionBus()
            notifications = bus.get_object(
                'org.freedesktop.Notifications',
                '/org/freedesktop/Notifications'
            )
            interface = dbus.Interface(
                notifications,
                'org.freedesktop.Notifications'
            )
            
            interface.Notify(
                'blink-app',  # app_name
                0,  # replaces_id
                '',  # app_icon
                title,  # summary
                message,  # body
                [],  # actions
                {'urgency': dbus.Byte(2)},  # hints (urgency: critical)
                int(duration * 1000)  # timeout (ms)
            )
            return True
        except Exception as e:
            print(f"DBus notification failed: {e}", file=sys.stderr)
            return False
    
    def _notify_notify_send(self, title, message, duration):
        """Use notify-send command"""
        try:
            subprocess.run(
                [
                    'notify-send',
                    '-u', 'critical',
                    '-t', str(int(duration * 1000)),
                    title,
                    message
                ],
                timeout=2
            )
            return True
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    def _notify_zenity(self, title, message, duration):
        """Use zenity dialog as fallback"""
        try:
            subprocess.Popen(
                [
                    'zenity',
                    '--info',
                    '--title', title,
                    '--text', message,
                    '--no-wrap'
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            return True
        except FileNotFoundError:
            return False


class EyeRestReminder:
    """Main application class"""
    
    def __init__(self):
        self.screen_monitor = ScreenMonitor()
        self.notification_manager = NotificationManager()
        self.next_reminder = time.time() + INTERVAL_SECONDS
        self.is_running = True
        self.lock = threading.Lock()
        
    def reset_timer(self):
        """Reset the reminder timer"""
        with self.lock:
            self.next_reminder = time.time() + INTERVAL_SECONDS
            print(f"[{datetime.now()}] Timer reset. Next reminder at: {datetime.fromtimestamp(self.next_reminder)}")
    
    def show_reminder(self):
        """Show the eye rest reminder"""
        print(f"[{datetime.now()}] Showing reminder...")
        self.notification_manager.show_notification(
            "Time for Eye Rest 👀",
            "Breath slowly. Look at something 20 feet away for 20 seconds.\n"
            "This helps reduce eye strain and fatigue.",
            NOTIFICATION_DURATION
        )
    
    def monitor_loop(self):
        """Main monitoring loop"""
        print("Eye Rest Reminder started...")
        print(f"Reminder interval: {INTERVAL_SECONDS // 60} minutes")
        
        while self.is_running:
            try:
                current_time = time.time()
                screen_state = self.screen_monitor.check_screen_state()
                
                # Check for screen state changes
                if screen_state == "wake":
                    print(f"[{datetime.now()}] Screen woke up - resetting timer")
                    self.reset_timer()
                elif screen_state == "idle":
                    # Don't show reminder while screen is dark/idle
                    if current_time >= self.next_reminder:
                        print(f"[{datetime.now()}] Screen is idle, skipping reminder")
                        self.reset_timer()
                elif current_time >= self.next_reminder:
                    # Show reminder if it's time and screen is active
                    self.show_reminder()
                    self.reset_timer()
                
                time.sleep(5)  # Check every 5 seconds
                
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"Error in monitor loop: {e}", file=sys.stderr)
                time.sleep(5)
        
        print("Eye Rest Reminder stopped.")
    
    def run(self):
        """Start the application"""
        try:
            self.monitor_loop()
        except KeyboardInterrupt:
            print("\nShutting down...")
        finally:
            self.is_running = False


def main():
    """Entry point"""
    app = EyeRestReminder()
    app.run()


if __name__ == '__main__':
    main()
