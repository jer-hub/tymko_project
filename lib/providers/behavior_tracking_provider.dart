import 'package:flutter/material.dart';
import '../models/behavior_metrics.dart';
import '../models/study_session.dart';
import '../models/task.dart';
import '../models/reflection.dart';
import '../models/academic_performance.dart';
import 'dart:math' as math;

class BehaviorTrackingProvider with ChangeNotifier {
  final List<BehaviorMetrics> _dailyMetrics = [];
  final List<StudySession> _studySessions = [];
  final List<Reflection> _reflections = [];
  final List<AcademicPerformance> _performanceHistory = [];

  List<BehaviorMetrics> get dailyMetrics => _dailyMetrics;
  List<StudySession> get studySessions => _studySessions;
  List<Reflection> get reflections => _reflections;
  List<AcademicPerformance> get performanceHistory => _performanceHistory;

  // Record study session
  void addStudySession(StudySession session) {
    _studySessions.add(session);
    _updateDailyMetrics(session.startTime);
    notifyListeners();
  }

  // Record reflection
  void addReflection(Reflection reflection) {
    _reflections.add(reflection);
    notifyListeners();
  }

  // Update daily metrics when task is completed
  void recordTaskCompletion(Task task, {bool isPastDeadline = false}) {
    final date = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    var metrics = _getMetricsForDate(date, task.studentId);

    metrics = BehaviorMetrics(
      studentId: task.studentId,
      date: date,
      tasksCompleted: metrics.tasksCompleted + 1,
      tasksCreated: metrics.tasksCreated,
      tasksMissed: metrics.tasksMissed,
      totalStudyTime: metrics.totalStudyTime,
      pomodoroSessions: metrics.pomodoroSessions,
      procrastinationCount: isPastDeadline
          ? metrics.procrastinationCount + 1
          : metrics.procrastinationCount,
      consistencyScore: _calculateConsistencyScore(task.studentId),
      peakProductivityHours: _calculatePeakHours(task.studentId),
    );

    _updateMetrics(metrics);
  }

  // Record missed task
  void recordMissedTask(Task task) {
    final date = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    var metrics = _getMetricsForDate(date, task.studentId);

    metrics = BehaviorMetrics(
      studentId: task.studentId,
      date: date,
      tasksCompleted: metrics.tasksCompleted,
      tasksCreated: metrics.tasksCreated,
      tasksMissed: metrics.tasksMissed + 1,
      totalStudyTime: metrics.totalStudyTime,
      pomodoroSessions: metrics.pomodoroSessions,
      procrastinationCount: metrics.procrastinationCount,
      consistencyScore: _calculateConsistencyScore(task.studentId),
      peakProductivityHours: metrics.peakProductivityHours,
    );

    _updateMetrics(metrics);
  }

  void _updateDailyMetrics(DateTime date) {
    // This would be called after study sessions to update metrics
    notifyListeners();
  }

  BehaviorMetrics _getMetricsForDate(DateTime date, String studentId) {
    try {
      return _dailyMetrics.firstWhere(
        (m) =>
            m.date.year == date.year &&
            m.date.month == date.month &&
            m.date.day == date.day &&
            m.studentId == studentId,
      );
    } catch (e) {
      final newMetrics = BehaviorMetrics(studentId: studentId, date: date);
      _dailyMetrics.add(newMetrics);
      return newMetrics;
    }
  }

  void _updateMetrics(BehaviorMetrics metrics) {
    final index = _dailyMetrics.indexWhere(
      (m) =>
          m.date.year == metrics.date.year &&
          m.date.month == metrics.date.month &&
          m.date.day == metrics.date.day &&
          m.studentId == metrics.studentId,
    );

    if (index != -1) {
      _dailyMetrics[index] = metrics;
    } else {
      _dailyMetrics.add(metrics);
    }
    notifyListeners();
  }

  // Analytics methods
  double _calculateConsistencyScore(String studentId) {
    final last7Days = _dailyMetrics
        .where(
          (m) =>
              m.studentId == studentId &&
              DateTime.now().difference(m.date).inDays <= 7,
        )
        .toList();

    if (last7Days.isEmpty) return 0;

    final daysWithTasks = last7Days.where((m) => m.tasksCompleted > 0).length;
    return (daysWithTasks / 7) * 100;
  }

