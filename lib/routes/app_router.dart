import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/teacher/teacher_dashboard_screen.dart';
import '../features/parent/parent_dashboard_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    final role = auth.currentUser?.role.toLowerCase();

    switch (role) {
      case 'admin':
        return const AdminDashboardScreen();
      case 'teacher':
        return const TeacherDashboardScreen();
      case 'parent':
        return const ParentDashboardScreen();
      default:
        return const LoginScreen();
    }
  }
}
