import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/behavior_tracking_provider.dart';
import '../models/behavior_metrics.dart';
import '../widgets/parent_task_activity_view.dart';
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
  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
            final completedTasks = taskProvider.getCompletedTasksCountForStudent(widget.studentId);
            final totalTasks = taskProvider.getTotalTasksCountForStudent(widget.studentId);
            final completionRate = totalTasks > 0
                ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
                : '0.0';

            final studyTrends = behaviorProvider.getStudyTimeTrends(widget.studentId);
            final parentAlert = behaviorProvider.getParentAlert(widget.studentId, widget.studentName);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Alert
                  if (parentAlert['hasAlert'] == true) _buildEnhancedAlert(parentAlert),
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
                              child: const Icon(Icons.auto_graph, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Academic Progress Analysis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('See how behavior correlates with performance', style: TextStyle(fontSize: 12, color: Colors.grey)),
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

                  // Overview
                  const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Tasks Done', '$completedTasks/$totalTasks', Icons.check_circle, Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Completion', '$completionRate%', Icons.trending_up, Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Study Time', '${studyTrends['totalMinutes'] ?? 0} min', Icons.timer, Colors.purple)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Pomodoros', '${studyTrends['pomodoroCount'] ?? 0}', Icons.alarm, Colors.orange)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Weekly Consistency
                  const Text('Weekly Consistency', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildConsistencyChart(behaviorProvider),

                  const SizedBox(height: 32),

                  // Task Activity — Optimized View
                  ParentTaskActivityView(
                    studentId: widget.studentId,
                    studentName: widget.studentName,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Helpers (existing implementations below) ---
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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

  Widget _buildConsistencyChart(BehaviorTrackingProvider provider) {
    final metrics = provider.getStudentMetrics(widget.studentId, days: 7);
    final last7Days = List.generate(7, (index) => DateTime.now().subtract(Duration(days: 6 - index)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: last7Days.map((date) {
            final metric = metrics.firstWhere(
              (m) => m.date.year == date.year && m.date.month == date.month && m.date.day == date.day,
              orElse: () => BehaviorMetrics(studentId: widget.studentId, date: date),
            );
            final hasActivity = metric.tasksCompleted > 0;
            return Column(
              children: [
                Text(DateFormat('EEE').format(date).substring(0, 1), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: hasActivity ? Colors.green : Colors.grey[300], shape: BoxShape.circle),
                  child: Center(child: Text('${metric.tasksCompleted}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: hasActivity ? Colors.white : Colors.grey[600]))),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEnhancedAlert(Map<String, dynamic> alert) {
    final severity = alert['severity'] as String? ?? 'low';
    final warnings = (alert['warnings'] as List?)?.cast<String>() ?? [];
    final guidance = (alert['guidance'] as List?)?.cast<String>() ?? [];

    Color backgroundColor = Colors.blue.shade50;
    Color borderColor = Colors.blue.shade400;
    Color textColor = Colors.blue.shade900;
    IconData icon = Icons.lightbulb_outline;
    if (severity == 'high') {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade400;
      textColor = Colors.red.shade900;
      icon = Icons.warning_amber_rounded;
    } else if (severity == 'medium') {
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade400;
      textColor = Colors.orange.shade900;
      icon = Icons.info_outline;
    }

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: textColor, size: 28), const SizedBox(width: 12), Expanded(child: Text(alert['title'] ?? 'Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)))]),
          const SizedBox(height: 8),
          ...warnings.map((w) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $w', style: TextStyle(color: textColor)))),
          const SizedBox(height: 8),
          ...guidance.map((g) => Padding(padding: const EdgeInsets.only(bottom: 3), child: Text('• $g', style: TextStyle(color: textColor)))),
        ]),
      ),
    );
  }

}
