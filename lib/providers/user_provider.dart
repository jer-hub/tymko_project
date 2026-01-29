import 'package:flutter/material.dart';
import '../models/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.student;
  bool get isStudent => currentRole == UserRole.student;
  bool get isParent => currentRole == UserRole.parent;
  bool get isAdmin => currentRole == UserRole.admin;

  Future<void> setUser(AppUser user) async {
    await _saveUserToFirestore(user);
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loginAsStudent(String id, String name) async {
    final user =
        await _getUserFromFirestore(id) ??
        AppUser(
          id: id,
          name: name,
          email: '$name@student.com',
          role: UserRole.student,
        );
    await setUser(user);
  }

  Future<void> loginAsParent(String id, String name, String studentId) async {
    final user =
        await _getUserFromFirestore(id) ??
        AppUser(
          id: id,
          name: name,
          email: '$name@parent.com',
          role: UserRole.parent,
          linkedStudentId: studentId,
        );
    await setUser(user);
  }

  Future<void> loginAsAdmin(String id, String name) async {
    final user =
        await _getUserFromFirestore(id) ??
        AppUser(
          id: id,
          name: name,
          email: '$name@admin.com',
          role: UserRole.admin,
        );
    await setUser(user);
  }

  Future<void> _saveUserToFirestore(AppUser user) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(user.id).set(user.toJson());
  }

  Future<AppUser?> _getUserFromFirestore(String id) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final doc = await usersCollection.doc(id).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(doc.data() as Map<String, dynamic>);
  }
}
