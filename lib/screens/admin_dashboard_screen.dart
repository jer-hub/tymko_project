import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/behavior_tracking_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
          final totalTasks = taskProvider.getTotalTasksCount();
          final completedTasks = taskProvider.getCompletedTasksCount();
          final totalSessions = behaviorProvider.studySessions.length;
          final totalReflections = behaviorProvider.reflections.length;

          // Anonymized analytics
          final tasksByCategory = taskProvider.getTasksByCategory();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // System Overview
                const Text(
                  'System Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Total Tasks',
                        totalTasks.toString(),
                        Icons.task,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Completed',
                        completedTasks.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Study Sessions',
                        totalSessions.toString(),
                        Icons.timer,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Reflections',
                        totalReflections.toString(),
                        Icons.auto_awesome,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Usage Analytics
                const Text(
                  'Anonymous Usage Patterns',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Categories Distribution',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (tasksByCategory.isEmpty)
                          const Text('No data available')
                        else
                          ...tasksByCategory.entries.map((entry) {
                            final percentage = totalTasks > 0
                                ? (entry.value / totalTasks * 100)
                                      .toStringAsFixed(1)
                                : '0.0';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value} ($percentage%)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: entry.value / totalTasks,
                                    backgroundColor: Colors.grey[200],
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Research Data Info
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.science, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Research & Data Integrity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.privacy_tip,
                          'All data is anonymized for research purposes',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.analytics,
                          'Behavioral patterns help improve academic interventions',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.verified,
                          'System ensures reliable data for continuous improvement',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // System Features
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Features',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          Icons.timer,
                          'Pomodoro Timer',
                          'Promotes focused study sessions',
                        ),
                        const Divider(),
                        _buildFeatureRow(
                          Icons.psychology,
                          'Behavioral Tracking',
                          'Identifies patterns and intervention needs',
                        ),
                        const Divider(),
                        _buildFeatureRow(
                          Icons.family_restroom,
                          'Parent Monitoring',
                          'Adds external accountability',
                        ),
                        const Divider(),
                        _buildFeatureRow(
                          Icons.auto_awesome,
                          'Daily Reflection',
                          'Builds self-awareness',
                        ),
                        const Divider(),
                        _buildFeatureRow(
                          Icons.lightbulb,
                          'Adaptive Suggestions',
                          'Personalized improvement recommendations',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.blue[900]),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
