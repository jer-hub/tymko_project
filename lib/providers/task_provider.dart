import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> getTasksForStudent(String studentId) {
    return _tasks.where((t) => t.studentId == studentId).toList();
  }

  List<Task> getTasksForStudentAndDate(String studentId, DateTime date) {
    return _tasks
        .where(
          (t) =>
              t.studentId == studentId &&
              t.dateTime.year == date.year &&
              t.dateTime.month == date.month &&
              t.dateTime.day == date.day,
        )
        .toList();
  }

  // Convenience overload used by UI (no studentId)
  List<Task> getTasksForDateOnly(DateTime date) {
    return _tasks
        .where(
          (t) =>
              t.dateTime.year == date.year &&
              t.dateTime.month == date.month &&
              t.dateTime.day == date.day,
        )
        .toList();
  }

  // UI-friendly alias (same name expected throughout the app)
  List<Task> getTasksForDate(DateTime date) => getTasksForDateOnly(date);

  int getCompletedTasksCountForStudent(String studentId) {
    return _tasks
        .where((t) => t.studentId == studentId && t.isCompleted)
        .length;
  }

  // No-arg variant used by some UI
  int getCompletedTasksCountAll() {
    return _tasks.where((t) => t.isCompleted).length;
  }

  // Alias expected by some screens
  int getCompletedTasksCount() => getCompletedTasksCountAll();

  int getTotalTasksCountForStudent(String studentId) {
    return _tasks.where((t) => t.studentId == studentId).length;
  }

  // No-arg variant used by some UI
  int getTotalTasksCountAll() {
    return _tasks.length;
  }

  // Alias expected by some screens
  int getTotalTasksCount() => getTotalTasksCountAll();

  Map<String, List<Task>> getTasksByCategoryForStudent(String studentId) {
    final map = <String, List<Task>>{};
    for (final t in getTasksForStudent(studentId)) {
      final cat = t.category ?? 'uncategorized';
      map.putIfAbsent(cat, () => []);
      map[cat]!.add(t);
    }
    return map;
  }

  // No-arg variant
  Map<String, List<Task>> getTasksByCategoryAll() {
    final map = <String, List<Task>>{};
    for (final t in _tasks) {
      final cat = t.category ?? 'uncategorized';
      map.putIfAbsent(cat, () => []);
      map[cat]!.add(t);
    }
    return map;
  }

  // Alias expected by some screens
  Map<String, List<Task>> getTasksByCategory() => getTasksByCategoryAll();

  Future<void> fetchTasksForStudent(String studentId) async {
    _tasks = await Task.getAllForStudent(studentId);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await task.save();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      await task.save();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final task = _tasks.removeAt(idx);
      await task.delete();
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final task = _tasks[idx];
      final updated = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      _tasks[idx] = updated;
      await updated.save();
      notifyListeners();
    }
  }

  Future<void> toggleSubtaskCompletion(String taskId, String subtaskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final task = _tasks[idx];
    final subtasks = task.subtasks
        .map(
          (s) => s.id == subtaskId
              ? Subtask(id: s.id, title: s.title, isCompleted: !s.isCompleted)
              : s,
        )
        .toList();
    final updated = task.copyWith(subtasks: subtasks);
    _tasks[idx] = updated;
    await updated.save();
    notifyListeners();
  }

  Future<void> addSubtask(String taskId, Subtask subtask) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final task = _tasks[idx];
    final subtasks = List<Subtask>.from(task.subtasks)..add(subtask);
    final updated = task.copyWith(subtasks: subtasks);
    _tasks[idx] = updated;
    await updated.save();
    notifyListeners();
  }
}
