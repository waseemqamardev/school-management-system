import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_record_model.dart';
import '../models/notification_model.dart';
import '../models/holiday_model.dart';
import '../models/school_settings_model.dart';
import '../services/repository_manager.dart';

class AttendanceProvider extends ChangeNotifier {
  final RepositoryManager _repoManager;
  final _uuid = const Uuid();

  List<SchoolClass> _classes = [];
  SchoolClass? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  List<Student> _students = [];
  final Map<String, String> _studentStatusMap = {}; // studentId -> 'present', 'absent', 'late', 'leave'
  Map<String, String> _previousStatusMap = {}; // Tracks before-correction status
  AttendanceSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;
  List<SchoolHoliday> _holidays = [];
  SchoolSettings? _settings;

  AttendanceProvider(this._repoManager);

  List<SchoolClass> get classes => _classes;
  SchoolClass? get selectedClass => _selectedClass;
  DateTime get selectedDate => _selectedDate;
  String get selectedDateFormatted => DateFormat('yyyy-MM-dd').format(_selectedDate);
  List<Student> get students => _students;
  Map<String, String> get studentStatusMap => _studentStatusMap;
  List<SchoolHoliday> get holidays => _holidays;
  AttendanceSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isSubmitted => _currentSession?.submitted ?? false;
  bool get isPending => !isSubmitted;

  int get totalStudents => _students.length;
  int get presentCount => _studentStatusMap.values.where((s) => s == 'present').length;
  int get absentCount => _studentStatusMap.values.where((s) => s == 'absent').length;
  int get lateCount => _studentStatusMap.values.where((s) => s == 'late').length;
  int get leaveCount => _studentStatusMap.values.where((s) => s == 'leave').length;

  bool get isPastCutoff {
    if (_settings == null) return false;
    final parts = _settings!.attendanceCutoffTime.split(':');
    if (parts.length != 2) return false;
    final cutoffHour = int.tryParse(parts[0]) ?? 9;
    final cutoffMin = int.tryParse(parts[1]) ?? 30;

    final now = DateTime.now();
    // Only apply cutoff warning for today's date
    if (DateFormat('yyyy-MM-dd').format(now) != selectedDateFormatted) return false;

    final cutoffTime = DateTime(now.year, now.month, now.day, cutoffHour, cutoffMin);
    return now.isAfter(cutoffTime) && isPending;
  }

  Future<void> initializeForClass(String? classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _classes = await _repoManager.repository.getClasses();
      _holidays = await _repoManager.repository.getHolidays();
      _settings = await _repoManager.repository.getSettings();

      if (_classes.isNotEmpty) {
        if (classId != null) {
          _selectedClass = _classes.firstWhere(
            (c) => c.classId == classId,
            orElse: () => _classes.first,
          );
        } else {
          _selectedClass ??= _classes.first;
        }
      }

      await loadAttendanceForDate(_selectedDate);
    } catch (e) {
      _errorMessage = 'Failed to initialize attendance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectClass(SchoolClass schoolClass) {
    _selectedClass = schoolClass;
    loadAttendanceForDate(_selectedDate);
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    loadAttendanceForDate(date);
  }

  Future<void> loadAttendanceForDate(DateTime date) async {
    if (_selectedClass == null) return;
    _isLoading = true;
    _selectedDate = date;
    _studentStatusMap.clear();
    _previousStatusMap.clear();
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      _students = await _repoManager.repository.getStudentsByClass(_selectedClass!.classId);

      _currentSession = await _repoManager.repository.getAttendanceSession(
        _selectedClass!.classId,
        dateStr,
      );

      if (_currentSession != null) {
        // Load existing records
        final records = await _repoManager.repository.getAttendanceRecords(_currentSession!.attendanceId);
        final map = {for (var r in records) r.studentId: r.status};

        for (final s in _students) {
          final status = map[s.studentId] ?? 'present';
          _studentStatusMap[s.studentId] = status;
          _previousStatusMap[s.studentId] = status;
        }
      } else {
        // New attendance session:
        // Rule: All students must initially appear as PRESENT!
        for (final s in _students) {
          _studentStatusMap[s.studentId] = 'present';
          _previousStatusMap[s.studentId] = 'present';
        }
      }
    } catch (e) {
      _errorMessage = 'Error loading attendance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStudentStatus(String studentId, String status) {
    _studentStatusMap[studentId] = status;
    notifyListeners();
  }

