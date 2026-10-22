import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../models/teacher_model.dart';
import '../models/student_model.dart';
import '../models/parent_model.dart';
import '../models/holiday_model.dart';
import '../models/school_settings_model.dart';
import '../services/repository_manager.dart';
import '../services/seed_data.dart';

class ClassTodaySummary {
  final SchoolClass schoolClass;
  final bool attendanceSubmitted;
  final int presentCount;
  final int absentCount;
  final int totalStudents;
  final bool diaryPublished;
  final int completedSubjects;
  final int totalSubjects;

  ClassTodaySummary({
    required this.schoolClass,
    required this.attendanceSubmitted,
    required this.presentCount,
    required this.absentCount,
    required this.totalStudents,
    required this.diaryPublished,
    required this.completedSubjects,
    required this.totalSubjects,
  });
}

class AdminProvider extends ChangeNotifier {
  final RepositoryManager _repoManager;
  final _uuid = const Uuid();

  List<SchoolClass> _classes = [];
  List<Subject> _subjects = [];
  List<TeacherProfile> _teachers = [];
  List<Student> _students = [];
  List<ParentProfile> _parents = [];
  List<AppUser> _users = [];
  List<SchoolHoliday> _holidays = [];
  SchoolSettings? _settings;

  List<ClassTodaySummary> _classSummaries = [];
  int _totalAbsentToday = 0;
  int _attendancePendingClassesCount = 0;
  int _diaryPublishedClassesCount = 0;
  int _diaryPendingClassesCount = 0;

  bool _isLoading = false;
  String? _errorMessage;

  AdminProvider(this._repoManager);

  List<SchoolClass> get classes => _classes;
  List<Subject> get subjects => _subjects;
  List<TeacherProfile> get teachers => _teachers;
  List<Student> get students => _students.where((s) => s.active).toList();
  List<ParentProfile> get parents => _parents;
  List<AppUser> get users => _users;
  List<SchoolHoliday> get holidays => _holidays;
  SchoolSettings? get settings => _settings;
  List<ClassTodaySummary> get classSummaries => _classSummaries;

  int get totalStudentsCount => students.length;
  int get totalTeachersCount => _teachers.length;
  int get totalClassesCount => _classes.length;
  int get totalAbsentToday => _totalAbsentToday;
  int get attendancePendingClassesCount => _attendancePendingClassesCount;
  int get diaryPublishedClassesCount => _diaryPublishedClassesCount;
  int get diaryPendingClassesCount => _diaryPendingClassesCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final repo = _repoManager.repository;
      _classes = await repo.getClasses();
      _subjects = await repo.getAllSubjects();
      _teachers = await repo.getTeachers();
      _students = await repo.getAllStudents();
      _parents = await repo.getParents();
      _users = await repo.getAllUsers();
      _holidays = await repo.getHolidays();
      _settings = await repo.getSettings();

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final summaries = <ClassTodaySummary>[];
      int totalAbsent = 0;
      int attPending = 0;
      int diaryPub = 0;
      int diaryPend = 0;

      for (final c in _classes) {
        final session = await repo.getAttendanceSession(c.classId, todayStr);
        final classStudents = await repo.getStudentsByClass(c.classId);
        final isAttSub = session?.submitted ?? false;

        int pres = 0;
        int abs = 0;

        if (isAttSub && session != null) {
          final records = await repo.getAttendanceRecords(session.attendanceId);
          abs = records.where((r) => r.status == 'absent').length;
          pres = records.where((r) => r.status == 'present' || r.status == 'late').length;
          totalAbsent += abs;
        } else {
          attPending++;
        }

        final classSubjects = await repo.getSubjectsByClass(c.classId);
        final diary = await repo.getClassDiary(c.classId, todayStr);
        final isDiaryPub = diary?.published ?? false;

        int completedSub = 0;
        if (diary != null) {
          final entries = await repo.getDiaryEntries(diary.diaryId);
          completedSub = entries.where((e) => e.status == 'completed').length;
        }

        if (isDiaryPub) {
          diaryPub++;
        } else {
          diaryPend++;
        }

        summaries.add(ClassTodaySummary(
          schoolClass: c,
          attendanceSubmitted: isAttSub,
          presentCount: pres,
          absentCount: abs,
          totalStudents: classStudents.length,
          diaryPublished: isDiaryPub,
          completedSubjects: completedSub,
          totalSubjects: classSubjects.length,
        ));
      }

