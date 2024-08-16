import 'dart:async';

import 'package:flutter/material.dart';

class PomodoroProvider with ChangeNotifier {
  int _workDuration = 25;
  int _breakDuration = 5;
  int _remainingTime = 25 * 60;
  bool _isWorkTime = true;
  bool _isRunning = false;
  Timer? _timer;

  int get workDuration => _workDuration;
  int get breakDuration => _breakDuration;
  int get remainingTime => _remainingTime;
  bool get isWorkTime => _isWorkTime;
  bool get isRunning => _isRunning;

  void startPomodoro() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void _tick(Timer timer) {
    if (_remainingTime > 0) {
      _remainingTime--;
    } else {
      _switchSession();
    }
    notifyListeners();
  }

  void pausePomodoro() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
      notifyListeners();
    }
  }

  void resetPomodoro() {
    _timer?.cancel();
    _isRunning = false;
    _remainingTime = (_isWorkTime ? _workDuration : _breakDuration) * 60;
    notifyListeners();
  }

  void stopPomodoro() {
    _timer?.cancel();
    _isRunning = false;
    _isWorkTime = true;
    _remainingTime = _workDuration * 60;
    notifyListeners();
  }

  void setDurations(int work, int breakTime) {
    _workDuration = work;
    _breakDuration = breakTime;
    _updateRemainingTime();
    notifyListeners();
  }

  void _switchSession() {
    _isWorkTime = !_isWorkTime;
    _remainingTime = (_isWorkTime ? _workDuration : _breakDuration) * 60;
    notifyListeners();
    if (_isRunning) {
      _timer?.cancel();
      startPomodoro();
    }
  }

  void _updateRemainingTime() {
    _remainingTime = (_isWorkTime ? _workDuration : _breakDuration) * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void toggleWorkBreak() {
    _isWorkTime = !_isWorkTime;
    _remainingTime = (_isWorkTime ? _workDuration : _breakDuration) * 60;
    notifyListeners();
    if (_isRunning) {
      _timer?.cancel();
      startPomodoro();
    }
  }
}
