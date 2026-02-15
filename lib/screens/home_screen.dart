import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import '../providers/behavior_tracking_provider.dart';
import '../utils/deadline_notification_service.dart';
import '../widgets/calendar_week_view.dart';
import '../widgets/task_list_item.dart';
import '../widgets/reflection_dialog.dart';
import '../widgets/pattern_warning_banner.dart';
import '../widgets/deadline_notification_banner.dart';
import '../widgets/full_calendar_view.dart';
import 'tasks_screen.dart';
import 'stats_screen.dart';
import 'pomodoro_timer_screen.dart';
import 'date_range_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  bool _notificationsScheduled = false;

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildScheduleScreen();
      case 1:
        return const TasksScreen();
      case 2:
        return const StatsScreen();
      default:
        return _buildScheduleScreen();
    }
  }

  Widget _buildScheduleScreen() {
    final userProvider = Provider.of<UserProvider>(context);
    final behaviorProvider = Provider.of<BehaviorTrackingProvider>(context);

    // Set student ID on TaskProvider for phone notifications (once)
    if (!_notificationsScheduled) {
      final studentId = userProvider.currentUser?.id ?? 'student1';
      Provider.of<TaskProvider>(context, listen: false)
          .setCurrentStudentId(studentId);
      _notificationsScheduled = true;
    }

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasksForDay = taskProvider.getTasksForDate(_selectedDate);
        final studentId = userProvider.currentUser?.id ?? 'student1';
        final suggestions = behaviorProvider.getAdaptiveSuggestions(studentId);

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'EEEE',
                                ).format(_selectedDate).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      DateFormat('MMMM').format(_selectedDate),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('d').format(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Quick Actions
                        Row(
                          children: [
                            Consumer<TaskProvider>(
                              builder: (context, taskProvider, _) {
                                final count = taskProvider
                                    .getDeadlineNotifications(
                                      studentId: studentId,
                                    )
                                    .length;
                                return Stack(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        count > 0
                                            ? Icons.notifications_active
                                            : Icons.notifications_none,
                                      ),
                                      tooltip: 'Deadline Alerts',
                                      onPressed: () {
                                        _showDeadlineBottomSheet(
                                          context,
                                          studentId,
                                        );
                                      },
                                    ),
                                    if (count > 0)
                                      Positioned(
                                        right: 6,
                                        top: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            count > 9 ? '9+' : '$count',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.date_range),
                              tooltip: 'Browse Dates',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DateRangeTasksScreen(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.timer),
                              tooltip: 'Pomodoro Timer',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PomodoroTimerScreen(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.auto_awesome),
                              tooltip: 'Daily Reflection',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ReflectionDialog(studentId: studentId),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Pattern Warning Banner
            SliverToBoxAdapter(
              child: PatternWarningBanner(studentId: studentId),
            ),

            // Deadline Notifications
            SliverToBoxAdapter(
              child: DeadlineNotificationBanner(studentId: studentId),
            ),

            // Adaptive Suggestions Card
            if (suggestions.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Personalized Tips',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...suggestions
                          .take(2)
                          .map(
                            (suggestion) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),

            // Calendar Week View
            SliverToBoxAdapter(
              child: CalendarWeekView(
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
                onExpandCalendar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullCalendarView(
                        initialDate: _selectedDate,
                        onDateSelected: _onDateSelected,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Timeline Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${tasksForDay.length} Tasks',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks List or Empty State
            tasksForDay.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            TaskListItem(task: tasksForDay[index]),
                        childCount: tasksForDay.length,
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  void _showDeadlineBottomSheet(BuildContext context, String studentId) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final notifications = taskProvider.getDeadlineNotifications(
      studentId: studentId,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            if (notifications.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.green[400],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'All caught up!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No upcoming or missed deadlines',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deadline Alerts (${notifications.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final isOverdue =
                          n.urgency == DeadlineUrgency.overdue;
                      final deadline =
                          n.task.endTime ?? n.task.dateTime;

                      return Card(
                        color: isOverdue
                            ? Theme.of(context).colorScheme.errorContainer
                            : null,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.schedule,
                            color: isOverdue
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            n.task.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${n.urgencyLabel} · ${DateFormat('MMM d, h:mm a').format(deadline)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            tooltip: 'Mark Complete',
                            onPressed: () {
                              taskProvider.toggleTaskCompletion(n.task.id);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'No tasks today!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "You're free as a bird. Or maybe you forgot to plan?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Plan something'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

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
    final userProvider = Provider.of<UserProvider>(context);

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
        appBar: _selectedIndex == 0
            ? null
            : AppBar(
              title: Text(_selectedIndex == 1 ? 'Tasks' : 'Statistics'),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'switch_role') {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 12),
                          Text(userProvider.currentUser?.name ?? 'Student'),
                        ],
                      ),
                      enabled: false,
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'switch_role',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 12),
                          Text('Switch Role'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
        body: _getSelectedScreen(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavigationItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            NavigationDestination(icon: Icon(Icons.task_alt), label: 'Tasks'),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          ],
        ),
      ),
    );
  }
}
