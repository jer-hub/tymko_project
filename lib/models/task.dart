class Subtask {
  final String id;
  final String title;
  final bool isCompleted;

  Subtask({required this.id, required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted};
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class Task {
  final String id;
  final String studentId;
  final String title;
  final String? description;
  final DateTime dateTime;
  final DateTime? endTime;
  final String? category;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isRecurring;
  final String? recurringPattern; // 'daily', 'weekly', 'monthly'
  final int? estimatedDuration; // in minutes
  final int? actualDuration; // in minutes
  final List<Subtask> subtasks;
  final int priority; // 1-5, 5 being highest

  Task({
    required this.id,
    required this.studentId,
    required this.title,
    this.description,
    required this.dateTime,
    this.endTime,
    this.category,
    this.isCompleted = false,
    this.completedAt,
    this.isRecurring = false,
    this.recurringPattern,
    this.estimatedDuration,
    this.actualDuration,
    this.subtasks = const [],
    this.priority = 3,
  });

  Task copyWith({
    String? id,
    String? studentId,
    String? title,
    String? description,
    DateTime? dateTime,
    DateTime? endTime,
    String? category,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isRecurring,
    String? recurringPattern,
    int? estimatedDuration,
    int? actualDuration,
    List<Subtask>? subtasks,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      subtasks: subtasks ?? this.subtasks,
      priority: priority ?? this.priority,
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
      'category': category,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'priority': priority,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      studentId: json['studentId'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      category: json['category'] as String?,
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
    );
  }
}