      _classSummaries = summaries;
      _totalAbsentToday = totalAbsent;
      _attendancePendingClassesCount = attPending;
      _diaryPublishedClassesCount = diaryPub;
      _diaryPendingClassesCount = diaryPend;
    } catch (e) {
      _errorMessage = 'Failed to load admin dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CRUD for Classes
  Future<bool> saveClass(SchoolClass schoolClass) async {
    try {
      await _repoManager.repository.saveClass(schoolClass);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error saving class: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteClass(String classId) async {
    try {
      await _repoManager.repository.deleteClass(classId);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting class: $e';
      notifyListeners();
      return false;
    }
  }

  // CRUD for Subjects
  Future<bool> saveSubject(Subject subject) async {
    try {
      await _repoManager.repository.saveSubject(subject);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error saving subject: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(String subjectId) async {
    try {
      await _repoManager.repository.deleteSubject(subjectId);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting subject: $e';
      notifyListeners();
      return false;
    }
  }

  // CRUD for Students
  Future<bool> saveStudent(Student student) async {
    try {
      await _repoManager.repository.saveStudent(student);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error saving student: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateStudent(String studentId) async {
    try {
      await _repoManager.repository.deleteStudent(studentId);
      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error deactivating student: $e';
      notifyListeners();
      return false;
    }
  }

  // CRUD for Teachers
  Future<bool> createTeacherUserAndProfile({
    required String name,
    required String email,
    required String phone,
    required List<String> assignedClassIds,
    required List<String> assignedSubjectIds,
  }) async {
    try {
      final userId = 'user_${_uuid.v4().substring(0, 8)}';
      final user = AppUser(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        role: 'teacher',
        schoolId: SeedData.schoolId,
      );
      await _repoManager.repository.createUser(user);

      final teacherProfile = TeacherProfile(
        teacherId: 'teacher_${_uuid.v4().substring(0, 8)}',
        userId: userId,
        assignedClassIds: assignedClassIds,
        assignedSubjectIds: assignedSubjectIds,
      );
      await _repoManager.repository.saveTeacher(teacherProfile);

      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error adding teacher: $e';
      notifyListeners();
      return false;
    }
  }

  // CRUD for Parents
  Future<bool> createParentUserAndProfile({
    required String name,
    required String email,
    required String phone,
    required List<String> studentIds,
  }) async {
    try {
      final userId = 'user_${_uuid.v4().substring(0, 8)}';
      final user = AppUser(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        role: 'parent',
        schoolId: SeedData.schoolId,
      );
      await _repoManager.repository.createUser(user);

      final parentProfile = ParentProfile(
        parentId: 'parent_${_uuid.v4().substring(0, 8)}',
        userId: userId,
        studentIds: studentIds,
      );
      await _repoManager.repository.saveParent(parentProfile);

      // Link parent to students
      for (final sId in studentIds) {
        final st = await _repoManager.repository.getStudentById(sId);
        if (st != null && !st.parentIds.contains(userId)) {
          final updatedParentIds = List<String>.from(st.parentIds)..add(userId);
          await _repoManager.repository.saveStudent(st.copyWith(parentIds: updatedParentIds));
        }
      }

      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error adding parent: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateParentStudentLinks({
    required String parentUserId,
    required List<String> updatedStudentIds,
  }) async {
    try {
      final parent = await _repoManager.repository.getParentByUserId(parentUserId);
      final currentStudentIds = parent?.studentIds ?? [];

      // Unlink removed students
      for (final sId in currentStudentIds) {
        if (!updatedStudentIds.contains(sId)) {
          await _repoManager.repository.unlinkParentFromStudent(parentUserId, sId);
        }
      }

      // Link newly added students
      for (final sId in updatedStudentIds) {
        if (!currentStudentIds.contains(sId)) {
          await _repoManager.repository.linkParentToStudent(parentUserId, sId);
        }
      }

      await loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating parent links: $e';
      notifyListeners();
      return false;
    }
  }

  // CRUD for Holidays
  Future<bool> addHoliday(String date, String title) async {
    try {
      final holiday = SchoolHoliday(
        holidayId: 'hol_${_uuid.v4().substring(0, 8)}',
        date: date,
        title: title,
        schoolId: SeedData.schoolId,
      );
      await _repoManager.repository.saveHoliday(holiday);
      _holidays = await _repoManager.repository.getHolidays();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error saving holiday: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteHoliday(String holidayId) async {
    try {
      await _repoManager.repository.deleteHoliday(holidayId);
      _holidays = await _repoManager.repository.getHolidays();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting holiday: $e';
      notifyListeners();
      return false;
    }
  }

  // Settings
  Future<bool> updateSettings(SchoolSettings newSettings) async {
    try {
      await _repoManager.repository.updateSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error saving settings: $e';
      notifyListeners();
      return false;
    }
  }

  // Reports
  Future<List<Map<String, dynamic>>> getLowAttendanceStudents() async {
    final list = <Map<String, dynamic>>[];
    final holidays = await _repoManager.repository.getHolidays();
    final holidayDates = holidays.map((h) => h.date).toSet();
    final threshold = _settings?.minimumAttendancePercentage ?? 75.0;

    for (final s in students) {
      final records = await _repoManager.repository.getStudentAttendanceHistory(s.studentId);
      int validDays = 0;
      int presentDays = 0;

      for (final r in records) {
        final parts = r.attendanceId.split('_');
        final dateStr = parts.isNotEmpty ? parts.last : '';
        if (holidayDates.contains(dateStr)) continue;

        validDays++;
        if (r.status == 'present' || r.status == 'late') {
          presentDays++;
        }
      }

      final percentage = validDays > 0 ? (presentDays / validDays) * 100 : 100.0;
      if (percentage < threshold) {
        final cls = _classes.firstWhere(
          (c) => c.classId == s.classId,
          orElse: () => SchoolClass(classId: '', schoolId: '', name: 'Class', section: '', classTeacherId: ''),
        );
        list.add({
          'student': s,
          'className': cls.displayName,
          'percentage': percentage,
          'validDays': validDays,
          'presentDays': presentDays,
        });
      }
    }

    return list;
  }
}
