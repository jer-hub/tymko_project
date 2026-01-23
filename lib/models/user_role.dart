enum UserRole { student, parent, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? linkedStudentId; // For parents
  final List<String>? linkedStudentIds; // For parents with multiple children

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.linkedStudentId,
    this.linkedStudentIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'linkedStudentId': linkedStudentId,
      'linkedStudentIds': linkedStudentIds,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      linkedStudentId: json['linkedStudentId'] as String?,
      linkedStudentIds: (json['linkedStudentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}
