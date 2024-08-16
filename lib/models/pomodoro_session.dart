class PomodoroSession {
  int workDuration;
  int breakDuration;
  int longBreakDuration;
  int sessionsBeforeLongBreak;
  DateTime? startTime;
  DateTime? endTime;
  int completedSessions;
  bool isCompleted;

  PomodoroSession({
    this.workDuration = 25,
    this.breakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.startTime,
    this.endTime,
    this.completedSessions = 0,
    this.isCompleted = false,
  }) {
    if (workDuration <= 0 || breakDuration <= 0 || longBreakDuration <= 0) {
      throw ArgumentError('Durations must be positive integers.');
    }
    if (sessionsBeforeLongBreak <= 0) {
      throw ArgumentError(
          'sessionsBeforeLongBreak must be a positive integer.');
    }
  }

  void start() {
    startTime = DateTime.now();
    isCompleted = false;
  }

  void end() {
    endTime = DateTime.now();
    isCompleted = true;
  }

  bool isTimeForLongBreak() {
    return completedSessions > 0 &&
        completedSessions % sessionsBeforeLongBreak == 0;
  }

  Duration getCurrentSessionDuration() {
    if (startTime == null) {
      throw StateError('Session has not started yet.');
    }
    return DateTime.now().difference(startTime!);
  }

  Duration getRemainingTime() {
    if (startTime == null) {
      throw StateError('Session has not started yet.');
    }
    final sessionDuration = Duration(minutes: workDuration);
    final elapsed = DateTime.now().difference(startTime!);
    return sessionDuration - elapsed;
  }

  Map<String, dynamic> toJson() {
    return {
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'longBreakDuration': longBreakDuration,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completedSessions': completedSessions,
      'isCompleted': isCompleted,
    };
  }

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      workDuration: json['workDuration'] ?? 25,
      breakDuration: json['breakDuration'] ?? 5,
      longBreakDuration: json['longBreakDuration'] ?? 15,
      sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] ?? 4,
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      completedSessions: json['completedSessions'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