  List<int> _calculatePeakHours(String studentId) {
    final sessions = _studySessions
        .where((s) => DateTime.now().difference(s.startTime).inDays <= 30)
        .toList();

    if (sessions.isEmpty) return [];

    final hourCounts = <int, int>{};
    for (var session in sessions) {
      final hour = session.startTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHours.take(3).map((e) => e.key).toList();
  }

  // Get metrics for a student
  List<BehaviorMetrics> getStudentMetrics(String studentId, {int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _dailyMetrics
        .where((m) => m.studentId == studentId && m.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Detect behavioral patterns
  Map<String, dynamic> analyzePatterns(String studentId) {
    final metrics = getStudentMetrics(studentId, days: 30);

    if (metrics.isEmpty) {
      return {
        'consistency': 'No data',
        'procrastination': 'No data',
        'productivity': 'No data',
      };
    }

    final avgConsistency =
        metrics.map((m) => m.consistencyScore).reduce((a, b) => a + b) /
        metrics.length;
    final totalProcrastination = metrics
        .map((m) => m.procrastinationCount)
        .reduce((a, b) => a + b);
    final avgTasksCompleted =
        metrics.map((m) => m.tasksCompleted).reduce((a, b) => a + b) /
        metrics.length;

    return {
      'consistency': avgConsistency >= 70
          ? 'Excellent'
          : avgConsistency >= 50
          ? 'Good'
          : 'Needs Improvement',
      'procrastination': totalProcrastination < 5
          ? 'Low'
          : totalProcrastination < 15
          ? 'Moderate'
          : 'High',
      'productivity': avgTasksCompleted >= 5
          ? 'High'
          : avgTasksCompleted >= 3
          ? 'Moderate'
          : 'Low',
      'avgTasksPerDay': avgTasksCompleted.toStringAsFixed(1),
      'consistencyScore': avgConsistency.toStringAsFixed(1),
      'totalProcrastination': totalProcrastination,
    };
  }

  // Get study time trends
  Map<String, dynamic> getStudyTimeTrends(String studentId) {
    final sessions = _studySessions
        .where((s) => DateTime.now().difference(s.startTime).inDays <= 30)
        .toList();

    if (sessions.isEmpty) {
      return {'totalMinutes': 0, 'avgMinutesPerDay': 0, 'pomodoroCount': 0};
    }

    final totalMinutes = sessions
        .map((s) => s.actualDuration.inMinutes)
        .reduce((a, b) => a + b);
    final pomodoroCount = sessions
        .where((s) => s.sessionType == 'pomodoro')
        .length;

    return {
      'totalMinutes': totalMinutes,
      'avgMinutesPerDay': (totalMinutes / 30).toStringAsFixed(1),
      'pomodoroCount': pomodoroCount,
    };
  }

  // Check if student needs intervention
  bool needsIntervention(String studentId) {
    final patterns = analyzePatterns(studentId);

    return patterns['consistency'] == 'Needs Improvement' ||
        patterns['procrastination'] == 'High' ||
        patterns['productivity'] == 'Low';
  }

  // Get personalized suggestions
  List<String> getAdaptiveSuggestions(String studentId) {
    final patterns = analyzePatterns(studentId);
    final suggestions = <String>[];

    if (patterns['consistency'] == 'Needs Improvement') {
      suggestions.add(
        '📅 Try setting a consistent study schedule each day to build better habits.',
      );
    }

    if (patterns['procrastination'] == 'High') {
      suggestions.add(
        '⏰ Consider using the Pomodoro timer to break tasks into focused 25-minute sessions.',
      );
    }

    if (patterns['productivity'] == 'Low') {
      suggestions.add(
        '🎯 Break larger tasks into smaller subtasks to make them more manageable.',
      );
    }

    final peakHours = _calculatePeakHours(studentId);
    if (peakHours.isNotEmpty) {
      suggestions.add(
        '✨ Your most productive hours are around ${peakHours.first}:00. Schedule important tasks then!',
      );
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        '🎉 You\'re doing great! Keep maintaining your consistent study habits.',
      );
    }

    return suggestions;
  }

  // Detect early warning signs of academic difficulty
  Map<String, dynamic> detectEarlyWarnings(String studentId) {
    final metrics = getStudentMetrics(studentId, days: 7);
    final warnings = <String>[];
    final severity = <String>[]; // 'low', 'medium', 'high'

    if (metrics.isEmpty) {
      return {
        'warnings': warnings,
        'severity': 'none',
        'requiresIntervention': false,
      };
    }

    // Check for increasing missed deadlines
    final recentMissed = metrics
        .take(3)
        .map((m) => m.tasksMissed)
        .reduce((a, b) => a + b);
    if (recentMissed >= 3) {
      warnings.add('⚠️ Multiple missed deadlines in the past 3 days');
      severity.add('high');
    }

    // Check for procrastination pattern
    final recentProcrastination = metrics
        .take(5)
        .map((m) => m.procrastinationCount)
        .reduce((a, b) => a + b);
    if (recentProcrastination >= 5) {
      warnings.add('🕐 Consistent pattern of last-minute task completion');
      severity.add('medium');
    }

    // Check for declining consistency
    final consistencyTrend = _getConsistencyTrend(studentId);
    if (consistencyTrend < -20) {
      warnings.add(
        '📉 Study consistency has dropped by ${consistencyTrend.abs().toStringAsFixed(0)}%',
      );
      severity.add('medium');
    }

    // Check for no activity periods
    final daysWithoutTasks = metrics.where((m) => m.tasksCompleted == 0).length;
    if (daysWithoutTasks >= 3) {
      warnings.add(
        '😴 No tasks completed on $daysWithoutTasks of the last 7 days',
      );
      severity.add('high');
    }

    // Check for productivity decline
    final productivityTrend = _getProductivityTrend(studentId);
    if (productivityTrend < -30) {
      warnings.add('📊 Productivity has decreased significantly');
      severity.add('medium');
    }

    String overallSeverity = 'low';
    if (severity.contains('high')) {
      overallSeverity = 'high';
    } else if (severity.contains('medium')) {
      overallSeverity = 'medium';
    }

    return {
      'warnings': warnings,
      'severity': overallSeverity,
      'requiresIntervention':
          warnings.isNotEmpty &&
          (overallSeverity == 'high' || overallSeverity == 'medium'),
    };
  }

  // Calculate consistency trend (positive = improving, negative = declining)
  double _getConsistencyTrend(String studentId) {
    final metrics = getStudentMetrics(studentId, days: 14);
    if (metrics.length < 7) return 0;

    final recent =
        metrics.take(7).map((m) => m.consistencyScore).reduce((a, b) => a + b) /
        7;
    final previous =
        metrics
            .skip(7)
            .take(7)
            .map((m) => m.consistencyScore)
            .reduce((a, b) => a + b) /
        7;

    return recent - previous;
  }

  // Calculate productivity trend
  double _getProductivityTrend(String studentId) {
    final metrics = getStudentMetrics(studentId, days: 14);
    if (metrics.length < 7) return 0;

    final recent =
        metrics.take(7).map((m) => m.tasksCompleted).reduce((a, b) => a + b) /
        7;
    final previous =
        metrics
            .skip(7)
            .take(7)
            .map((m) => m.tasksCompleted)
            .reduce((a, b) => a + b) /
        7;

    if (previous == 0) return 0;
    return ((recent - previous) / previous) * 100;
  }

  // Get notification message for student
  String? getStudentNotification(String studentId) {
    final warnings = detectEarlyWarnings(studentId);

    if (warnings['requiresIntervention'] == true) {
      final warningList = warnings['warnings'] as List<String>;
      if (warningList.isNotEmpty) {
        return '⚠️ Attention: ${warningList.first}\nTip: ${getAdaptiveSuggestions(studentId).first}';
      }
    }
    return null;
  }

  // Get parent alert with actionable guidance
  Map<String, dynamic> getParentAlert(String studentId, String studentName) {
    final warnings = detectEarlyWarnings(studentId);
    final patterns = analyzePatterns(studentId);

    if (warnings['requiresIntervention'] != true) {
      return {'hasAlert': false};
    }

    final warningList = warnings['warnings'] as List<String>;
    final severity = warnings['severity'] as String;

    // Generate actionable guidance for parents
    final guidance = <String>[];

    if (patterns['procrastination'] == 'High') {
      guidance.add('Consider having a conversation about time management');
      guidance.add('Help establish a daily study routine');
    }

    if (patterns['consistency'] == 'Needs Improvement') {
      guidance.add('Work together to create a weekly study schedule');
      guidance.add('Set up recurring study reminders');
    }

    if (patterns['productivity'] == 'Low') {
      guidance.add(
        'Discuss breaking down larger assignments into smaller tasks',
      );
      guidance.add('Ensure adequate breaks and rest periods');
    }

    final peakHours = _calculatePeakHours(studentId);
    if (peakHours.isNotEmpty) {
      guidance.add(
        '$studentName works best around ${peakHours.first}:00 - schedule important tasks then',
      );
    }

    return {
      'hasAlert': true,
      'severity': severity,
      'studentName': studentName,
      'warnings': warningList,
      'guidance': guidance,
      'timestamp': DateTime.now(),
    };
  }

  // Analyze task completion time patterns
  Map<String, dynamic> getCompletionTimePatterns(String studentId) {
    final metrics = getStudentMetrics(studentId, days: 30);

    if (metrics.isEmpty) {
      return {'pattern': 'insufficient_data'};
    }

    final totalCompleted = metrics
        .map((m) => m.tasksCompleted)
        .reduce((a, b) => a + b);
    final totalProcrastinated = metrics
        .map((m) => m.procrastinationCount)
        .reduce((a, b) => a + b);

    final procrastinationRate = totalCompleted > 0
        ? (totalProcrastinated / totalCompleted) * 100
        : 0;

    String pattern;
    if (procrastinationRate < 20) {
      pattern = 'early_completer';
    } else if (procrastinationRate < 50) {
      pattern = 'mixed';
    } else {
      pattern = 'chronic_procrastinator';
    }

    return {
      'pattern': pattern,
      'procrastinationRate': procrastinationRate.toStringAsFixed(1),
      'totalCompleted': totalCompleted,
      'completedOnTime': totalCompleted - totalProcrastinated,
      'completedLate': totalProcrastinated,
      'recommendation': _getPatternRecommendation(pattern),
    };
  }

  String _getPatternRecommendation(String pattern) {
    switch (pattern) {
      case 'chronic_procrastinator':
        return 'Set earlier personal deadlines 24-48 hours before actual due dates';
      case 'mixed':
        return 'Use the Pomodoro technique to maintain focus and avoid last-minute rushes';
      case 'early_completer':
        return 'Great time management! Keep maintaining this consistent approach';
      default:
        return 'Track more tasks to identify your completion patterns';
    }
  }

  // Get suggested schedule based on patterns
  List<Map<String, dynamic>> getSuggestedSchedule(String studentId) {
    final peakHours = _calculatePeakHours(studentId);
    final patterns = analyzePatterns(studentId);
    final schedule = <Map<String, dynamic>>[];

    if (peakHours.isEmpty) {
      // Default schedule if no data
      schedule.addAll([
        {
          'time': '9:00 AM',
          'activity': 'Morning Study Session',
          'duration': '50 min',
        },
        {
          'time': '2:00 PM',
          'activity': 'Afternoon Focus Time',
          'duration': '50 min',
        },
        {
          'time': '7:00 PM',
          'activity': 'Review & Planning',
          'duration': '30 min',
        },
      ]);
    } else {
      // Personalized based on peak hours
      for (var hour in peakHours.take(2)) {
        final timeStr = _formatHour(hour);
        schedule.add({
          'time': timeStr,
          'activity': 'Peak Productivity Study Block',
          'duration': '50 min',
          'reason': 'Based on your highest productivity period',
        });
      }
    }

    if (patterns['procrastination'] == 'High') {
      schedule.add({
        'time': 'Daily',
        'activity': 'Morning Task Planning',
        'duration': '10 min',
        'reason': 'Helps prevent last-minute rushes',
      });
    }

    return schedule;
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  // Record academic performance snapshot
  void recordAcademicPerformance(
    String studentId,
    int totalTasks,
    int completedTasks,
    int onTimeTasks,
    int lateTasks,
    Duration totalStudyTime,
    bool hadCrammingSession,
  ) {
    final date = DateTime.now();
    final weekNumber = _getWeekNumber(date);

    // Calculate consecutive on-time days
    int consecutive = 0;
    for (var i = _performanceHistory.length - 1; i >= 0; i--) {
      if (_performanceHistory[i].studentId == studentId &&
          _performanceHistory[i].lateTasks == 0 &&
          _performanceHistory[i].onTimeTasks > 0) {
        consecutive++;
      } else {
        break;
      }
    }

    final performance = AcademicPerformance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: studentId,
      date: date,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      onTimeTasks: onTimeTasks,
      lateTasks: lateTasks,
      totalStudyTime: totalStudyTime,
      consecutiveOnTimeDays: consecutive,
      hadCrammingSession: hadCrammingSession,
      weekNumber: weekNumber,
    );

    _performanceHistory.add(performance);
    notifyListeners();
  }

  int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear) / 7).ceil();
  }

