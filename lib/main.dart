import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/school_constants.dart';
import 'providers/admin_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/diary_provider.dart';
import 'providers/marks_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/parent_provider.dart';
import 'routes/app_router.dart';
import 'services/repository_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom User-Friendly Error Boundary (replaces Flutter's red error screen)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Dar-e-Arqam Portal Note',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Screen view was updated. Please navigate back or pull to refresh.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Initialize Repository Manager (handles Supabase or graceful local mock fallback)
  final repoManager = RepositoryManager();
  await repoManager.initialize();

  runApp(DarEArqamApp(repoManager: repoManager));
}

class DarEArqamApp extends StatelessWidget {
  final RepositoryManager repoManager;

  const DarEArqamApp({super.key, required this.repoManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RepositoryManager>.value(value: repoManager),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(repoManager),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (_) => AttendanceProvider(repoManager),
        ),
        ChangeNotifierProvider<DiaryProvider>(
          create: (_) => DiaryProvider(repoManager),
        ),
        ChangeNotifierProvider<MarksProvider>(
          create: (_) => MarksProvider(repoManager),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(repoManager),
        ),
        ChangeNotifierProvider<ParentProvider>(
          create: (_) => ParentProvider(repoManager),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(repoManager),
        ),
      ],
      child: MaterialApp(
        title: SchoolConstants.schoolName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppRouter(),
      ),
    );
  }
}
