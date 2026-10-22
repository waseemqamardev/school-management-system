import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student_model.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../models/attendance_record_model.dart';
import '../models/diary_model.dart';
import '../models/diary_entry_model.dart';
import '../models/mark_model.dart';
import '../models/school_settings_model.dart';
import '../services/repository_manager.dart';

class ParentProvider extends ChangeNotifier {
  final RepositoryManager _repoManager;

  List<Student> _children = [];
  List<SchoolClass> _availableClasses = [];
  Student? _selectedChild;
  SchoolClass? _childClass;

  // Today status
  String? _todayAttendanceStatus;
  bool _isAttendanceSubmittedToday = false;
  ClassDiary? _todayDiary;
  List<Subject> _classSubjects = [];
  final Map<String, DiaryEntry> _todayDiaryEntries = {};
  StudentMark? _latestMark;

  // History
  List<AttendanceRecord> _attendanceRecords = [];
  double _attendancePercentage = 100.0;
  bool _isLowAttendance = false;
  List<StudentMark> _childMarks = [];
  double _averageMarksPercentage = 0.0;

  bool _isLoading = false;
  String? _errorMessage;
  SchoolSettings? _settings;

  ParentProvider(this._repoManager);

  List<Student> get children => _children;
  List<SchoolClass> get availableClasses => _availableClasses;
  Student? get selectedChild => _selectedChild;
  SchoolClass? get childClass => _childClass;
  String? get todayAttendanceStatus => _todayAttendanceStatus;
  bool get isAttendanceSubmittedToday => _isAttendanceSubmittedToday;
  ClassDiary? get todayDiary => _todayDiary;
  List<Subject> get classSubjects => _classSubjects;
  Map<String, DiaryEntry> get todayDiaryEntries => _todayDiaryEntries;
  StudentMark? get latestMark => _latestMark;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  double get attendancePercentage => _attendancePercentage;
  bool get isLowAttendance => _isLowAttendance;
  List<StudentMark> get childMarks => _childMarks;
  double get averageMarksPercentage => _averageMarksPercentage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initializeForParent(String parentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _repoManager.repository.getSettings();
      _availableClasses = await _repoManager.repository.getClasses();
      _children = await _repoManager.repository.getStudentsByParentUserId(parentUserId);

      if (_children.isNotEmpty) {
        _selectedChild = _children.first;
        await loadChildData(_selectedChild!);
      } else {
        _selectedChild = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load parent data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectChild(Student child) {
    _selectedChild = child;
    loadChildData(child);
  }

  Future<void> loadChildData(Student child) async {
    _isLoading = true;
    notifyListeners();

    try {
      _childClass = await _repoManager.repository.getClassById(child.classId);
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 1. Today Attendance
      final session = await _repoManager.repository.getAttendanceSession(child.classId, todayStr);
      _isAttendanceSubmittedToday = session?.submitted ?? false;
      if (session != null && session.submitted) {
        final records = await _repoManager.repository.getAttendanceRecords(session.attendanceId);
        final myRecord = records.firstWhere(
          (r) => r.studentId == child.studentId,
          orElse: () => AttendanceRecord(
            recordId: '',
            attendanceId: '',
            studentId: '',
            status: 'pending',
            updatedAt: DateTime.now(),
            updatedBy: '',
          ),
        );
        _todayAttendanceStatus = myRecord.status;
      } else {
        _todayAttendanceStatus = 'Pending';
      }

      // 2. Attendance History & Calculation
      _attendanceRecords = await _repoManager.repository.getStudentAttendanceHistory(child.studentId);
      final holidays = await _repoManager.repository.getHolidays();
      final holidayDates = holidays.map((h) => h.date).toSet();

      int validDays = 0;
      int presentDays = 0;
      for (final r in _attendanceRecords) {
        final parts = r.attendanceId.split('_');
        final dateStr = parts.isNotEmpty ? parts.last : '';
        if (holidayDates.contains(dateStr)) continue;

        validDays++;
        if (r.status == 'present' || r.status == 'late') {
          presentDays++;
        }
      }
      _attendancePercentage = validDays > 0 ? (presentDays / validDays) * 100 : 100.0;
      _isLowAttendance = _attendancePercentage < (_settings?.minimumAttendancePercentage ?? 75.0);

      // 3. Today Diary
      _classSubjects = await _repoManager.repository.getSubjectsByClass(child.classId);
      _todayDiary = await _repoManager.repository.getClassDiary(child.classId, todayStr);
      _todayDiaryEntries.clear();
      if (_todayDiary != null) {
        final entries = await _repoManager.repository.getDiaryEntries(_todayDiary!.diaryId);
        for (final e in entries) {
          _todayDiaryEntries[e.subjectId] = e;
        }
      }

      // 4. Marks
      _childMarks = await _repoManager.repository.getMarksForStudent(child.studentId);
      if (_childMarks.isNotEmpty) {
        _latestMark = _childMarks.first;
        double totObtained = 0.0;
        double totMax = 0.0;
        for (final m in _childMarks) {
          totObtained += m.obtainedMarks;
          totMax += m.totalMarks;
        }
        _averageMarksPercentage = totMax > 0 ? (totObtained / totMax) * 100 : 0.0;
      } else {
        _latestMark = null;
        _averageMarksPercentage = 0.0;
      }
    } catch (e) {
      _errorMessage = 'Failed to load details for ${child.name}: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> loadDiaryForDate(DateTime date) async {
    if (_selectedChild == null) return {};
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final diary = await _repoManager.repository.getClassDiary(_selectedChild!.classId, dateStr);
    final entriesMap = <String, DiaryEntry>{};

    if (diary != null) {
      final entries = await _repoManager.repository.getDiaryEntries(diary.diaryId);
      for (final e in entries) {
        entriesMap[e.subjectId] = e;
      }
    }

    return {
      'diary': diary,
      'entries': entriesMap,
      'subjects': _classSubjects,
    };
  }

  // --- Parent & Student Direct Linking Methods ---
  Future<Student?> verifyStudentByUniqueCode(String code) async {
    try {
      return await _repoManager.repository.findStudentByUniqueCode(code);
    } catch (e) {
      debugPrint('Error finding student by code: $e');
      return null;
    }
  }

  Future<bool> linkChildByUniqueCode({
    required String parentUserId,
    required String code,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final student = await _repoManager.repository.findStudentByUniqueCode(code);
      if (student == null) {
        _errorMessage = 'No student found with Link ID / Admission Code "$code". Please check the code provided by the school.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _repoManager.repository.linkParentToStudent(parentUserId, student.studentId);
      if (success) {
        await initializeForParent(parentUserId);
        final match = _children.firstWhere(
          (c) => c.studentId == student.studentId,
          orElse: () => student,
        );
        selectChild(match);
        return true;
      } else {
        _errorMessage = 'Failed to connect student to your account.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Student?> verifyStudent({required String rollNumber, required String classId}) async {
    try {
      return await _repoManager.repository.findStudentByRollNumberAndClass(rollNumber, classId);
    } catch (e) {
      debugPrint('Error finding student: $e');
      return null;
    }
  }

  Future<bool> linkChildByRollNumber({
    required String parentUserId,
    required String rollNumber,
    required String classId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final student = await _repoManager.repository.findStudentByRollNumberAndClass(rollNumber, classId);
      if (student == null) {
        _errorMessage = 'No student found with Roll #$rollNumber in the selected class.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _repoManager.repository.linkParentToStudent(parentUserId, student.studentId);
      if (success) {
        await initializeForParent(parentUserId);
        // Switch to the newly linked child
        final match = _children.firstWhere(
          (c) => c.studentId == student.studentId,
          orElse: () => student,
        );
        selectChild(match);
        return true;
      } else {
        _errorMessage = 'Failed to connect student to your account.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unlinkChild({
    required String parentUserId,
    required String studentId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repoManager.repository.unlinkParentFromStudent(parentUserId, studentId);
      if (success) {
        await initializeForParent(parentUserId);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Unlink failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
