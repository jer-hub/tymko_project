class AcademicPerformance {
  final String id;
  final String studentId;
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final int onTimeTasks;
  final int lateTasks;
  final Duration totalStudyTime;
  final double averageTaskScore; // Optional: if grading is implemented
  final int consecutiveOnTimeDays;
  final bool hadCrammingSession; // Study session > 3 hours in one sitting
  final int weekNumber; // Week of the year for trend tracking

  AcademicPerformance({
    required this.id,
    required this.studentId,
    required this.date,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.onTimeTasks = 0,
    this.lateTasks = 0,
    this.totalStudyTime = Duration.zero,
    this.averageTaskScore = 0,
    this.consecutiveOnTimeDays = 0,
    this.hadCrammingSession = false,
    required this.weekNumber,
  });

  double get completionRate =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  double get punctualityRate =>
      completedTasks > 0 ? (onTimeTasks / completedTasks) * 100 : 0;

  int get studyMinutes => totalStudyTime.inMinutes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'onTimeTasks': onTimeTasks,
      'lateTasks': lateTasks,
      'totalStudyTime': totalStudyTime.inMinutes,
      'averageTaskScore': averageTaskScore,
      'consecutiveOnTimeDays': consecutiveOnTimeDays,
      'hadCrammingSession': hadCrammingSession,
      'weekNumber': weekNumber,
    };
  }

  factory AcademicPerformance.fromJson(Map<String, dynamic> json) {
    return AcademicPerformance(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalTasks: json['totalTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      onTimeTasks: json['onTimeTasks'] as int? ?? 0,
      lateTasks: json['lateTasks'] as int? ?? 0,
      totalStudyTime: Duration(minutes: json['totalStudyTime'] as int? ?? 0),
      averageTaskScore: json['averageTaskScore'] as double? ?? 0,
      consecutiveOnTimeDays: json['consecutiveOnTimeDays'] as int? ?? 0,
      hadCrammingSession: json['hadCrammingSession'] as bool? ?? false,
      weekNumber: json['weekNumber'] as int,
    );
  }
}

class PerformanceCorrelation {
  final String metric;
  final double correlationCoefficient; // -1 to 1
  final String interpretation;
  final String recommendation;
  final List<Map<String, dynamic>> dataPoints;

  PerformanceCorrelation({
    required this.metric,
    required this.correlationCoefficient,
    required this.interpretation,
    required this.recommendation,
    this.dataPoints = const [],
  });

  String get strength {
    final abs = correlationCoefficient.abs();
    if (abs >= 0.7) return 'Strong';
    if (abs >= 0.4) return 'Moderate';
    if (abs >= 0.2) return 'Weak';
    return 'Negligible';
  }

  bool get isPositive => correlationCoefficient > 0;
}