  // CORRELATION ANALYSIS: Study Duration vs. Task Completion Rates
  PerformanceCorrelation analyzeStudyDurationVsCompletion(String studentId) {
    final performances = _performanceHistory
        .where((p) => p.studentId == studentId)
        .toList();

    if (performances.length < 5) {
      return PerformanceCorrelation(
        metric: 'Study Duration vs. Completion',
        correlationCoefficient: 0,
        interpretation: 'Insufficient data (need 5+ days)',
        recommendation: 'Continue tracking for meaningful insights',
      );
    }

    final studyMinutes = performances
        .map((p) => p.studyMinutes.toDouble())
        .toList();
    final completionRates = performances.map((p) => p.completionRate).toList();

    final correlation = _calculateCorrelation(studyMinutes, completionRates);

    String interpretation;
    String recommendation;

    if (correlation > 0.5) {
      interpretation =
          'More study time strongly correlates with higher task completion';
      recommendation =
          'Maintain or increase dedicated study time to improve completion rates';
    } else if (correlation > 0.2) {
      interpretation =
          'Study time shows moderate positive impact on completion';
      recommendation =
          'Focus on quality study sessions with the Pomodoro technique';
    } else if (correlation < -0.2) {
      interpretation =
          'Warning: Longer study time associated with lower completion';
      recommendation =
          'Review study efficiency - may be spending time on low-priority tasks';
    } else {
      interpretation =
          'Study time alone doesn\'t predict completion - focus on consistency';
      recommendation = 'Break tasks into smaller chunks and use time-blocking';
    }

    return PerformanceCorrelation(
      metric: 'Study Duration vs. Completion',
      correlationCoefficient: correlation,
      interpretation: interpretation,
      recommendation: recommendation,
      dataPoints: List.generate(
        performances.length,
        (i) => {
          'studyMinutes': studyMinutes[i],
          'completionRate': completionRates[i],
          'date': performances[i].date,
        },
      ),
    );
  }

