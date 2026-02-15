import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../utils/deadline_notification_service.dart';

class DeadlineNotificationBanner extends StatefulWidget {
  final String studentId;

  const DeadlineNotificationBanner({super.key, required this.studentId});

  @override
  State<DeadlineNotificationBanner> createState() =>
      _DeadlineNotificationBannerState();
}

class _DeadlineNotificationBannerState
    extends State<DeadlineNotificationBanner> {
  final Set<String> _dismissedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final notifications = taskProvider.getDeadlineNotifications(
          studentId: widget.studentId,
        );

        // Filter out dismissed notifications
        final activeNotifications = notifications
            .where((n) => !_dismissedTaskIds.contains(n.task.id))
            .toList();

        if (activeNotifications.isEmpty) return const SizedBox.shrink();

        final overdueCount =
            activeNotifications
                .where((n) => n.urgency == DeadlineUrgency.overdue)
                .length;
        final upcomingCount = activeNotifications.length - overdueCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: overdueCount > 0
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildSummaryText(overdueCount, upcomingCount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: overdueCount > 0
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (_dismissedTaskIds.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _dismissedTaskIds.clear();
                        });
                      },
                      child: const Text('Show all', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),

            // Notification cards
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: activeNotifications.length,
                itemBuilder: (context, index) {
                  return _DeadlineCard(
                    notification: activeNotifications[index],
                    onDismiss: () {
                      setState(() {
                        _dismissedTaskIds.add(
                          activeNotifications[index].task.id,
                        );
                      });
                    },
                    onComplete: () {
                      taskProvider.toggleTaskCompletion(
                        activeNotifications[index].task.id,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _buildSummaryText(int overdueCount, int upcomingCount) {
    final parts = <String>[];
    if (overdueCount > 0) {
      parts.add('$overdueCount missed deadline${overdueCount > 1 ? 's' : ''}');
    }
    if (upcomingCount > 0) {
      parts.add(
        '$upcomingCount upcoming deadline${upcomingCount > 1 ? 's' : ''}',
      );
    }
    return parts.join(' · ');
  }
}

class _DeadlineCard extends StatelessWidget {
  final DeadlineNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback onComplete;

  const _DeadlineCard({
    required this.notification,
    required this.onDismiss,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = notification.urgency == DeadlineUrgency.overdue;
    final isDueToday = notification.urgency == DeadlineUrgency.dueToday;
    final deadline = notification.task.endTime ?? notification.task.dateTime;

    final Color cardColor;
    final Color textColor;
    final IconData icon;

    switch (notification.urgency) {
      case DeadlineUrgency.overdue:
        cardColor = Theme.of(context).colorScheme.errorContainer;
        textColor = Theme.of(context).colorScheme.onErrorContainer;
        icon = Icons.warning_amber_rounded;
        break;
      case DeadlineUrgency.dueToday:
        cardColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        icon = Icons.schedule;
        break;
      case DeadlineUrgency.dueTomorrow:
        cardColor = Colors.amber.shade50;
        textColor = Colors.amber.shade900;
        icon = Icons.upcoming;
        break;
      case DeadlineUrgency.dueThisWeek:
        cardColor = Theme.of(context).colorScheme.primaryContainer;
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        icon = Icons.event;
        break;
    }

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        color: cardColor,
        elevation: isOverdue ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOverdue
              ? BorderSide(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showNotificationDetail(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: textColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        notification.urgencyLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onDismiss,
                      child: Icon(Icons.close, size: 14, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    notification.task.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM d, h:mm a').format(deadline),
                      style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.7)),
                    ),
                    if (isOverdue || isDueToday)
                      InkWell(
                        onTap: onComplete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: textColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(BuildContext context) {
    final isOverdue = notification.urgency == DeadlineUrgency.overdue;
    final deadline = notification.task.endTime ?? notification.task.dateTime;
    final task = notification.task;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
              color: isOverdue
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              Icons.access_time,
              'Deadline: ${DateFormat('EEEE, MMM d, y – h:mm a').format(deadline)}',
              context,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              isOverdue ? Icons.error_outline : Icons.hourglass_bottom,
              notification.urgencyLabel,
              context,
              color: isOverdue ? Theme.of(context).colorScheme.error : null,
            ),
            if (task.category != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.category, task.category!, context),
            ],
            if (task.description != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.notes, task.description!, context),
            ],
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.flag,
              'Priority: ${'★' * task.priority}${'☆' * (5 - task.priority)}',
              context,
            ),
            if (task.subtasks.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.checklist,
                'Subtasks: ${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length} done',
                context,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              final taskProvider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              taskProvider.toggleTaskCompletion(task.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text,
    BuildContext context, {
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
