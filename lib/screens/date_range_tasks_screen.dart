import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';

class DateRangeTasksScreen extends StatefulWidget {
  const DateRangeTasksScreen({super.key});

  @override
  State<DateRangeTasksScreen> createState() => _DateRangeTasksScreenState();
}

class _DateRangeTasksScreenState extends State<DateRangeTasksScreen> {
  DateTimeRange? _selectedRange;
  String _filterType = 'all'; // all, pending, completed, overdue
  String _sortBy = 'date'; // date, priority, category
  final Set<String> _selectedTaskIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    // Default to current week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final weekEnd = weekStart.add(const Duration(days: 6));
    _selectedRange = DateTimeRange(start: weekStart, end: weekEnd);
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _selectedRange = range;
        _selectedTaskIds.clear();
        _isSelectionMode = false;
      });
    }
  }

  List<Task> _getFilteredTasks(TaskProvider taskProvider) {
    if (_selectedRange == null) return [];

    List<Task> tasks = [];
    DateTime currentDate = _selectedRange!.start;

    while (currentDate.isBefore(_selectedRange!.end) ||
        currentDate.isAtSameMomentAs(_selectedRange!.end)) {
      tasks.addAll(taskProvider.getTasksForDate(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Remove duplicates
    final uniqueTasks = <String, Task>{};
    for (var task in tasks) {
      uniqueTasks[task.id] = task;
    }
    tasks = uniqueTasks.values.toList();

    // Apply filter
    switch (_filterType) {
      case 'pending':
        tasks = tasks.where((t) => !t.isCompleted).toList();
        break;
      case 'completed':
        tasks = tasks.where((t) => t.isCompleted).toList();
        break;
      case 'overdue':
        tasks = tasks
            .where((t) => !t.isCompleted && t.dateTime.isBefore(DateTime.now()))
            .toList();
        break;
    }

    // Apply sort
    switch (_sortBy) {
      case 'priority':
        tasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'category':
        tasks.sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
        break;
      default:
        tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }

    return tasks;
  }

  void _toggleTaskSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
        if (_selectedTaskIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  void _bulkComplete(TaskProvider taskProvider) {
    for (var taskId in _selectedTaskIds) {
      final task = taskProvider.tasks.firstWhere((t) => t.id == taskId);
      if (!task.isCompleted) {
        taskProvider.toggleTaskCompletion(taskId);
      }
    }
    setState(() {
      _selectedTaskIds.clear();
      _isSelectionMode = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Tasks marked as complete')));
  }

  void _bulkDelete(TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: Text('Delete ${_selectedTaskIds.length} selected tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (var taskId in _selectedTaskIds) {
                taskProvider.deleteTask(taskId);
              }
              setState(() {
                _selectedTaskIds.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ Tasks deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = _getFilteredTasks(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Tasks by Date'),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () => _bulkComplete(taskProvider),
              tooltip: 'Mark Complete',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _bulkDelete(taskProvider),
              tooltip: 'Delete',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedTaskIds.clear();
                  _isSelectionMode = false;
                });
              },
              tooltip: 'Cancel',
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
              tooltip: 'Select Multiple',
            ),
        ],
      ),
      body: Column(
        children: [
          // Date Range Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _selectedRange != null
                              ? Text(
                                  '${DateFormat('MMM d').format(_selectedRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedRange!.end)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : const Text('Select Date Range'),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Quick date range buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickDateButton('Today', () {
                        setState(() {
                          final today = DateTime.now();
                          _selectedRange = DateTimeRange(
                            start: today,
                            end: today,
                          );
                        });
                      }),
                      _buildQuickDateButton('This Week', () {
                        setState(() {
                          final now = DateTime.now();
                          final weekStart = now.subtract(
                            Duration(days: now.weekday % 7),
                          );
                          _selectedRange = DateTimeRange(
                            start: weekStart,
                            end: weekStart.add(const Duration(days: 6)),
                          );
                        });
                      }),
                      _buildQuickDateButton('This Month', () {
                        setState(() {
                          final now = DateTime.now();
                          final monthStart = DateTime(now.year, now.month, 1);
                          final monthEnd = DateTime(now.year, now.month + 1, 0);
                          _selectedRange = DateTimeRange(
                            start: monthStart,
                            end: monthEnd,
                          );
                        });
                      }),
                      _buildQuickDateButton('Next 7 Days', () {
                        setState(() {
                          final now = DateTime.now();
                          _selectedRange = DateTimeRange(
                            start: now,
                            end: now.add(const Duration(days: 6)),
                          );
                        });
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters and Sort
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Filter dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterType,
                    decoration: const InputDecoration(
                      labelText: 'Filter',
                      prefixIcon: Icon(Icons.filter_list, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Tasks')),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: 'overdue',
                        child: Text('Overdue'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Sort dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      prefixIcon: Icon(Icons.sort, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Date')),
                      DropdownMenuItem(
                        value: 'priority',
                        child: Text('Priority'),
                      ),
                      DropdownMenuItem(
                        value: 'category',
                        child: Text('Category'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Task count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${tasks.length} tasks found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedTaskIds.isNotEmpty)
                  Text(
                    ' • ${_selectedTaskIds.length} selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks in this date range',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isSelected = _selectedTaskIds.contains(task.id);
                      final isOverdue =
                          !task.isCompleted &&
                          task.dateTime.isBefore(DateTime.now());

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.3)
                            : null,
                        child: ListTile(
                          leading: _isSelectionMode
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      _toggleTaskSelection(task.id),
                                )
                              : Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) {
                                    taskProvider.toggleTaskCompletion(task.id);
                                  },
                                ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: isOverdue ? Colors.red : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'EEE, MMM d',
                                    ).format(task.dateTime),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOverdue
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  if (task.category != null) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        task.category!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: _isSelectionMode
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (task.priority > 3)
                                      const Icon(
                                        Icons.priority_high,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          taskProvider.deleteTask(task.id);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Task deleted'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                          onTap: _isSelectionMode
                              ? () => _toggleTaskSelection(task.id)
                              : null,
                          onLongPress: () {
                            setState(() {
                              _isSelectionMode = true;
                              _toggleTaskSelection(task.id);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddTaskDialog(),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
