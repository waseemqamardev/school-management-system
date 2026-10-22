import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/parent_model.dart';
import '../models/teacher_model.dart';
import '../services/repository_manager.dart';

class AuthProvider extends ChangeNotifier {
  final RepositoryManager _repoManager;

  AppUser? _currentUser;
  TeacherProfile? _teacherProfile;
  ParentProfile? _parentProfile;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repoManager);

  AppUser? get currentUser => _currentUser;
  TeacherProfile? get teacherProfile => _teacherProfile;
  ParentProfile? get parentProfile => _parentProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isTeacher => _currentUser?.role == 'teacher';
  bool get isParent => _currentUser?.role == 'parent';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repoManager.repository.getUserByEmail(email.trim());
      if (user == null) {
        _errorMessage = 'No user account found with email "$email".';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!user.active) {
        _errorMessage = 'This account has been deactivated. Please contact the administrator.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _loadRoleProfiles();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Quick Demo Login Helper
  Future<bool> quickDemoLogin(String role) async {
    switch (role.toLowerCase()) {
      case 'admin':
        return login('admin@daralarqam.demo', '123456');
      case 'teacher':
        return login('teacher@daralarqam.demo', '123456');
      case 'parent':
        return login('parent@daralarqam.demo', '123456');
      default:
        return false;
    }
  }

  Future<void> _loadRoleProfiles() async {
    if (_currentUser == null) return;
    if (_currentUser!.role == 'teacher') {
      _teacherProfile = await _repoManager.repository.getTeacherByUserId(_currentUser!.userId);
    } else if (_currentUser!.role == 'parent') {
      _parentProfile = await _repoManager.repository.getParentByUserId(_currentUser!.userId);
    }
  }

  void logout() {
    _currentUser = null;
    _teacherProfile = null;
    _parentProfile = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
