class StudySession {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration targetDuration;
  final Duration actualDuration;
  final bool completed;
  final int breakCount;
  final String sessionType; // 'pomodoro', 'custom', 'timed'

  StudySession({
    required this.id,
    required this.taskId,
    required this.startTime,
    this.endTime,
    required this.targetDuration,
    required this.actualDuration,
    this.completed = false,
    this.breakCount = 0,
    this.sessionType = 'custom',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'targetDuration': targetDuration.inMinutes,
      'actualDuration': actualDuration.inMinutes,
      'completed': completed,
      'breakCount': breakCount,
      'sessionType': sessionType,
    };
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      targetDuration: Duration(minutes: json['targetDuration'] as int),
      actualDuration: Duration(minutes: json['actualDuration'] as int),
      completed: json['completed'] as bool? ?? false,
      breakCount: json['breakCount'] as int? ?? 0,
      sessionType: json['sessionType'] as String? ?? 'custom',
    );
  }
}