  // CORRELATION ANALYSIS: Consistency vs. Punctuality Improvement
  PerformanceCorrelation analyzeConsistencyVsPunctuality(String studentId) {
    final performances =
        _performanceHistory.where((p) => p.studentId == studentId).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (performances.length < 7) {
      return PerformanceCorrelation(
        metric: 'Consistency vs. Punctuality',
        correlationCoefficient: 0,
        interpretation: 'Insufficient data (need 7+ days)',
        recommendation: 'Build consistent study habits over the next week',
      );
    }

    // Calculate weekly consistency scores and punctuality rates
    final weeklyData = <int, Map<String, dynamic>>{};

    for (var perf in performances) {
      if (!weeklyData.containsKey(perf.weekNumber)) {
        weeklyData[perf.weekNumber] = {
          'consistency': 0.0,
          'punctuality': 0.0,
          'count': 0,
        };
      }

      final metrics = getStudentMetrics(
        studentId,
        days: 7,
      ).where((m) => _getWeekNumber(m.date) == perf.weekNumber).toList();

      final consistency = metrics.isNotEmpty
          ? metrics.map((m) => m.consistencyScore).reduce((a, b) => a + b) /
                metrics.length
          : 0.0;

      weeklyData[perf.weekNumber]!['consistency'] = consistency;
      weeklyData[perf.weekNumber]!['punctuality'] =
          (weeklyData[perf.weekNumber]!['punctuality'] as double) +
          perf.punctualityRate;
      weeklyData[perf.weekNumber]!['count'] =
          (weeklyData[perf.weekNumber]!['count'] as int) + 1;
    }

    // Average punctuality per week
    weeklyData.forEach((week, data) {
      data['punctuality'] = data['punctuality'] / data['count'];
    });

    final consistencyScores = weeklyData.values
        .map((d) => d['consistency'] as double)
        .toList();
    final punctualityRates = weeklyData.values
        .map((d) => d['punctuality'] as double)
        .toList();

    final correlation = _calculateCorrelation(
      consistencyScores,
      punctualityRates,
    );

    String interpretation;
    String recommendation;

    if (correlation > 0.5) {
      interpretation =
          'Strong link: Consistent study blocks lead to better punctuality';
      recommendation =
          'Excellent! Keep your regular study schedule to maintain on-time submissions';
    } else if (correlation > 0.2) {
      interpretation =
          'Moderate improvement in punctuality with consistent time blocks';
      recommendation = 'Strengthen routine by studying at the same time daily';
    } else {
      interpretation = 'Consistency hasn\'t yet improved punctuality';
      recommendation =
          'Focus on time estimation and setting earlier personal deadlines';
    }

    return PerformanceCorrelation(
      metric: 'Consistency vs. Punctuality',
      correlationCoefficient: correlation,
      interpretation: interpretation,
      recommendation: recommendation,
      dataPoints: weeklyData.entries
          .map(
            (e) => {
              'week': e.key,
              'consistency': e.value['consistency'],
              'punctuality': e.value['punctuality'],
            },
          )
          .toList(),
    );
  }

