import 'package:flutter/material.dart';

class SchoolConstants {
  static const String schoolName = 'Dar-e-Arqam Digital School';
  static const String schoolMotto = 'Excellence in Islamic & Contemporary Education';
  static const String defaultSchoolId = 'school_darearqam_01';

  // Real App Assets
  static const String logoAsset = 'assets/images/dar_e_arqam_logo.png';
  static const String avatarBoyAsset = 'assets/images/avatar_student_boy.png';
  static const String avatarGirlAsset = 'assets/images/avatar_student_girl.png';
  static const String trophyAsset = 'assets/images/trophy_badge.png';
  static const String emptyDiaryAsset = 'assets/images/empty_diary.png';

  // Helper for dynamic student avatar
  static String getStudentAvatar(String studentName) {
    final lower = studentName.toLowerCase();
    if (lower.contains('sana') ||
        lower.contains('ayesha') ||
        lower.contains('fatima') ||
        lower.contains('maryam') ||
        lower.contains('hira') ||
        lower.contains('zainab') ||
        lower.contains('noor')) {
      return avatarGirlAsset;
    }
    return avatarBoyAsset;
  }

  // Dynamic Islamic Greeting based on time of day
  static String getDynamicGreeting({String userName = ''}) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    String icon;
    if (hour >= 4 && hour < 12) {
      timeGreeting = 'Subah Bakhair / Good Morning';
      icon = '☀️';
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = 'Dopehr Bakhair / Good Afternoon';
      icon = '🌤️';
    } else {
      timeGreeting = 'Shaam Bakhair / Good Evening';
      icon = '🌙';
    }
    if (userName.isNotEmpty) {
      return 'Assalam-o-Alaikum, $userName $icon\n$timeGreeting';
    }
    return 'Assalam-o-Alaikum $icon\n$timeGreeting';
  }

  // Role Constants
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleParent = 'parent';

  // Attendance Statuses
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusLate = 'late';
  static const String statusLeave = 'leave';

  // Time cutoffs (Prototypes)
  static const TimeOfDay defaultAttendanceCutoff = TimeOfDay(hour: 9, minute: 30);
  static const TimeOfDay defaultDiaryPublishTime = TimeOfDay(hour: 14, minute: 0);
  static const double minimumAttendancePercentage = 75.0;

  // Assessment Types
  static const List<String> assessmentTypes = [
    'Weekly Test',
    'Monthly Test',
    'Mid-Term Exam',
    'Final Exam',
  ];

  // Diary Statuses
  static const String diaryStatusDraft = 'draft';
  static const String diaryStatusCompleted = 'completed';

  // Notification Types
  static const String notifAttendance = 'attendance';
  static const String notifAttendanceCorrection = 'attendance_correction';
  static const String notifDiary = 'diary';
  static const String notifMarks = 'marks';
  static const String notifWarning = 'warning';
  static const String notifSystem = 'system';
}
