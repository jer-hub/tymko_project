class Reflection {
  final String id;
  final String studentId;
  final DateTime date;
  final String completedToday;
  final String challenges;
  final String improvements;
  final int productivityRating; // 1-5

  Reflection({
    required this.id,
    required this.studentId,
    required this.date,
    required this.completedToday,
    this.challenges = '',
    this.improvements = '',
    this.productivityRating = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'completedToday': completedToday,
      'challenges': challenges,
      'improvements': improvements,
      'productivityRating': productivityRating,
    };
  }

  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      date: DateTime.parse(json['date'] as String),
      completedToday: json['completedToday'] as String,
      challenges: json['challenges'] as String? ?? '',
      improvements: json['improvements'] as String? ?? '',
      productivityRating: json['productivityRating'] as int? ?? 3,
    );
  }
}