  // CORRELATION ANALYSIS: Cramming Reduction vs. Workload Stability
  PerformanceCorrelation analyzeCrammingVsWorkloadStability(String studentId) {
    final performances =
        _performanceHistory.where((p) => p.studentId == studentId).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (performances.length < 14) {
      return PerformanceCorrelation(
        metric: 'Cramming vs. Workload Stability',
        correlationCoefficient: 0,
        interpretation: 'Insufficient data (need 14+ days)',
        recommendation: 'Avoid cramming by spreading study over multiple days',
      );
    }

    // Split into two-week periods
    final periods = <Map<String, dynamic>>[];
    for (var i = 0; i < performances.length; i += 7) {
      final periodPerfs = performances.skip(i).take(7).toList();
      if (periodPerfs.length < 4) continue;

      final crammingSessions = periodPerfs
          .where((p) => p.hadCrammingSession)
          .length;
      final taskCounts = periodPerfs.map((p) => p.totalTasks).toList();

      // Calculate standard deviation (workload stability - lower is more stable)
      final avgTasks = taskCounts.reduce((a, b) => a + b) / taskCounts.length;
      final variance =
          taskCounts
              .map((t) => math.pow(t - avgTasks, 2))
              .reduce((a, b) => a + b) /
          taskCounts.length;
      final stability = 100 - (math.sqrt(variance) * 10).clamp(0, 100);

      periods.add({
        'crammingSessions': crammingSessions.toDouble(),
        'stability': stability,
      });
    }

    final crammingCounts = periods
        .map((p) => p['crammingSessions'] as double)
        .toList();
    final stabilityScores = periods
        .map((p) => p['stability'] as double)
        .toList();

    final correlation = _calculateCorrelation(crammingCounts, stabilityScores);

    String interpretation;
    String recommendation;

    if (correlation < -0.4) {
      interpretation =
          'Less cramming strongly correlates with stable, balanced workload';
      recommendation =
          'Great progress! Your distributed study approach is working';
    } else if (correlation < -0.2) {
      interpretation = 'Reducing cramming shows some workload improvement';
      recommendation = 'Continue breaking tasks across multiple days';
    } else {
      interpretation = 'Cramming sessions causing workload instability';
      recommendation =
          'Use task chunking and start assignments earlier to avoid spikes';
    }

    return PerformanceCorrelation(
      metric: 'Cramming vs. Workload Stability',
      correlationCoefficient: correlation,
      interpretation: interpretation,
      recommendation: recommendation,
      dataPoints: periods,
    );
  }

