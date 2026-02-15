import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/deadline_notification_service.dart';

/// An optimized, feature-rich task activity view for the parent dashboard.
class ParentTaskActivityView extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ParentTaskActivityView({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ParentTaskActivityView> createState() => _ParentTaskActivityViewState();
}

class _ParentTaskActivityViewState extends State<ParentTaskActivityView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final allTasks = taskProvider.getTasksForStudent(widget.studentId);
        final now = DateTime.now();

        // Categorize tasks
        final overdueTasks = <Task>[];
        final todayTasks = <Task>[];
        final upcomingTasks = <Task>[];
        final completedTasks = <Task>[];

        for (final task in allTasks) {
          if (task.isCompleted) {
            completedTasks.add(task);
            continue;
          }
          final deadline = task.endTime ?? task.dateTime;
          if (deadline.isBefore(now)) {
            overdueTasks.add(task);
          } else if (_isSameDay(deadline, now)) {
            todayTasks.add(task);
          } else {
            upcomingTasks.add(task);
          }
        }

        // Sort
        overdueTasks.sort((a, b) => (a.endTime ?? a.dateTime).compareTo(b.endTime ?? b.dateTime));
        todayTasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        upcomingTasks.sort((a, b) => (a.endTime ?? a.dateTime).compareTo(b.endTime ?? b.dateTime));
        completedTasks.sort((a, b) => (b.completedAt ?? b.dateTime).compareTo(a.completedAt ?? a.dateTime));

        // Deadline notifications
        final deadlineNotifications = taskProvider.getDeadlineNotifications(
          studentId: widget.studentId,
        );

        if (allTasks.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deadline Alerts Banner
            if (deadlineNotifications.isNotEmpty)
              _buildDeadlineAlertsBanner(context, deadlineNotifications),

            if (deadlineNotifications.isNotEmpty) const SizedBox(height: 16),

            // Completion Overview Ring
            _buildCompletionRing(context, allTasks, completedTasks.length),

            const SizedBox(height: 20),

            // Category Breakdown
            if (allTasks.isNotEmpty)
              _buildCategoryBreakdown(context, allTasks),

            const SizedBox(height: 20),

            // Daily Completion Trend
            _buildDailyTrend(context, allTasks),

            const SizedBox(height: 24),

            // Tabbed Task Lists
            const Text(
              'Task Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                tabs: [
                  _buildTab('Today', todayTasks.length),
                  _buildTab('Upcoming', upcomingTasks.length),
                  _buildTab('Overdue', overdueTasks.length,
                      isAlert: overdueTasks.isNotEmpty),
                  _buildTab('Done', completedTasks.length),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tab views (not in a TabBarView since we're in a scroll)
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                switch (_tabController.index) {
                  case 0:
                    return _buildTaskList(context, todayTasks, 'today');
                  case 1:
                    return _buildTaskList(context, upcomingTasks, 'upcoming');
                  case 2:
                    return _buildTaskList(context, overdueTasks, 'overdue');
                  case 3:
                    return _buildTaskList(
                        context, completedTasks.take(20).toList(), 'completed');
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // Deadline Alerts Banner
  // ───────────────────────────────────────────────
  Widget _buildDeadlineAlertsBanner(
      BuildContext context, List<DeadlineNotification> notifications) {
    final overdueCount = notifications
        .where((n) => n.urgency == DeadlineUrgency.overdue)
        .length;
    final urgentCount = notifications
        .where((n) => n.urgency == DeadlineUrgency.dueToday)
        .length;

    final hasOverdue = overdueCount > 0;

    return Card(
      color: hasOverdue
          ? Theme.of(context).colorScheme.errorContainer
          : Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasOverdue
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasOverdue
                    ? Theme.of(context).colorScheme.error
                    : Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasOverdue
                    ? Icons.warning_amber_rounded
                    : Icons.notifications_active,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasOverdue
                        ? 'Attention Needed'
                        : 'Upcoming Deadlines',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: hasOverdue
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildAlertSummary(overdueCount, urgentCount, notifications.length),
                    style: TextStyle(
                      fontSize: 13,
                      color: hasOverdue
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasOverdue
                    ? Theme.of(context).colorScheme.error
                    : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${notifications.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildAlertSummary(int overdue, int urgent, int total) {
    final parts = <String>[];
    if (overdue > 0) parts.add('$overdue missed');
    if (urgent > 0) parts.add('$urgent due today');
    final others = total - overdue - urgent;
    if (others > 0) parts.add('$others upcoming');
    return '${widget.studentName} has ${parts.join(', ')}';
  }

  // ───────────────────────────────────────────────
  // Completion Ring
  // ───────────────────────────────────────────────
  Widget _buildCompletionRing(
      BuildContext context, List<Task> allTasks, int completedCount) {
    final total = allTasks.length;
    final rate = total > 0 ? completedCount / total : 0.0;
    final now = DateTime.now();

    // Tasks completed on time vs late
    int onTimeCount = 0;
    int lateCount = 0;
    for (final task in allTasks.where((t) => t.isCompleted)) {
      final deadline = task.endTime ?? task.dateTime;
      if (task.completedAt != null && task.completedAt!.isAfter(deadline)) {
        lateCount++;
      } else {
        onTimeCount++;
      }
    }

    // Calculate streak
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final dayTasks = allTasks.where((t) =>
          _isSameDay(t.dateTime, day) && t.isCompleted);
      if (dayTasks.isNotEmpty) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Animated ring
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: rate,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        rate > 0.7
                            ? Colors.green
                            : rate > 0.4
                                ? Colors.orange
                                : Colors.red,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(rate * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedCount/$total',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Completion Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMiniStat(
                    Icons.check_circle,
                    Colors.green,
                    'On time',
                    '$onTimeCount',
                  ),
                  const SizedBox(height: 6),
                  _buildMiniStat(
                    Icons.schedule,
                    Colors.orange,
                    'Completed late',
                    '$lateCount',
                  ),
                  const SizedBox(height: 6),
                  _buildMiniStat(
                    Icons.local_fire_department,
                    Colors.deepOrange,
                    'Day streak',
                    '$streak',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────
  // Category Breakdown
  // ───────────────────────────────────────────────
  Widget _buildCategoryBreakdown(BuildContext context, List<Task> tasks) {
    final categoryMap = <String, _CategoryStats>{};
    for (final task in tasks) {
      final cat = task.category ?? 'Uncategorized';
      categoryMap.putIfAbsent(cat, () => _CategoryStats());
      categoryMap[cat]!.total++;
      if (task.isCompleted) categoryMap[cat]!.completed++;
    }

    final entries = categoryMap.entries.toList()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Horizontal stacked bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 20,
                child: Row(
                  children: entries.asMap().entries.map((e) {
                    final idx = e.key;
                    final entry = e.value;
                    final fraction = entry.value.total / tasks.length;
                    return Expanded(
                      flex: (fraction * 1000).round(),
                      child: Container(
                        color: colors[idx % colors.length],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Legend + stats
            ...entries.asMap().entries.map((e) {
              final idx = e.key;
              final entry = e.value;
              final color = colors[idx % colors.length];
              final rate = entry.value.total > 0
                  ? (entry.value.completed / entry.value.total * 100).toInt()
                  : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      '${entry.value.completed}/${entry.value.total}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$rate%',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rate >= 70
                              ? Colors.green
                              : rate >= 40
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Daily Completion Trend (last 14 days)
  // ───────────────────────────────────────────────
  Widget _buildDailyTrend(BuildContext context, List<Task> allTasks) {
    final now = DateTime.now();
    const days = 14;
    final dailyData = <_DayData>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      int total = 0;
      int completed = 0;
      for (final task in allTasks) {
        if (_isSameDay(task.dateTime, day)) {
          total++;
          if (task.isCompleted) completed++;
        }
      }
      dailyData.add(_DayData(day: day, total: total, completed: completed));
    }

    final maxTasks = dailyData
        .map((d) => d.total)
        .fold(0, (a, b) => a > b ? a : b);
    final barMax = maxTasks > 0 ? maxTasks : 1;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2-Week Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${allTasks.where((t) => t.isCompleted && t.completedAt != null && t.completedAt!.isAfter(now.subtract(const Duration(days: 14)))).length} done',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailyData.map((d) {
                  final totalHeight = d.total / barMax;
                  final completedHeight =
                      d.total > 0 ? d.completed / barMax : 0.0;
                  final isToday = _isSameDay(d.day, now);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (d.total > 0)
                            Text(
                              '${d.completed}',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: d.completed == d.total
                                    ? Colors.green
                                    : Colors.grey[600],
                              ),
                            ),
                          const SizedBox(height: 2),
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: totalHeight > 0 ? totalHeight : 0.05,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.grey.shade200,
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: d.total > 0
                                        ? completedHeight / totalHeight
                                        : 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: d.completed == d.total && d.total > 0
                                            ? Colors.green
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(d.day),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(Colors.grey.shade300, 'Total'),
                const SizedBox(width: 16),
                _legendDot(Theme.of(context).colorScheme.primary, 'Completed'),
                const SizedBox(width: 16),
                _legendDot(Colors.green, 'All done'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  // ───────────────────────────────────────────────
  // Task List per Tab
  // ───────────────────────────────────────────────
  Widget _buildTaskList(BuildContext context, List<Task> tasks, String type) {
    if (tasks.isEmpty) {
      return _buildEmptyTab(type);
    }

    return Column(
      children: tasks.map((task) => _buildTaskCard(context, task, type)).toList(),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, String type) {
    final deadline = task.endTime ?? task.dateTime;
    final now = DateTime.now();
    final isOverdue = !task.isCompleted && deadline.isBefore(now);
    final priority = task.priority;

    final priorityColor = priority >= 4
        ? Colors.red
        : priority >= 3
            ? Colors.orange
            : Colors.grey;

    // Subtask progress
    final subtasksDone = task.subtasks.where((s) => s.isCompleted).length;
    final subtasksTotal = task.subtasks.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isOverdue
            ? BorderSide(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
                width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: priority + title + status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority indicator
                Container(
                  width: 4,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? Colors.grey
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(context, task, type, isOverdue),
              ],
            ),

            const SizedBox(height: 10),

            // Bottom info row
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                // Date/time
                _buildInfoChip(
                  Icons.calendar_today,
                  DateFormat('MMM d').format(deadline),
                ),
                _buildInfoChip(
                  Icons.access_time,
                  DateFormat('h:mm a').format(deadline),
                ),

                // Category
                if (task.category != null)
                  _buildInfoChip(Icons.label_outline, task.category!),

                // Priority
                _buildInfoChip(
                  Icons.flag,
                  '${'★' * priority}${'☆' * (5 - priority)}',
                  color: priorityColor,
                ),

                // Subtasks
                if (subtasksTotal > 0)
                  _buildInfoChip(
                    Icons.checklist,
                    '$subtasksDone/$subtasksTotal',
                    color: subtasksDone == subtasksTotal
                        ? Colors.green
                        : Colors.grey[700],
                  ),

                // Deadline status
                if (isOverdue)
                  _buildInfoChip(
                    Icons.warning_amber,
                    _formatOverdueTime(now.difference(deadline)),
                    color: Theme.of(context).colorScheme.error,
                  ),

                // Completed time
                if (task.isCompleted && task.completedAt != null)
                  _buildInfoChip(
                    Icons.done_all,
                    'Done ${_formatTimeAgo(task.completedAt!)}',
                    color: Colors.green,
                  ),
              ],
            ),

            // Subtask progress bar
            if (subtasksTotal > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: subtasksDone / subtasksTotal,
                  minHeight: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    subtasksDone == subtasksTotal ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
      BuildContext context, Task task, String type, bool isOverdue) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (task.isCompleted) {
      // Check if it was late
      final deadline = task.endTime ?? task.dateTime;
      final isLate = task.completedAt != null && task.completedAt!.isAfter(deadline);
      bg = isLate ? Colors.orange.shade100 : Colors.green.shade100;
      fg = isLate ? Colors.orange.shade800 : Colors.green.shade800;
      label = isLate ? 'Late' : 'Done';
      icon = isLate ? Icons.schedule : Icons.check_circle;
    } else if (isOverdue) {
      bg = Theme.of(context).colorScheme.errorContainer;
      fg = Theme.of(context).colorScheme.onErrorContainer;
      label = 'Overdue';
      icon = Icons.warning_amber_rounded;
    } else {
      bg = Theme.of(context).colorScheme.primaryContainer;
      fg = Theme.of(context).colorScheme.onPrimaryContainer;
      label = 'Pending';
      icon = Icons.pending_actions;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color ?? Colors.grey[600]),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color ?? Colors.grey[600],
            fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────
  // Tab Helper
  // ───────────────────────────────────────────────
  Widget _buildTab(String label, int count, {bool isAlert = false}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isAlert
                    ? Colors.red
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isAlert ? Colors.white : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Empty States
  // ───────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.task_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '${widget.studentName} hasn\'t created any tasks yet.',
              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks will appear here once they start planning.',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String type) {
    IconData icon;
    String message;

    switch (type) {
      case 'today':
        icon = Icons.today;
        message = 'No tasks scheduled for today';
        break;
      case 'upcoming':
        icon = Icons.upcoming;
        message = 'No upcoming tasks';
        break;
      case 'overdue':
        icon = Icons.check_circle_outline;
        message = 'No overdue tasks — great job!';
        break;
      case 'completed':
        icon = Icons.hourglass_empty;
        message = 'No completed tasks yet';
        break;
      default:
        icon = Icons.inbox;
        message = 'No tasks';
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Utilities
  // ───────────────────────────────────────────────
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatOverdueTime(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d overdue';
    if (d.inHours > 0) return '${d.inHours}h overdue';
    return '${d.inMinutes}m overdue';
  }

  String _formatTimeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'just now';
  }
}

// ─── Helper Classes ─────────────────────────────
class _CategoryStats {
  int total = 0;
  int completed = 0;
}

class _DayData {
  final DateTime day;
  final int total;
  final int completed;

  _DayData({required this.day, required this.total, required this.completed});
}
