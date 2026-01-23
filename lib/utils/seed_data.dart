import 'dart:math';
import '../models/task.dart';
import '../models/study_session.dart';
import '../models/reflection.dart';
import '../models/academic_performance.dart';
import '../models/behavior_metrics.dart';
import '../providers/task_provider.dart';
import '../providers/behavior_tracking_provider.dart';

class SeedData {
  static final Random _random = Random();

  static void seedAll(
    TaskProvider taskProvider,
    BehaviorTrackingProvider behaviorProvider, {
    String studentId = 'student1',
  }) {
    _seedTasks(taskProvider, studentId);
    _seedStudySessions(behaviorProvider, studentId);
    _seedReflections(behaviorProvider, studentId);
    _seedAcademicPerformance(behaviorProvider, studentId);
    _seedBehaviorMetrics(behaviorProvider, studentId);
  }

  static void _seedTasks(TaskProvider taskProvider, String studentId) {
    final now = DateTime.now();
    final tasks = <Task>[];

    // Past completed tasks (last 30 days)
    for (int i = 1; i <= 30; i++) {
      final date = now.subtract(Duration(days: i));
      final numTasks = _random.nextInt(4) + 2; // 2-5 tasks per day

      for (int j = 0; j < numTasks; j++) {
        final hour = _random.nextInt(12) + 8; // 8 AM - 8 PM
        final taskDate = DateTime(date.year, date.month, date.day, hour);
        final category = _getRandomCategory();
        final isCompleted = _random.nextDouble() > 0.2; // 80% completion rate

        // Some tasks completed late
        final isLate = isCompleted && _random.nextDouble() > 0.7;
        final completedAt = isCompleted
            ? (isLate
                  ? taskDate.add(Duration(hours: _random.nextInt(24) + 1))
                  : taskDate.subtract(Duration(hours: _random.nextInt(3))))
            : null;

        tasks.add(
          Task(
            id: 'task_${i}_$j',
            studentId: studentId,
            title: _getTaskTitle(category),
            description: _getTaskDescription(category),
            dateTime: taskDate,
            category: category,
            isCompleted: isCompleted,
            completedAt: completedAt,
            priority: _random.nextInt(5) + 1,
            estimatedDuration: (_random.nextInt(6) + 1) * 15, // 15-90 min
            subtasks: _random.nextBool() ? _generateSubtasks(isCompleted) : [],
          ),
        );
      }
    }

    // Today's tasks (mix of completed and pending)
    for (int i = 0; i < 6; i++) {
      final hour = 8 + i * 2;
      final taskDate = DateTime(now.year, now.month, now.day, hour);
      final category = _getRandomCategory();
      final isCompleted = i < 3; // First 3 completed

      tasks.add(
        Task(
          id: 'today_$i',
          studentId: studentId,
          title: _getTaskTitle(category),
          description: _getTaskDescription(category),
          dateTime: taskDate,
          category: category,
          isCompleted: isCompleted,
          completedAt: isCompleted
              ? taskDate.add(const Duration(minutes: 30))
              : null,
          priority: _random.nextInt(5) + 1,
          estimatedDuration: (_random.nextInt(4) + 1) * 15,
          subtasks: _generateSubtasks(isCompleted),
        ),
      );
    }

    // Future tasks (next 14 days)
    for (int i = 1; i <= 14; i++) {
      final date = now.add(Duration(days: i));
      final numTasks = _random.nextInt(3) + 1; // 1-3 tasks per day

      for (int j = 0; j < numTasks; j++) {
        final hour = _random.nextInt(10) + 8;
        final taskDate = DateTime(date.year, date.month, date.day, hour);
        final category = _getRandomCategory();

        tasks.add(
          Task(
            id: 'future_${i}_$j',
            studentId: studentId,
            title: _getTaskTitle(category),
            description: _getTaskDescription(category),
            dateTime: taskDate,
            category: category,
            isCompleted: false,
            priority: _random.nextInt(5) + 1,
            estimatedDuration: (_random.nextInt(6) + 1) * 15,
            subtasks: _generateSubtasks(false),
            isRecurring: j == 0 && i % 3 == 0,
            recurringPattern: j == 0 && i % 3 == 0 ? 'weekly' : null,
          ),
        );
      }
    }

    // Overdue tasks
    for (int i = 1; i <= 3; i++) {
      final date = now.subtract(Duration(days: i));
      final hour = _random.nextInt(8) + 10;
      final taskDate = DateTime(date.year, date.month, date.day, hour);
      final category = _getRandomCategory();

      tasks.add(
        Task(
          id: 'overdue_$i',
          studentId: studentId,
          title: _getTaskTitle(category),
          description: _getTaskDescription(category),
          dateTime: taskDate,
          category: category,
          isCompleted: false,
          priority: 4 + _random.nextInt(2), // High priority
          estimatedDuration: (_random.nextInt(4) + 2) * 15,
        ),
      );
    }

    // Add all tasks to provider
    for (var task in tasks) {
      taskProvider.addTask(task);
    }
  }

