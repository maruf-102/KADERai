import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroTimerModel extends ChangeNotifier {
  Timer? _timer;

  int _remainingTime = 1500; // Default: 25 minutes in seconds
  int _focusDuration = 1500; // Focus session in seconds (25 minutes)
  int _shortBreakDuration = 300; // Short break duration in seconds (5 minutes)
  int _longBreakDuration = 900; // Long break duration in seconds (15 minutes)

  bool _isBreak = false;
  int _sessionCount = 0;
  bool _isRunning = false;

  // Getters for accessing private variables
  int get remainingTime => _remainingTime;
  int get focusDuration => _focusDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  bool get isRunning => _isRunning;
  bool get isBreak => _isBreak;

  /// Start the timer
  void startTimer() {
    if (_isRunning) return;  // Prevent starting the timer if already running

    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _isRunning = false;
        _toggleSession();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  /// Stop the timer
  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  /// Reset the timer
  void resetTimer() {
    _timer?.cancel();
    _remainingTime = _isBreak ? _shortBreakDuration : _focusDuration;
    _isRunning = false;
    notifyListeners();
  }

  /// Toggle between focus and break sessions
  void _toggleSession() {
    if (_isBreak) {
      _remainingTime = _focusDuration;
      _isBreak = false;
    } else {
      _sessionCount++;
      if (_sessionCount % 4 == 0) {
        _remainingTime = _longBreakDuration;  // Long break after every 4 sessions
      } else {
        _remainingTime = _shortBreakDuration;  // Short break after each focus session
      }
      _isBreak = true;
    }
  }

  /// Update focus duration
  void setFocusDuration(int newDuration) {
    _focusDuration = newDuration;
    if (!_isBreak) _remainingTime = newDuration;
    notifyListeners();
  }

  /// Update short break duration
  void setShortBreakDuration(int newDuration) {
    _shortBreakDuration = newDuration;
    if (_isBreak && _sessionCount % 4 != 0) _remainingTime = newDuration;
    notifyListeners();
  }

  /// Update long break duration
  void setLongBreakDuration(int newDuration) {
    _longBreakDuration = newDuration;
    if (_isBreak && _sessionCount % 4 == 0) _remainingTime = newDuration;
    notifyListeners();
  }

  /// Format time as MM:SS
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
