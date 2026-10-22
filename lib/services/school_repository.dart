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

abstract class ISchoolRepository {
  // Users & Auth
  Future<AppUser?> getUserById(String userId);
  Future<AppUser?> getUserByEmail(String email);
  Future<AppUser> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
  Future<List<AppUser>> getAllUsers();

  // Classes
  Future<List<SchoolClass>> getClasses();
  Future<SchoolClass?> getClassById(String classId);
  Future<void> saveClass(SchoolClass schoolClass);
  Future<void> deleteClass(String classId);

  // Subjects
  Future<List<Subject>> getSubjectsByClass(String classId);
  Future<List<Subject>> getAllSubjects();
  Future<void> saveSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);

  // Teachers
  Future<List<TeacherProfile>> getTeachers();
  Future<TeacherProfile?> getTeacherByUserId(String userId);
  Future<void> saveTeacher(TeacherProfile teacher);

  // Students
  Future<List<Student>> getStudentsByClass(String classId);
  Future<List<Student>> getStudentsByParentUserId(String userId);
  Future<List<Student>> getAllStudents();
  Future<Student?> getStudentById(String studentId);
  Future<Student?> findStudentByRollNumberAndClass(String rollNumber, String classId);
  Future<Student?> findStudentByUniqueCode(String code);
  Future<void> saveStudent(Student student);
  Future<void> deleteStudent(String studentId);

  // Parents & Linking
  Future<List<ParentProfile>> getParents();
  Future<ParentProfile?> getParentByUserId(String userId);
  Future<void> saveParent(ParentProfile parent);
  Future<bool> linkParentToStudent(String parentUserId, String studentId);
  Future<bool> unlinkParentFromStudent(String parentUserId, String studentId);

  // Attendance
  Future<AttendanceSession?> getAttendanceSession(String classId, String date);
  Future<void> saveAttendanceSession(AttendanceSession session);
  Future<List<AttendanceRecord>> getAttendanceRecords(String attendanceId);
  Future<void> saveAttendanceRecords(List<AttendanceRecord> records);
  Future<List<AttendanceRecord>> getStudentAttendanceHistory(String studentId);
  Future<List<AttendanceSession>> getClassAttendanceHistory(String classId);
  Future<List<AttendanceSession>> getTodayAllAttendanceSessions(String date);
  Future<List<AttendanceRecord>> getAllRecordsForAttendanceIds(List<String> attendanceIds);

  // Diary
  Future<ClassDiary?> getClassDiary(String classId, String date);
  Future<void> saveClassDiary(ClassDiary diary);
  Future<List<DiaryEntry>> getDiaryEntries(String diaryId);
  Future<void> saveDiaryEntry(DiaryEntry entry);
  Future<List<ClassDiary>> getDiaryHistory(String classId);

  // Marks
  Future<List<StudentMark>> getMarksForStudent(String studentId);
  Future<List<StudentMark>> getMarksForClass(String classId);
  Future<void> saveMark(StudentMark mark);
  Future<void> deleteMark(String markId);

  // Notifications
  Future<List<AppNotification>> getNotificationsForUser(String userId);
  Future<void> createNotification(AppNotification notification);
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markAllNotificationsAsRead(String userId);

  // Holidays
  Future<List<SchoolHoliday>> getHolidays();
  Future<void> saveHoliday(SchoolHoliday holiday);
  Future<void> deleteHoliday(String holidayId);

  // Settings
  Future<SchoolSettings> getSettings();
  Future<void> updateSettings(SchoolSettings settings);

  // Seed / Reset
  Future<void> seedInitialData();
}
