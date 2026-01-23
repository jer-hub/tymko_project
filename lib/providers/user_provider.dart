import 'package:flutter/material.dart';
import '../models/user_role.dart';

class UserProvider with ChangeNotifier {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.student;
  bool get isStudent => currentRole == UserRole.student;
  bool get isParent => currentRole == UserRole.parent;
  bool get isAdmin => currentRole == UserRole.admin;

  void setUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // For demo purposes - simulate login
  void loginAsStudent(String id, String name) {
    _currentUser = AppUser(
      id: id,
      name: name,
      email: '$name@student.com',
      role: UserRole.student,
    );
    notifyListeners();
  }

  void loginAsParent(String id, String name, String studentId) {
    _currentUser = AppUser(
      id: id,
      name: name,
      email: '$name@parent.com',
      role: UserRole.parent,
      linkedStudentId: studentId,
    );
    notifyListeners();
  }

  void loginAsAdmin(String id, String name) {
    _currentUser = AppUser(
      id: id,
      name: name,
      email: '$name@admin.com',
      role: UserRole.admin,
    );
    notifyListeners();
  }
}
