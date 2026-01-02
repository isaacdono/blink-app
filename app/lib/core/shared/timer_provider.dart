import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppState { idle, onboarding, breakReady, breakInProgress, reflection }

class Settings {
  int intervalMinutes;
  int breakDurationSeconds;
  bool soundEnabled;
  bool meditationMode;
  int activeStartHour;
  int activeEndHour;

  Settings({
    this.intervalMinutes = 20,
    this.breakDurationSeconds = 20,
    this.soundEnabled = false,
    this.meditationMode = false,
    this.activeStartHour = 9,
    this.activeEndHour = 18,
  });

  Map<String, dynamic> toJson() => {
        'intervalMinutes': intervalMinutes,
        'breakDurationSeconds': breakDurationSeconds,
        'soundEnabled': soundEnabled,
        'meditationMode': meditationMode,
        'activeStartHour': activeStartHour,
        'activeEndHour': activeEndHour,
      };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        intervalMinutes: json['intervalMinutes'] ?? 20,
        breakDurationSeconds: json['breakDurationSeconds'] ?? 20,
        soundEnabled: json['soundEnabled'] ?? false,
        meditationMode: json['meditationMode'] ?? false,
        activeStartHour: json['activeStartHour'] ?? 9,
        activeEndHour: json['activeEndHour'] ?? 18,
      );
}

class TimerProvider with ChangeNotifier {
  AppState _appState = AppState.onboarding;
  Settings _settings = Settings();
  int _secondsRemaining = 0;
  int _breaksCompletedToday = 0;
  String? _breakType;
  int _totalBreakSeconds = 20;
  Timer? _timer;

  AppState get appState => _appState;
  Settings get settings => _settings;
  int get secondsRemaining => _secondsRemaining;
  int get breaksCompletedToday => _breaksCompletedToday;
  String? get breakType => _breakType;
  int get totalBreakSeconds => _totalBreakSeconds;

  TimerProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadSettings();
    await _loadState();
    _startTimerLogic();
  }

  void _startTimerLogic() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_appState == AppState.idle) {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          notifyListeners();
        } else {
          _appState = AppState.breakReady;
          _saveState();
          notifyListeners();
        }
      } else if (_appState == AppState.breakInProgress) {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          notifyListeners();
        } else {
          _appState = AppState.reflection;
          _saveState();
          notifyListeners();
        }
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('settings');
    if (settingsJson != null) {
      try {
        _settings = Settings.fromJson(jsonDecode(settingsJson));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading settings: $e');
      }
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final appStateStr = prefs.getString('appState');
    final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    
    if (!hasCompletedOnboarding) {
      _appState = AppState.onboarding;
    } else if (appStateStr != null) {
      _appState = AppState.values.firstWhere(
        (e) => e.toString() == appStateStr,
        orElse: () => AppState.idle,
      );
    } else {
      _appState = AppState.idle;
      _secondsRemaining = _settings.intervalMinutes * 60;
    }
    
    _breaksCompletedToday = prefs.getInt('breaksCompletedToday') ?? 0;
    
    if (_appState == AppState.idle) {
      _secondsRemaining = _settings.intervalMinutes * 60;
    } else if (_appState == AppState.breakInProgress) {
      _secondsRemaining = _settings.breakDurationSeconds;
    }
    
    notifyListeners();
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode(_settings.toJson()));
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appState', _appState.toString());
    await prefs.setInt('breaksCompletedToday', _breaksCompletedToday);
  }

  void completeOnboarding() async {
    _appState = AppState.idle;
    _secondsRemaining = _settings.intervalMinutes * 60;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    _saveState();
    notifyListeners();
  }

  void startFocus() {
    _appState = AppState.idle;
    _secondsRemaining = _settings.intervalMinutes * 60;
    _saveState();
    notifyListeners();
  }

  void snoozeOneHour() {
    _appState = AppState.idle;
    _secondsRemaining = 60 * 60;
    _saveState();
    notifyListeners();
  }

  void startBreak(String type) {
    _appState = AppState.breakInProgress;
    _breakType = type;
    _totalBreakSeconds = _settings.breakDurationSeconds;
    _secondsRemaining = _totalBreakSeconds;
    _saveState();
    notifyListeners();
  }

  void cancelBreak() {
    _appState = AppState.idle;
    _secondsRemaining = _settings.intervalMinutes * 60;
    _saveState();
    notifyListeners();
  }

  void finishReflection() {
    _breaksCompletedToday++;
    startFocus();
  }

  void updateSettings(Settings newSettings) {
    _settings = newSettings;
    _saveSettings();
    // If we are in idle mode, we might want to reset the timer to the new interval
    if (_appState == AppState.idle) {
      _secondsRemaining = _settings.intervalMinutes * 60;
    }
    notifyListeners();
  }

  void resetDailyProgress() {
    _breaksCompletedToday = 0;
    _saveState();
    notifyListeners();
  }

  void testBreak() {
    _appState = AppState.breakReady;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}