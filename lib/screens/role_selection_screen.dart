import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
import '../providers/behavior_tracking_provider.dart';
import '../utils/seed_data.dart';
import 'home_screen.dart';
import 'parent_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.school,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Tymko',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Student Task & Habit Manager',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 48),

                  // Role Selection Cards
                  _buildRoleCard(
                    context,
                    'Student',
                    'Track tasks, study time, and build better habits',
                    Icons.person,
                    Colors.blue,
                    () {
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      userProvider.loginAsStudent('student1', 'Student User');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildRoleCard(
                    context,
                    'Parent',
                    'Monitor your child\'s progress and consistency',
                    Icons.family_restroom,
                    Colors.green,
                    () {
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      userProvider.loginAsParent(
                        'parent1',
                        'Parent User',
                        'student1',
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ParentDashboardScreen(
                            studentId: 'student1',
                            studentName: 'Student User',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildRoleCard(
                    context,
                    'Admin',
                    'View analytics and manage system data',
                    Icons.admin_panel_settings,
                    Colors.purple,
                    () {
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      userProvider.loginAsAdmin('admin1', 'Admin User');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboardScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Info card
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            'Demo Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select a role to explore different features',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _seedDummyData(context),
                            icon: const Icon(Icons.data_array, size: 18),
                            label: const Text('Load Sample Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _seedDummyData(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final behaviorProvider = Provider.of<BehaviorTrackingProvider>(
      context,
      listen: false,
    );

    // Clear existing data first
    taskProvider.tasks.clear();
    behaviorProvider.dailyMetrics.clear();
    behaviorProvider.studySessions.clear();
    behaviorProvider.reflections.clear();
    behaviorProvider.performanceHistory.clear();

    // Seed new data
    SeedData.seedAll(taskProvider, behaviorProvider);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Sample data loaded successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
