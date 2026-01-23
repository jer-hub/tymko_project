class BehaviorMetrics {
  final String studentId;
  final DateTime date;
  final int tasksCompleted;
  final int tasksCreated;
  final int tasksMissed;
  final Duration totalStudyTime;
  final int pomodoroSessions;
  final int procrastinationCount; // Tasks completed past deadline
  final double consistencyScore; // 0-100
  final List<int> peakProductivityHours;

  BehaviorMetrics({
    required this.studentId,
    required this.date,
    this.tasksCompleted = 0,
    this.tasksCreated = 0,
    this.tasksMissed = 0,
    this.totalStudyTime = Duration.zero,
    this.pomodoroSessions = 0,
    this.procrastinationCount = 0,
    this.consistencyScore = 0,
    this.peakProductivityHours = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'date': date.toIso8601String(),
      'tasksCompleted': tasksCompleted,
      'tasksCreated': tasksCreated,
      'tasksMissed': tasksMissed,
      'totalStudyTime': totalStudyTime.inMinutes,
      'pomodoroSessions': pomodoroSessions,
      'procrastinationCount': procrastinationCount,
      'consistencyScore': consistencyScore,
      'peakProductivityHours': peakProductivityHours,
    };
  }

  factory BehaviorMetrics.fromJson(Map<String, dynamic> json) {
    return BehaviorMetrics(
      studentId: json['studentId'] as String,
      date: DateTime.parse(json['date'] as String),
      tasksCompleted: json['tasksCompleted'] as int? ?? 0,
      tasksCreated: json['tasksCreated'] as int? ?? 0,
      tasksMissed: json['tasksMissed'] as int? ?? 0,
      totalStudyTime: Duration(minutes: json['totalStudyTime'] as int? ?? 0),
      pomodoroSessions: json['pomodoroSessions'] as int? ?? 0,
      procrastinationCount: json['procrastinationCount'] as int? ?? 0,
      consistencyScore: (json['consistencyScore'] as num?)?.toDouble() ?? 0,
      peakProductivityHours:
          (json['peakProductivityHours'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}
