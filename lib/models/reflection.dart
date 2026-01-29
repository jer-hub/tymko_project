import 'package:cloud_firestore/cloud_firestore.dart';

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
  // --- Firestore CRUD methods ---
  static CollectionReference get _collection =>
      FirebaseFirestore.instance.collection('reflections');

  Future<void> save() async {
    await _collection.doc(id).set(toJson());
  }

  Future<void> delete() async {
    await _collection.doc(id).delete();
  }

  static Future<List<Reflection>> getAllForStudent(String studentId) async {
    final query = await _collection
        .where('studentId', isEqualTo: studentId)
        .get();
    return query.docs
        .map((doc) => Reflection.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
