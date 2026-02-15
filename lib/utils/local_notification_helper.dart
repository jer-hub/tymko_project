import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';

/// Handles system-level (phone) push notifications for task deadlines.
class LocalNotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Channel IDs
  static const String _overdueChannelId = 'deadline_overdue';
  static const String _upcomingChannelId = 'deadline_upcoming';

  /// Initialize the notification plugin. Call once at app startup.
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permission for scheduled notifications
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Could navigate to the specific task here if needed
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Schedule all deadline notifications for a student's tasks.
  /// Cancels previous notifications first to avoid duplicates.
  static Future<void> scheduleAllDeadlineNotifications(
    List<Task> tasks, {
    String? studentId,
  }) async {
    if (!_initialized) return;

    // Cancel all existing deadline notifications
    await cancelAllDeadlineNotifications();

    final now = DateTime.now();
    int notificationId = 1000; // Start IDs at 1000 for deadline notifications

    final filteredTasks = tasks.where((task) {
      if (task.isCompleted) return false;
      if (studentId != null && task.studentId != studentId) return false;
      return true;
    });

    for (final task in filteredTasks) {
      final deadline = task.endTime ?? task.dateTime;

      // --- Missed deadline: show immediately ---
      if (deadline.isBefore(now)) {
        await _showImmediateNotification(
          id: notificationId++,
          title: '⚠️ Missed Deadline',
          body: '"${task.title}" was due ${_formatTimeAgo(now.difference(deadline))}',
          channelId: _overdueChannelId,
          channelName: 'Missed Deadlines',
          payload: task.id,
          color: Colors.red,
        );
        continue;
      }

      // --- 1 hour before deadline ---
      final oneHourBefore = deadline.subtract(const Duration(hours: 1));
      if (oneHourBefore.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId++,
          title: '⏰ Deadline in 1 hour',
          body: '"${task.title}" is due at ${_formatTime(deadline)}',
          scheduledTime: oneHourBefore,
          channelId: _upcomingChannelId,
          channelName: 'Upcoming Deadlines',
          payload: task.id,
          color: Colors.orange,
        );
      }

      // --- 24 hours before deadline ---
      final oneDayBefore = deadline.subtract(const Duration(hours: 24));
      if (oneDayBefore.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId++,
          title: '📅 Deadline tomorrow',
          body: '"${task.title}" is due ${_formatDateTime(deadline)}',
          scheduledTime: oneDayBefore,
          channelId: _upcomingChannelId,
          channelName: 'Upcoming Deadlines',
          payload: task.id,
          color: Colors.amber,
        );
      }

      // --- At deadline time (missed alert) ---
      if (deadline.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId++,
          title: '🚨 Deadline now!',
          body: '"${task.title}" is due right now!',
          scheduledTime: deadline,
          channelId: _overdueChannelId,
          channelName: 'Missed Deadlines',
          payload: task.id,
          color: Colors.red,
        );
      }
    }
  }

  /// Show an immediate notification (for already-overdue tasks).
  static Future<void> _showImmediateNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? payload,
    Color? color,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifications for $channelName',
      importance: Importance.high,
      priority: Priority.high,
      color: color,
      styleInformation: BigTextStyleInformation(body),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Schedule a notification at a specific time.
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    required String channelName,
    String? payload,
    Color? color,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifications for $channelName',
      importance: Importance.high,
      priority: Priority.high,
      color: color,
      styleInformation: BigTextStyleInformation(body),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancel all deadline notifications.
  static Future<void> cancelAllDeadlineNotifications() async {
    await _plugin.cancelAll();
  }

  /// Show a one-off test notification (for debugging).
  static Future<void> showTestNotification() async {
    await _showImmediateNotification(
      id: 0,
      title: 'Tymko Notifications Active',
      body: 'You will be notified about upcoming and missed deadlines.',
      channelId: _upcomingChannelId,
      channelName: 'Upcoming Deadlines',
    );
  }

  // --- Formatting helpers ---

  static String _formatTimeAgo(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${_formatTime(dt)}';
  }
}
