import 'package:cloud_firestore/cloud_firestore.dart';

class Subtask {
  final String id;
  final String title;
  final bool isCompleted;

  Subtask({required this.id, required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
    id: json['id'] as String,
    title: json['title'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

class Task {
  final String id;
  final String studentId;
  final String title;
  final String? description;
  final DateTime dateTime; // alias used across the app (now non-nullable)
  final DateTime? endTime;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isRecurring;
  final String? recurringPattern;
  final int? estimatedDuration; // in minutes
  final int? actualDuration; // in minutes
  final List<Subtask> subtasks;
  final int priority;
  final String? category;

  // Keep dueDate for backward compatibility (maps to dateTime)
  DateTime get dueDate => dateTime;

  Task({
    required this.id,
    required this.studentId,
    required this.title,
    this.description,
    DateTime? dateTime,
    this.endTime,
    this.isCompleted = false,
    this.completedAt,
    this.isRecurring = false,
    this.recurringPattern,
    this.estimatedDuration,
    this.actualDuration,
    this.subtasks = const [],
    this.priority = 3,
    this.category,
  }) : dateTime = dateTime ?? DateTime.now();

  Task copyWith({
    String? id,
    String? studentId,
    String? title,
    String? description,
    DateTime? dateTime,
    DateTime? endTime,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isRecurring,
    String? recurringPattern,
    int? estimatedDuration,
    int? actualDuration,
    List<Subtask>? subtasks,
    int? priority,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      subtasks: subtasks ?? this.subtasks,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'priority': priority,
      'category': category,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      studentId: json['studentId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringPattern: json['recurringPattern'] as String?,
      estimatedDuration: json['estimatedDuration'] as int?,
      actualDuration: json['actualDuration'] as int?,
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      priority: json['priority'] as int? ?? 3,
      category: json['category'] as String?,
    );
  }

  static CollectionReference get _collection =>
      FirebaseFirestore.instance.collection('tasks');

  Future<void> save() async {
    await _collection.doc(id).set(toJson());
  }

  Future<void> delete() async {
    await _collection.doc(id).delete();
  }

  static Future<List<Task>> getAllForStudent(String studentId) async {
    final query = await _collection
        .where('studentId', isEqualTo: studentId)
        .get();
    return query.docs
        .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