  // CORRELATION ANALYSIS: Before vs. After Recommendations
  Map<String, dynamic> analyzeRecommendationImpact(String studentId) {
    final performances =
        _performanceHistory.where((p) => p.studentId == studentId).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (performances.length < 10) {
      return {
        'hasEnoughData': false,
        'message': 'Need 10+ days to analyze recommendation impact',
      };
    }

    // Split data in half: before (first half) vs after (second half)
    final midPoint = performances.length ~/ 2;
    final before = performances.sublist(0, midPoint);
    final after = performances.sublist(midPoint);

    // Calculate metrics before recommendations
    final beforeMetrics = _calculatePeriodMetrics(before);

    // Calculate metrics after recommendations
    final afterMetrics = _calculatePeriodMetrics(after);

    // Calculate improvements
    final completionImprovement =
        afterMetrics['completionRate']! - beforeMetrics['completionRate']!;
    final punctualityImprovement =
        afterMetrics['punctualityRate']! - beforeMetrics['punctualityRate']!;
    final consistencyImprovement =
        afterMetrics['consistency']! - beforeMetrics['consistency']!;
    final crammingReduction =
        beforeMetrics['crammingRate']! - afterMetrics['crammingRate']!;

    return {
      'hasEnoughData': true,
      'before': beforeMetrics,
      'after': afterMetrics,
      'improvements': {
        'completion': completionImprovement,
        'punctuality': punctualityImprovement,
        'consistency': consistencyImprovement,
        'crammingReduction': crammingReduction,
      },
      'overallImprovement':
          (completionImprovement +
              punctualityImprovement +
              consistencyImprovement +
              crammingReduction) /
          4,
      'interpretation': _interpretImpact(
        completionImprovement,
        punctualityImprovement,
        consistencyImprovement,
        crammingReduction,
      ),
    };
  }

