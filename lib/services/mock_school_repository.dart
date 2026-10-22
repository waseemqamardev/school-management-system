import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../models/student_model.dart';
import '../models/parent_model.dart';
import '../models/teacher_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_record_model.dart';
import '../models/diary_model.dart';
import '../models/diary_entry_model.dart';
import '../models/mark_model.dart';
import '../models/notification_model.dart';
import '../models/holiday_model.dart';
import '../models/school_settings_model.dart';
import 'school_repository.dart';
import 'seed_data.dart';

class MockSchoolRepository implements ISchoolRepository {
  // In-memory data store
  final List<AppUser> _users = [];
  final List<SchoolClass> _classes = [];
  final List<Subject> _subjects = [];
  final List<TeacherProfile> _teachers = [];
  final List<Student> _students = [];
  final List<ParentProfile> _parents = [];
  final List<AttendanceSession> _attendanceSessions = [];
  final List<AttendanceRecord> _attendanceRecords = [];
  final List<ClassDiary> _diaries = [];
  final List<DiaryEntry> _diaryEntries = [];
  final List<StudentMark> _marks = [];
  final List<AppNotification> _notifications = [];
  final List<SchoolHoliday> _holidays = [];
  late SchoolSettings _settings;

  MockSchoolRepository() {
    _initData();
  }

  void _initData() {
    _users.clear();
    _users.addAll(SeedData.users);

    _classes.clear();
    _classes.addAll(SeedData.classes);

    _subjects.clear();
    _subjects.addAll(SeedData.subjects);

    _teachers.clear();
    _teachers.addAll(SeedData.teachers);

    _students.clear();
    _students.addAll(SeedData.students);

    _parents.clear();
    _parents.addAll(SeedData.parents);

    final attData = SeedData.generateInitialAttendance();
    _attendanceSessions.clear();
    _attendanceSessions.addAll(attData['sessions'] as List<AttendanceSession>);
    _attendanceRecords.clear();
    _attendanceRecords.addAll(attData['records'] as List<AttendanceRecord>);

    final diaryData = SeedData.generateInitialDiaries();
    _diaries.clear();
    _diaries.addAll(diaryData['diaries'] as List<ClassDiary>);
    _diaryEntries.clear();
    _diaryEntries.addAll(diaryData['entries'] as List<DiaryEntry>);

    _marks.clear();
    _marks.addAll(SeedData.marks);

    _notifications.clear();
    _notifications.addAll(SeedData.notifications);

    _holidays.clear();
    _holidays.addAll(SeedData.getHolidays());

    _settings = SeedData.settings;
  }

  @override
  Future<void> seedInitialData() async {
    _initData();
  }

