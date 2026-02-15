import '../models/task.dart';

enum DeadlineUrgency { overdue, dueToday, dueTomorrow, dueThisWeek }

class DeadlineNotification {
  final Task task;
  final DeadlineUrgency urgency;
  final Duration timeRemaining;

  DeadlineNotification({
    required this.task,
    required this.urgency,
    required this.timeRemaining,
  });

  String get urgencyLabel {
    switch (urgency) {
      case DeadlineUrgency.overdue:
        final days = timeRemaining.inDays.abs();
        final hours = timeRemaining.inHours.abs() % 24;
        if (days > 0) {
          return 'Overdue by $days day${days > 1 ? 's' : ''}';
        } else if (hours > 0) {
          return 'Overdue by $hours hour${hours > 1 ? 's' : ''}';
        } else {
          return 'Overdue by ${timeRemaining.inMinutes.abs()} min';
        }
      case DeadlineUrgency.dueToday:
        final hours = timeRemaining.inHours;
        final minutes = timeRemaining.inMinutes % 60;
        if (hours > 0) {
          return 'Due in $hours hour${hours > 1 ? 's' : ''}';
        } else {
          return 'Due in $minutes minute${minutes > 1 ? 's' : ''}';
        }
      case DeadlineUrgency.dueTomorrow:
        return 'Due tomorrow';
      case DeadlineUrgency.dueThisWeek:
        final days = timeRemaining.inDays;
        return 'Due in $days day${days > 1 ? 's' : ''}';
    }
  }
}

class DeadlineNotificationService {
  /// Get all deadline notifications for a student, sorted by urgency.
  static List<DeadlineNotification> getNotifications(
    List<Task> tasks, {
    String? studentId,
  }) {
    final now = DateTime.now();
    final notifications = <DeadlineNotification>[];

    final filteredTasks = tasks.where((task) {
      if (task.isCompleted) return false;
      if (studentId != null && task.studentId != studentId) return false;
      return true;
    });

    for (final task in filteredTasks) {
      final deadline = task.endTime ?? task.dateTime;
      final difference = deadline.difference(now);

      if (difference.isNegative) {
        // Overdue
        notifications.add(DeadlineNotification(
          task: task,
          urgency: DeadlineUrgency.overdue,
          timeRemaining: difference,
        ));
      } else if (_isSameDay(deadline, now)) {
        // Due today
        notifications.add(DeadlineNotification(
          task: task,
          urgency: DeadlineUrgency.dueToday,
          timeRemaining: difference,
        ));
      } else if (_isSameDay(deadline, now.add(const Duration(days: 1)))) {
        // Due tomorrow
        notifications.add(DeadlineNotification(
          task: task,
          urgency: DeadlineUrgency.dueTomorrow,
          timeRemaining: difference,
        ));
      } else if (difference.inDays <= 7) {
        // Due this week
        notifications.add(DeadlineNotification(
          task: task,
          urgency: DeadlineUrgency.dueThisWeek,
          timeRemaining: difference,
        ));
      }
    }

    // Sort: overdue first, then by urgency, then by time remaining
    notifications.sort((a, b) {
      final urgencyOrder = a.urgency.index.compareTo(b.urgency.index);
      if (urgencyOrder != 0) return urgencyOrder;
      return a.timeRemaining.compareTo(b.timeRemaining);
    });

    return notifications;
  }

  /// Get only overdue notifications.
  static List<DeadlineNotification> getOverdueNotifications(
    List<Task> tasks, {
    String? studentId,
  }) {
    return getNotifications(tasks, studentId: studentId)
        .where((n) => n.urgency == DeadlineUrgency.overdue)
        .toList();
  }

  /// Get only upcoming (non-overdue) notifications.
  static List<DeadlineNotification> getUpcomingNotifications(
    List<Task> tasks, {
    String? studentId,
  }) {
    return getNotifications(tasks, studentId: studentId)
        .where((n) => n.urgency != DeadlineUrgency.overdue)
        .toList();
  }

  /// Get count summary for quick display.
  static Map<DeadlineUrgency, int> getNotificationCounts(
    List<Task> tasks, {
    String? studentId,
  }) {
    final notifications = getNotifications(tasks, studentId: studentId);
    final counts = <DeadlineUrgency, int>{};
    for (final n in notifications) {
      counts[n.urgency] = (counts[n.urgency] ?? 0) + 1;
    }
    return counts;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