  Map<String, double> _calculatePeriodMetrics(
    List<AcademicPerformance> performances,
  ) {
    final avgCompletion =
        performances.map((p) => p.completionRate).reduce((a, b) => a + b) /
        performances.length;
    final avgPunctuality =
        performances.map((p) => p.punctualityRate).reduce((a, b) => a + b) /
        performances.length;
    final crammingRate =
        (performances.where((p) => p.hadCrammingSession).length /
            performances.length) *
        100;

    // Get consistency from metrics
    final studentId = performances.first.studentId;
    final metrics = getStudentMetrics(studentId, days: performances.length * 2);
    final avgConsistency = metrics.isNotEmpty
        ? metrics.map((m) => m.consistencyScore).reduce((a, b) => a + b) /
              metrics.length
        : 0.0;

    return {
      'completionRate': avgCompletion,
      'punctualityRate': avgPunctuality,
      'consistency': avgConsistency,
      'crammingRate': crammingRate,
    };
  }

  String _interpretImpact(
    double completionChange,
    double punctualityChange,
    double consistencyChange,
    double crammingReduction,
  ) {
    final improvements = [
      if (completionChange > 5) 'Task completion improved',
      if (punctualityChange > 5) 'Submission punctuality improved',
      if (consistencyChange > 5) 'Study consistency improved',
      if (crammingReduction > 10) 'Cramming significantly reduced',
    ];

    if (improvements.isEmpty) {
      return 'Continue following recommendations - changes take time';
    } else if (improvements.length == 1) {
      return '${improvements[0]} after applying recommendations';
    } else {
      return 'Multiple improvements: ${improvements.join(', ')}';
    }
  }

  // Calculate Pearson correlation coefficient
  double _calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return 0;

    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;

    double numerator = 0;
    double sumXSquared = 0;
    double sumYSquared = 0;

    for (var i = 0; i < n; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      numerator += diffX * diffY;
      sumXSquared += diffX * diffX;
      sumYSquared += diffY * diffY;
    }

    final denominator = math.sqrt(sumXSquared * sumYSquared);
    return denominator == 0 ? 0 : numerator / denominator;
  }

  // Get comprehensive academic progress report
  Map<String, dynamic> getAcademicProgressReport(String studentId) {
    return {
      'studyVsCompletion': analyzeStudyDurationVsCompletion(studentId),
      'consistencyVsPunctuality': analyzeConsistencyVsPunctuality(studentId),
      'crammingVsStability': analyzeCrammingVsWorkloadStability(studentId),
      'recommendationImpact': analyzeRecommendationImpact(studentId),
      'performanceHistory':
          _performanceHistory.where((p) => p.studentId == studentId).toList()
            ..sort((a, b) => b.date.compareTo(a.date)),
    };
  }
}