  Future<bool> submitAttendance(String teacherUserId) async {
    if (_selectedClass == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = selectedDateFormatted;
      final sessionId = _currentSession?.attendanceId ?? 'att_${_selectedClass!.classId}_$dateStr';

      final wasAlreadySubmitted = _currentSession?.submitted ?? false;

      final updatedSession = AttendanceSession(
        attendanceId: sessionId,
        date: dateStr,
        classId: _selectedClass!.classId,
        submitted: true,
        submittedBy: teacherUserId,
        submittedAt: DateTime.now(),
      );

      // Prepare records
      final records = <AttendanceRecord>[];
      for (final s in _students) {
        final currentStatus = _studentStatusMap[s.studentId] ?? 'present';
        final recId = 'rec_${sessionId}_${s.studentId}';

        records.add(AttendanceRecord(
          recordId: recId,
          attendanceId: sessionId,
          studentId: s.studentId,
          status: currentStatus,
          updatedAt: DateTime.now(),
          updatedBy: teacherUserId,
        ));

        // Notification logic:
        if (!wasAlreadySubmitted) {
          // First time submission:
          // "If an absent student exists: create a notification for the linked parent.
          //  Do NOT create absence notifications for students marked Present."
          if (currentStatus == 'absent') {
            for (final parentId in s.parentIds) {
              await _repoManager.repository.createNotification(
                AppNotification(
                  notificationId: _uuid.v4(),
                  userId: parentId,
                  studentId: s.studentId,
                  title: 'Attendance Alert',
                  body: '${s.name} is absent from school today ($dateStr).',
                  type: 'attendance',
                  createdAt: DateTime.now(),
                ),
              );
            }
          }
        } else {
          // Attendance was already submitted, this is an update/correction:
          final prevStatus = _previousStatusMap[s.studentId];
          if (prevStatus == 'absent' && currentStatus == 'present') {
            // "If Absent is corrected to Present: create another parent notification:
            //  Attendance for Ali Khan has been corrected."
            for (final parentId in s.parentIds) {
              await _repoManager.repository.createNotification(
                AppNotification(
                  notificationId: _uuid.v4(),
                  userId: parentId,
                  studentId: s.studentId,
                  title: 'Attendance Corrected',
                  body: 'Attendance for ${s.name} has been corrected to Present.',
                  type: 'attendance_correction',
                  createdAt: DateTime.now(),
                ),
              );
            }
          } else if (prevStatus != 'absent' && currentStatus == 'absent') {
            // New absence marked during correction
            for (final parentId in s.parentIds) {
              await _repoManager.repository.createNotification(
                AppNotification(
                  notificationId: _uuid.v4(),
                  userId: parentId,
                  studentId: s.studentId,
                  title: 'Attendance Alert',
                  body: '${s.name} has been marked absent for today ($dateStr).',
                  type: 'attendance',
                  createdAt: DateTime.now(),
                ),
              );
            }
          }
        }
      }

      await _repoManager.repository.saveAttendanceSession(updatedSession);
      await _repoManager.repository.saveAttendanceRecords(records);

      _currentSession = updatedSession;
      _previousStatusMap = Map.from(_studentStatusMap);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit attendance: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Calculate Attendance Percentage for a student
  Future<Map<String, dynamic>> calculateStudentAttendance(String studentId) async {
    final records = await _repoManager.repository.getStudentAttendanceHistory(studentId);
    final holidays = await _repoManager.repository.getHolidays();
    final holidayDates = holidays.map((h) => h.date).toSet();

    int validDays = 0;
    int presentDays = 0;
    int absentDays = 0;
    int lateDays = 0;
    int leaveDays = 0;

    for (final r in records) {
      // Find session or date to verify holiday exclusion
      // Record IDs are in form rec_att_classId_dateStr_studentId
      final parts = r.attendanceId.split('_');
      final dateStr = parts.isNotEmpty ? parts.last : '';

      if (holidayDates.contains(dateStr)) {
        continue; // Exclude holidays
      }

      validDays++;
      if (r.status == 'present') {
        presentDays++;
      } else if (r.status == 'late') {
        lateDays++;
        // Count late as present or partial
        presentDays++;
      } else if (r.status == 'absent') {
        absentDays++;
      } else if (r.status == 'leave') {
        leaveDays++;
      }
    }

    final double percentage = validDays > 0 ? (presentDays / validDays) * 100 : 100.0;
    final isLowAttendance = percentage < (_settings?.minimumAttendancePercentage ?? 75.0);

    return {
      'percentage': percentage,
      'validDays': validDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'leaveDays': leaveDays,
      'isLowAttendance': isLowAttendance,
      'records': records,
    };
  }
}