  static void _seedStudySessions(
    BehaviorTrackingProvider provider,
    String studentId,
  ) {
    final now = DateTime.now();

    for (int i = 1; i <= 30; i++) {
      final date = now.subtract(Duration(days: i));
      final numSessions = _random.nextInt(4) + 1; // 1-4 sessions per day

      for (int j = 0; j < numSessions; j++) {
        final hour = 9 + j * 3;
        final startTime = DateTime(date.year, date.month, date.day, hour);
        final targetMinutes = 25; // Pomodoro
        final actualMinutes = targetMinutes + _random.nextInt(10) - 5;
        final endTime = startTime.add(Duration(minutes: actualMinutes));

        provider.addStudySession(
          StudySession(
            id: 'session_${i}_$j',
            taskId: 'task_${i}_$j',
            startTime: startTime,
            endTime: endTime,
            targetDuration: Duration(minutes: targetMinutes),
            actualDuration: Duration(minutes: actualMinutes),
            completed: true,
            breakCount: _random.nextInt(2),
            sessionType: 'pomodoro',
          ),
        );
      }
    }
  }

  static void _seedReflections(
    BehaviorTrackingProvider provider,
    String studentId,
  ) {
    final now = DateTime.now();
    final completions = [
      'Finished math homework and studied for chemistry test',
      'Completed reading assignment and started project outline',
      'Reviewed notes and practiced coding exercises',
      'Worked on essay draft and prepared presentation slides',
      'Studied vocabulary and completed practice problems',
    ];

    final challenges = [
      'Had trouble focusing on long reading assignment',
      'Struggled with time management between tasks',
      'Found the math concepts difficult to understand',
      'Got distracted by social media a few times',
      'Felt overwhelmed by multiple deadlines',
    ];

    final improvements = [
      'Will try Pomodoro technique more consistently',
      'Need to start tasks earlier to avoid rushing',
      'Should ask teacher for help on difficult topics',
      'Plan to use website blocker during study time',
      'Going to break large tasks into smaller chunks',
    ];

    for (int i = 1; i <= 20; i++) {
      final date = now.subtract(Duration(days: i));

      provider.addReflection(
        Reflection(
          id: 'reflection_$i',
          studentId: studentId,
          date: DateTime(date.year, date.month, date.day, 20),
          completedToday: completions[_random.nextInt(completions.length)],
          challenges: challenges[_random.nextInt(challenges.length)],
          improvements: improvements[_random.nextInt(improvements.length)],
          productivityRating: _random.nextInt(3) + 3, // 3-5 rating
        ),
      );
    }
  }

  static void _seedAcademicPerformance(
    BehaviorTrackingProvider provider,
    String studentId,
  ) {
    final now = DateTime.now();

    for (int i = 1; i <= 12; i++) {
      // Last 12 weeks
      final weekDate = now.subtract(Duration(days: i * 7));
      final totalTasks = _random.nextInt(15) + 20; // 20-35 tasks/week
      final completedTasks = (totalTasks * (0.7 + _random.nextDouble() * 0.25))
          .round();
      final onTimeTasks = (completedTasks * (0.6 + _random.nextDouble() * 0.3))
          .round();

      provider.performanceHistory.add(
        AcademicPerformance(
          id: 'perf_$i',
          studentId: studentId,
          date: weekDate,
          totalTasks: totalTasks,
          completedTasks: completedTasks,
          onTimeTasks: onTimeTasks,
          lateTasks: completedTasks - onTimeTasks,
          totalStudyTime: Duration(
            minutes: _random.nextInt(600) + 600,
          ), // 10-20 hours
          averageTaskScore: 70 + _random.nextDouble() * 25, // 70-95
          consecutiveOnTimeDays: _random.nextInt(7),
          hadCrammingSession: _random.nextBool(),
          weekNumber: _getWeekNumber(weekDate),
        ),
      );
    }
  }

