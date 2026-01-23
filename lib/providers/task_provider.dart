import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      return task.dateTime.year == date.year &&
          task.dateTime.month == date.month &&
          task.dateTime.day == date.day;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Task> getTasksForStudent(String studentId) {
    return _tasks.where((task) => task.studentId == studentId).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  int getCompletedTasksCountForStudent(String studentId) {
    return _tasks
        .where((task) => task.studentId == studentId && task.isCompleted)
        .length;
  }

  int getTotalTasksCountForStudent(String studentId) {
    return _tasks.where((task) => task.studentId == studentId).length;
  }

  Map<String, int> getTasksByCategoryForStudent(String studentId) {
    final Map<String, int> categoryCount = {};
    final studentTasks = _tasks.where((task) => task.studentId == studentId);
    for (var task in studentTasks) {
      final category = task.category ?? 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    return categoryCount;
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final now = DateTime.now();
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
        completedAt: !_tasks[index].isCompleted ? now : null,
      );
      notifyListeners();
    }
  }

  void toggleSubtaskCompletion(String taskId, String subtaskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubtasks = task.subtasks.map((subtask) {
        if (subtask.id == subtaskId) {
          return Subtask(
            id: subtask.id,
            title: subtask.title,
            isCompleted: !subtask.isCompleted,
          );
        }
        return subtask;
      }).toList();

      _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
      notifyListeners();
    }
  }

  void addSubtask(String taskId, Subtask subtask) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubtasks = [...task.subtasks, subtask];
      _tasks[taskIndex] = task.copyWith(subtasks: updatedSubtasks);
      notifyListeners();
    }
  }

  int getCompletedTasksCount() {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int getTotalTasksCount() {
    return _tasks.length;
  }

  Map<String, int> getTasksByCategory() {
    final Map<String, int> categoryCount = {};
    for (var task in _tasks) {
      final category = task.category ?? 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    return categoryCount;
  }
}
