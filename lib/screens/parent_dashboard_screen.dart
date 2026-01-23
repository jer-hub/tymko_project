import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/behavior_tracking_provider.dart';
import '../models/behavior_metrics.dart';
import 'academic_progress_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ParentDashboardScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.studentName}\'s Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Switch Role',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Consumer2<TaskProvider, BehaviorTrackingProvider>(
        builder: (context, taskProvider, behaviorProvider, child) {
          final studentTasks = taskProvider.getTasksForStudent(
            widget.studentId,
          );
          final completedTasks = taskProvider.getCompletedTasksCountForStudent(
            widget.studentId,
          );
          final totalTasks = taskProvider.getTotalTasksCountForStudent(
            widget.studentId,
          );
          final completionRate = totalTasks > 0
              ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
              : '0.0';

          final patterns = behaviorProvider.analyzePatterns(widget.studentId);
          final studyTrends = behaviorProvider.getStudyTimeTrends(
            widget.studentId,
          );
          final parentAlert = behaviorProvider.getParentAlert(
            widget.studentId,
            widget.studentName,
          );
          final completionPatterns = behaviorProvider.getCompletionTimePatterns(
            widget.studentId,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Alert with Actionable Guidance
                if (parentAlert['hasAlert'] == true)
                  _buildEnhancedAlert(parentAlert),

                if (parentAlert['hasAlert'] == true) const SizedBox(height: 16),

                // Academic Progress Link
                Card(
                  color: Colors.purple.shade50,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcademicProgressScreen(
                            studentId: widget.studentId,
                            studentName: widget.studentName,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.auto_graph,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Academic Progress Analysis',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'See how behavior correlates with performance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Overview Cards
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Tasks Done',
                        '$completedTasks/$totalTasks',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Completion',
                        '$completionRate%',
                        Icons.trending_up,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Study Time',
                        '${studyTrends['totalMinutes'] ?? 0} min',
                        Icons.timer,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pomodoros',
                        '${studyTrends['pomodoroCount'] ?? 0}',
                        Icons.alarm,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Behavioral Patterns
                const Text(
                  'Behavioral Patterns',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPatternRow(
                          'Consistency',
                          (patterns['consistency'] ?? 'No data').toString(),
                          _getPatternColor(
                            (patterns['consistency'] ?? '').toString(),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildPatternRow(
                          'Procrastination Level',
                          (patterns['procrastination'] ?? 'No data').toString(),
                          _getProcrastinationColor(
                            (patterns['procrastination'] ?? '').toString(),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildPatternRow(
                          'Productivity',
                          (patterns['productivity'] ?? 'No data').toString(),
                          _getPatternColor(
                            (patterns['productivity'] ?? '').toString(),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildPatternRow(
                          'Avg Tasks/Day',
                          (patterns['avgTasksPerDay'] ?? '0.0').toString(),
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Completion Time Patterns
                const Text(
                  'Task Completion Behavior',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildCompletionPatternsCard(completionPatterns),

                const SizedBox(height: 32),

                // Consistency Report (Last 7 days)
                const Text(
                  'Weekly Consistency',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildConsistencyChart(behaviorProvider),

                const SizedBox(height: 32),

                // Recent Activity
                const Text(
                  'Task Activity',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recent and upcoming tasks',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                if (studentTasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Tasks Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.studentName} hasn\'t created any tasks yet.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Show overdue tasks first
                      ...studentTasks
                          .where(
                            (task) =>
                                !task.isCompleted &&
                                task.dateTime.isBefore(DateTime.now()),
                          )
                          .take(3)
                          .map(
                            (task) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Colors.red[50],
                              child: ListTile(
                                leading: Icon(
                                  Icons.warning_amber,
                                  color: Colors.red[700],
                                ),
                                title: Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Overdue: ${DateFormat('MMM d, h:mm a').format(task.dateTime)}',
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'OVERDUE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      // Then show recent/upcoming tasks
                      ...studentTasks
                          .where(
                            (task) =>
                                task.isCompleted ||
                                task.dateTime.isAfter(DateTime.now()),
                          )
                          .take(5)
                          .map(
                            (task) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  task.isCompleted
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: task.isCompleted
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                title: Text(task.title),
                                subtitle: Text(
                                  DateFormat(
                                    'MMM d, h:mm a',
                                  ).format(task.dateTime),
                                ),
                                trailing:
                                    task.isCompleted && task.completedAt != null
                                    ? Text(
                                        'Done ${_getTimeAgo(task.completedAt!)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                    ],
                  ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPatternColor(String pattern) {
    switch (pattern) {
      case 'Excellent':
      case 'Good':
      case 'High':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'Low':
      case 'Needs Improvement':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getProcrastinationColor(String level) {
    switch (level) {
      case 'Low':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildConsistencyChart(BehaviorTrackingProvider provider) {
    final metrics = provider.getStudentMetrics(widget.studentId, days: 7);
    final last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: last7Days.map((date) {
                final metric = metrics.firstWhere(
                  (m) =>
                      m.date.year == date.year &&
                      m.date.month == date.month &&
                      m.date.day == date.day,
                  orElse: () =>
                      BehaviorMetrics(studentId: widget.studentId, date: date),
                );

                final hasActivity = metric.tasksCompleted > 0;

                return Column(
                  children: [
                    Text(
                      DateFormat('EEE').format(date).substring(0, 1),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: hasActivity ? Colors.green : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${metric.tasksCompleted}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: hasActivity
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Tasks completed per day',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildCompletionPatternsCard(Map<String, dynamic> patterns) {
    final pattern = patterns['pattern'].toString();
    final procrastinationRate = patterns['procrastinationRate'] ?? '0.0';
    final completedOnTime = patterns['completedOnTime'] ?? 0;
    final completedLate = patterns['completedLate'] ?? 0;
    final recommendation = patterns['recommendation'] ?? 'Keep tracking tasks';

    Color patternColor;
    IconData patternIcon;
    String patternTitle;

    switch (pattern) {
      case 'early_completer':
        patternColor = Colors.green;
        patternIcon = Icons.check_circle;
        patternTitle = 'Early Completer ✅';
        break;
      case 'chronic_procrastinator':
        patternColor = Colors.red;
        patternIcon = Icons.warning;
        patternTitle = 'Chronic Procrastinator ⚠️';
        break;
      case 'mixed':
        patternColor = Colors.orange;
        patternIcon = Icons.trending_up;
        patternTitle = 'Mixed Pattern';
        break;
      default:
        patternColor = Colors.grey;
        patternIcon = Icons.analytics;
        patternTitle = 'Analyzing...';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(patternIcon, color: patternColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    patternTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: patternColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pattern != 'insufficient_data') ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricColumn(
                      'On Time',
                      completedOnTime.toString(),
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricColumn(
                      'Late',
                      completedLate.toString(),
                      Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricColumn(
                      'Late Rate',
                      '$procrastinationRate%',
                      patternColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: patternColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: patternColor.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: patternColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: TextStyle(
                          fontSize: 12,
                          color: patternColor.withOpacity(0.9),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Not enough data yet. Encourage your student to complete more tasks.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEnhancedAlert(Map<String, dynamic> alert) {
    final severity = alert['severity'] as String;
    final warnings = alert['warnings'] as List<String>;
    final guidance = alert['guidance'] as List<String>;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    switch (severity) {
      case 'high':
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade400;
        textColor = Colors.red.shade900;
        icon = Icons.warning_amber_rounded;
        break;
      case 'medium':
        backgroundColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade400;
        textColor = Colors.orange.shade900;
        icon = Icons.info_outline;
        break;
      default:
        backgroundColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade400;
        textColor = Colors.blue.shade900;
        icon = Icons.lightbulb_outline;
    }

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    severity == 'high'
                        ? '⚠️ Urgent: ${alert['studentName']} Needs Support'
                        : '📊 Pattern Alert for ${alert['studentName']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Detected Issues:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            ...warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: textColor)),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(color: textColor, fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: textColor, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Recommended Actions:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...guidance.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_right, color: textColor, size: 14),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(color: textColor, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Last updated: ${DateFormat('MMM d, h:mm a').format(alert['timestamp'])}',
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