  static void _seedBehaviorMetrics(
    BehaviorTrackingProvider provider,
    String studentId,
  ) {
    final now = DateTime.now();

    for (int i = 1; i <= 30; i++) {
      final date = now.subtract(Duration(days: i));
      final tasksCompleted = _random.nextInt(4) + 2;
      final tasksCreated = tasksCompleted + _random.nextInt(3);
      final tasksMissed = _random.nextDouble() > 0.8 ? _random.nextInt(2) : 0;

      provider.dailyMetrics.add(
        BehaviorMetrics(
          studentId: studentId,
          date: DateTime(date.year, date.month, date.day),
          tasksCompleted: tasksCompleted,
          tasksCreated: tasksCreated,
          tasksMissed: tasksMissed,
          totalStudyTime: Duration(
            minutes: _random.nextInt(180) + 60,
          ), // 1-4 hours
          pomodoroSessions: _random.nextInt(6) + 2, // 2-7 sessions
          procrastinationCount: _random.nextInt(3),
          consistencyScore: 60 + _random.nextDouble() * 35, // 60-95%
          peakProductivityHours: [
            _random.nextInt(4) + 9, // Morning: 9-12
            _random.nextInt(4) + 14, // Afternoon: 14-17
          ],
        ),
      );
    }
  }

  // Helper methods
  static String _getRandomCategory() {
    final categories = [
      'Study',
      'Assignment',
      'Project',
      'Exam Prep',
      'Reading',
      'Practice',
      'Other',
    ];
    return categories[_random.nextInt(categories.length)];
  }

  static String _getTaskTitle(String category) {
    final titles = {
      'Study': [
        'Review Chapter 5 Notes',
        'Study for Math Quiz',
        'Go over Physics Formulas',
        'Memorize Biology Terms',
        'Review History Timeline',
      ],
      'Assignment': [
        'Complete Math Worksheet',
        'Finish English Essay',
        'Submit Science Lab Report',
        'Answer Reading Questions',
        'Complete Problem Set',
      ],
      'Project': [
        'Start Science Fair Project',
        'Work on Group Presentation',
        'Research Paper Draft',
        'Build Model for Class',
        'Create Poster Board',
      ],
      'Exam Prep': [
        'Practice Exam Questions',
        'Create Study Guide',
        'Review Past Tests',
        'Flash Card Practice',
        'Mock Exam Practice',
      ],
      'Reading': [
        'Read Chapter 3',
        'Finish Novel Assignment',
        'Read Article for Class',
        'Complete Reading Log',
        'Review Study Materials',
      ],
      'Practice': [
        'Math Practice Problems',
        'Coding Exercise',
        'Language Practice',
        'Music Practice',
        'Sports Training',
      ],
      'Other': [
        'Organize Study Space',
        'Plan Week Schedule',
        'Check Assignment Calendar',
        'Email Teacher Question',
        'Prepare Materials',
      ],
    };

    final categoryTitles = titles[category] ?? titles['Other']!;
    return categoryTitles[_random.nextInt(categoryTitles.length)];
  }

  static String _getTaskDescription(String category) {
    final descriptions = [
      'Make sure to review all key concepts',
      'Focus on understanding the main ideas',
      'Take detailed notes while working',
      'Don\'t forget to check the rubric',
      'Ask questions if anything is unclear',
      'Break this down into smaller steps',
      'Set a timer to stay focused',
      'Review completed work before submitting',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  static List<Subtask> _generateSubtasks(bool parentCompleted) {
    if (_random.nextDouble() > 0.5) return []; // 50% have subtasks

    final numSubtasks = _random.nextInt(3) + 2; // 2-4 subtasks
    final subtasks = <Subtask>[];

    final subtaskTitles = [
      'Read materials',
      'Take notes',
      'Complete exercises',
      'Review answers',
      'Organize information',
      'Create summary',
      'Practice problems',
      'Check for errors',
    ];

    for (int i = 0; i < numSubtasks; i++) {
      final isCompleted = parentCompleted
          ? _random.nextDouble() >
                0.2 // 80% completed if parent is
          : false;

      subtasks.add(
        Subtask(
          id: 'subtask_${DateTime.now().millisecondsSinceEpoch}_$i',
          title: subtaskTitles[_random.nextInt(subtaskTitles.length)],
          isCompleted: isCompleted,
        ),
      );
    }

    return subtasks;
  }

  static int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