  // Users
  @override
  Future<AppUser?> getUserById(String userId) async {
    try {
      return _users.firstWhere((u) => u.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser?> getUserByEmail(String email) async {
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> createUser(AppUser user) async {
    _users.removeWhere((u) => u.userId == user.userId);
    _users.add(user);
    return user;
  }

  @override
  Future<void> updateUser(AppUser user) async {
    final index = _users.indexWhere((u) => u.userId == user.userId);
    if (index >= 0) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    return List.unmodifiable(_users);
  }

  // Classes
  @override
  Future<List<SchoolClass>> getClasses() async {
    return List.unmodifiable(_classes);
  }

  @override
  Future<SchoolClass?> getClassById(String classId) async {
    try {
      return _classes.firstWhere((c) => c.classId == classId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveClass(SchoolClass schoolClass) async {
    final index = _classes.indexWhere((c) => c.classId == schoolClass.classId);
    if (index >= 0) {
      _classes[index] = schoolClass;
    } else {
      _classes.add(schoolClass);
    }
  }

  @override
  Future<void> deleteClass(String classId) async {
    _classes.removeWhere((c) => c.classId == classId);
  }

  // Subjects
  @override
  Future<List<Subject>> getSubjectsByClass(String classId) async {
    return _subjects.where((s) => s.classId == classId).toList();
  }

  @override
  Future<List<Subject>> getAllSubjects() async {
    return List.unmodifiable(_subjects);
  }

  @override
  Future<void> saveSubject(Subject subject) async {
    final index = _subjects.indexWhere((s) => s.subjectId == subject.subjectId);
    if (index >= 0) {
      _subjects[index] = subject;
    } else {
      _subjects.add(subject);
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    _subjects.removeWhere((s) => s.subjectId == subjectId);
  }

  // Teachers
  @override
  Future<List<TeacherProfile>> getTeachers() async {
    return List.unmodifiable(_teachers);
  }

  @override
  Future<TeacherProfile?> getTeacherByUserId(String userId) async {
    try {
      return _teachers.firstWhere((t) => t.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveTeacher(TeacherProfile teacher) async {
    final index = _teachers.indexWhere((t) => t.teacherId == teacher.teacherId);
    if (index >= 0) {
      _teachers[index] = teacher;
    } else {
      _teachers.add(teacher);
    }
  }

  // Students
  @override
  Future<List<Student>> getStudentsByClass(String classId) async {
    return _students.where((s) => s.classId == classId && s.active).toList()
      ..sort((a, b) => int.tryParse(a.rollNumber)?.compareTo(int.tryParse(b.rollNumber) ?? 0) ?? a.rollNumber.compareTo(b.rollNumber));
  }

  @override
  Future<List<Student>> getStudentsByParentUserId(String userId) async {
    return _students.where((s) => s.parentIds.contains(userId) && s.active).toList();
  }

  @override
  Future<List<Student>> getAllStudents() async {
    return List.unmodifiable(_students);
  }

  @override
  Future<Student?> getStudentById(String studentId) async {
    try {
      return _students.firstWhere((s) => s.studentId == studentId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Student?> findStudentByRollNumberAndClass(String rollNumber, String classId) async {
    try {
      final cleanRoll = rollNumber.trim().toLowerCase();
      return _students.firstWhere(
        (s) => s.active && s.classId == classId && s.rollNumber.trim().toLowerCase() == cleanRoll,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Student?> findStudentByUniqueCode(String code) async {
    final clean = code.trim().toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    if (clean.isEmpty) return null;
    try {
      return _students.firstWhere((s) {
        if (!s.active) return false;
        final linkClean = s.linkCode.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
        final idClean = s.studentId.toLowerCase().replaceAll('-', '').replaceAll('_', '').replaceAll(' ', '');
        return linkClean == clean || idClean == clean || s.linkCode.toLowerCase() == code.trim().toLowerCase();
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveStudent(Student student) async {
    final index = _students.indexWhere((s) => s.studentId == student.studentId);
    if (index >= 0) {
      _students[index] = student;
    } else {
      _students.add(student);
    }
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    final index = _students.indexWhere((s) => s.studentId == studentId);
    if (index >= 0) {
      // Deactivate instead of hard delete
      _students[index] = _students[index].copyWith(active: false);
    }
  }

  // Parents
  @override
  Future<List<ParentProfile>> getParents() async {
    return List.unmodifiable(_parents);
  }

  @override
  Future<ParentProfile?> getParentByUserId(String userId) async {
    try {
      return _parents.firstWhere((p) => p.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveParent(ParentProfile parent) async {
    final index = _parents.indexWhere((p) => p.parentId == parent.parentId);
    if (index >= 0) {
      _parents[index] = parent;
    } else {
      _parents.add(parent);
    }
  }

  @override
  Future<bool> linkParentToStudent(String parentUserId, String studentId) async {
    // 1. Update Student
    final stIdx = _students.indexWhere((s) => s.studentId == studentId);
    if (stIdx < 0) return false;

    final student = _students[stIdx];
    if (!student.parentIds.contains(parentUserId)) {
      final updatedParentIds = List<String>.from(student.parentIds)..add(parentUserId);
      _students[stIdx] = student.copyWith(parentIds: updatedParentIds);
    }

    // 2. Update ParentProfile
    final parentIdx = _parents.indexWhere((p) => p.userId == parentUserId);
    if (parentIdx >= 0) {
      final parent = _parents[parentIdx];
      if (!parent.studentIds.contains(studentId)) {
        final updatedStudents = List<String>.from(parent.studentIds)..add(studentId);
        _parents[parentIdx] = parent.copyWith(studentIds: updatedStudents);
      }
    } else {
      // Create new parent profile if didn't exist
      _parents.add(ParentProfile(
        parentId: 'parent_${DateTime.now().millisecondsSinceEpoch}',
        userId: parentUserId,
        studentIds: [studentId],
      ));
    }
    return true;
  }

  @override
  Future<bool> unlinkParentFromStudent(String parentUserId, String studentId) async {
    // 1. Remove from student
    final stIdx = _students.indexWhere((s) => s.studentId == studentId);
    if (stIdx >= 0) {
      final student = _students[stIdx];
      final updated = List<String>.from(student.parentIds)..remove(parentUserId);
      _students[stIdx] = student.copyWith(parentIds: updated);
    }

    // 2. Remove from parent
    final parentIdx = _parents.indexWhere((p) => p.userId == parentUserId);
    if (parentIdx >= 0) {
      final parent = _parents[parentIdx];
      final updated = List<String>.from(parent.studentIds)..remove(studentId);
      _parents[parentIdx] = parent.copyWith(studentIds: updated);
    }
    return true;
  }

  // Attendance
  @override
  Future<AttendanceSession?> getAttendanceSession(String classId, String date) async {
    try {
      return _attendanceSessions.firstWhere((s) => s.classId == classId && s.date == date);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAttendanceSession(AttendanceSession session) async {
    final index = _attendanceSessions.indexWhere((s) => s.attendanceId == session.attendanceId);
    if (index >= 0) {
      _attendanceSessions[index] = session;
    } else {
      _attendanceSessions.add(session);
    }
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceRecords(String attendanceId) async {
    return _attendanceRecords.where((r) => r.attendanceId == attendanceId).toList();
  }

  @override
  Future<void> saveAttendanceRecords(List<AttendanceRecord> records) async {
    for (final rec in records) {
      final index = _attendanceRecords.indexWhere((r) => r.recordId == rec.recordId);
      if (index >= 0) {
        _attendanceRecords[index] = rec;
      } else {
        _attendanceRecords.add(rec);
      }
    }
  }

  @override
  Future<List<AttendanceRecord>> getStudentAttendanceHistory(String studentId) async {
    return _attendanceRecords.where((r) => r.studentId == studentId).toList();
  }

  @override
  Future<List<AttendanceSession>> getClassAttendanceHistory(String classId) async {
    return _attendanceSessions.where((s) => s.classId == classId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<AttendanceSession>> getTodayAllAttendanceSessions(String date) async {
    return _attendanceSessions.where((s) => s.date == date).toList();
  }

  @override
  Future<List<AttendanceRecord>> getAllRecordsForAttendanceIds(List<String> attendanceIds) async {
    return _attendanceRecords.where((r) => attendanceIds.contains(r.attendanceId)).toList();
  }

  // Diary
  @override
  Future<ClassDiary?> getClassDiary(String classId, String date) async {
    try {
      return _diaries.firstWhere((d) => d.classId == classId && d.date == date);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveClassDiary(ClassDiary diary) async {
    final index = _diaries.indexWhere((d) => d.diaryId == diary.diaryId);
    if (index >= 0) {
      _diaries[index] = diary;
    } else {
      _diaries.add(diary);
    }
  }

  @override
  Future<List<DiaryEntry>> getDiaryEntries(String diaryId) async {
    return _diaryEntries.where((e) => e.diaryId == diaryId).toList();
  }

  @override
  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    final index = _diaryEntries.indexWhere((e) => e.entryId == entry.entryId);
    if (index >= 0) {
      _diaryEntries[index] = entry;
    } else {
      _diaryEntries.add(entry);
    }
  }

  @override
  Future<List<ClassDiary>> getDiaryHistory(String classId) async {
    return _diaries.where((d) => d.classId == classId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Marks
  @override
  Future<List<StudentMark>> getMarksForStudent(String studentId) async {
    return _marks.where((m) => m.studentId == studentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<StudentMark>> getMarksForClass(String classId) async {
    return _marks.where((m) => m.classId == classId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveMark(StudentMark mark) async {
    final index = _marks.indexWhere((m) => m.markId == mark.markId);
    if (index >= 0) {
      _marks[index] = mark;
    } else {
      _marks.add(mark);
    }
  }

  @override
  Future<void> deleteMark(String markId) async {
    _marks.removeWhere((m) => m.markId == markId);
  }

  // Notifications
  @override
  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(read: true);
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }
    }
  }

  // Holidays
  @override
  Future<List<SchoolHoliday>> getHolidays() async {
    return List.unmodifiable(_holidays);
  }

  @override
  Future<void> saveHoliday(SchoolHoliday holiday) async {
    final index = _holidays.indexWhere((h) => h.holidayId == holiday.holidayId);
    if (index >= 0) {
      _holidays[index] = holiday;
    } else {
      _holidays.add(holiday);
    }
  }

  @override
  Future<void> deleteHoliday(String holidayId) async {
    _holidays.removeWhere((h) => h.holidayId == holidayId);
  }

  // Settings
  @override
  Future<SchoolSettings> getSettings() async {
    return _settings;
  }

  @override
  Future<void> updateSettings(SchoolSettings settings) async {
    _settings = settings;
  }
}
