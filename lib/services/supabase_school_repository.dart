import 'package:supabase_flutter/supabase_flutter.dart';
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

class SupabaseSchoolRepository implements ISchoolRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // 1. Users
  @override
  Future<AppUser?> getUserById(String userId) async {
    final res = await _client.from('users').select().eq('user_id', userId).maybeSingle();
    if (res == null) return null;
    return AppUser(
      userId: res['user_id'] as String,
      name: res['name'] as String? ?? '',
      email: res['email'] as String? ?? '',
      phone: res['phone'] as String? ?? '',
      role: res['role'] as String? ?? 'parent',
      schoolId: res['school_id'] as String? ?? '',
      active: res['active'] as bool? ?? true,
    );
  }

  @override
  Future<AppUser?> getUserByEmail(String email) async {
    final res = await _client.from('users').select().ilike('email', email.trim()).maybeSingle();
    if (res == null) return null;
    return AppUser(
      userId: res['user_id'] as String,
      name: res['name'] as String? ?? '',
      email: res['email'] as String? ?? '',
      phone: res['phone'] as String? ?? '',
      role: res['role'] as String? ?? 'parent',
      schoolId: res['school_id'] as String? ?? '',
      active: res['active'] as bool? ?? true,
    );
  }

  @override
  Future<AppUser> createUser(AppUser user) async {
    await _client.from('users').upsert({
      'user_id': user.userId,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'role': user.role,
      'school_id': user.schoolId,
      'active': user.active,
    });
    return user;
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _client.from('users').update({
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'role': user.role,
      'school_id': user.schoolId,
      'active': user.active,
    }).eq('user_id', user.userId);
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final List res = await _client.from('users').select();
    return res.map((r) => AppUser(
      userId: r['user_id'] as String,
      name: r['name'] as String? ?? '',
      email: r['email'] as String? ?? '',
      phone: r['phone'] as String? ?? '',
      role: r['role'] as String? ?? 'parent',
      schoolId: r['school_id'] as String? ?? '',
      active: r['active'] as bool? ?? true,
    )).toList();
  }

  // 2. Classes
  @override
  Future<List<SchoolClass>> getClasses() async {
    final List res = await _client.from('classes').select().order('name');
    return res.map((r) => SchoolClass(
      classId: r['class_id'] as String,
      schoolId: r['school_id'] as String? ?? '',
      name: r['name'] as String? ?? '',
      section: r['section'] as String? ?? '',
      classTeacherId: r['class_teacher_id'] as String? ?? '',
    )).toList();
  }

  @override
  Future<SchoolClass?> getClassById(String classId) async {
    final res = await _client.from('classes').select().eq('class_id', classId).maybeSingle();
    if (res == null) return null;
    return SchoolClass(
      classId: res['class_id'] as String,
      schoolId: res['school_id'] as String? ?? '',
      name: res['name'] as String? ?? '',
      section: res['section'] as String? ?? '',
      classTeacherId: res['class_teacher_id'] as String? ?? '',
    );
  }

  @override
  Future<void> saveClass(SchoolClass schoolClass) async {
    await _client.from('classes').upsert({
      'class_id': schoolClass.classId,
      'school_id': schoolClass.schoolId,
      'name': schoolClass.name,
      'section': schoolClass.section,
      'class_teacher_id': schoolClass.classTeacherId,
    });
  }

  @override
  Future<void> deleteClass(String classId) async {
    await _client.from('classes').delete().eq('class_id', classId);
  }

  // 3. Subjects
  @override
  Future<List<Subject>> getSubjectsByClass(String classId) async {
    final List res = await _client.from('subjects').select().eq('class_id', classId);
    return res.map((r) => Subject(
      subjectId: r['subject_id'] as String,
      name: r['name'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      teacherId: r['teacher_id'] as String? ?? '',
    )).toList();
  }

  @override
  Future<List<Subject>> getAllSubjects() async {
    final List res = await _client.from('subjects').select();
    return res.map((r) => Subject(
      subjectId: r['subject_id'] as String,
      name: r['name'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      teacherId: r['teacher_id'] as String? ?? '',
    )).toList();
  }

  @override
  Future<void> saveSubject(Subject subject) async {
    await _client.from('subjects').upsert({
      'subject_id': subject.subjectId,
      'name': subject.name,
      'class_id': subject.classId,
      'teacher_id': subject.teacherId,
    });
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    await _client.from('subjects').delete().eq('subject_id', subjectId);
  }

  // 4. Teachers
  @override
  Future<List<TeacherProfile>> getTeachers() async {
    final List res = await _client.from('teachers').select();
    return res.map((r) => TeacherProfile(
      teacherId: r['teacher_id'] as String,
      userId: r['user_id'] as String? ?? '',
      assignedClassIds: List<String>.from(r['assigned_class_ids'] ?? []),
      assignedSubjectIds: List<String>.from(r['assigned_subject_ids'] ?? []),
    )).toList();
  }

  @override
  Future<TeacherProfile?> getTeacherByUserId(String userId) async {
    final res = await _client.from('teachers').select().eq('user_id', userId).maybeSingle();
    if (res == null) return null;
    return TeacherProfile(
      teacherId: res['teacher_id'] as String,
      userId: res['user_id'] as String? ?? '',
      assignedClassIds: List<String>.from(res['assigned_class_ids'] ?? []),
      assignedSubjectIds: List<String>.from(res['assigned_subject_ids'] ?? []),
    );
  }

  @override
  Future<void> saveTeacher(TeacherProfile teacher) async {
    await _client.from('teachers').upsert({
      'teacher_id': teacher.teacherId,
      'user_id': teacher.userId,
      'assigned_class_ids': teacher.assignedClassIds,
      'assigned_subject_ids': teacher.assignedSubjectIds,
    });
  }

  // 5. Students
  @override
  Future<List<Student>> getStudentsByClass(String classId) async {
    final List res = await _client
        .from('students')
        .select()
        .eq('class_id', classId)
        .eq('active', true)
        .order('roll_number');
    return res.map((r) => Student(
      studentId: r['student_id'] as String,
      name: r['name'] as String? ?? '',
      rollNumber: r['roll_number'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      parentIds: List<String>.from(r['parent_ids'] ?? []),
      active: r['active'] as bool? ?? true,
      photoUrl: r['photo_url'] as String?,
      linkCode: r['link_code'] as String?,
    )).toList();
  }

  @override
  Future<List<Student>> getStudentsByParentUserId(String userId) async {
    final List res = await _client
        .from('students')
        .select()
        .contains('parent_ids', [userId])
        .eq('active', true);
    return res.map((r) => Student(
      studentId: r['student_id'] as String,
      name: r['name'] as String? ?? '',
      rollNumber: r['roll_number'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      parentIds: List<String>.from(r['parent_ids'] ?? []),
      active: r['active'] as bool? ?? true,
      photoUrl: r['photo_url'] as String?,
      linkCode: r['link_code'] as String?,
    )).toList();
  }

  @override
  Future<List<Student>> getAllStudents() async {
    final List res = await _client.from('students').select().order('roll_number');
    return res.map((r) => Student(
      studentId: r['student_id'] as String,
      name: r['name'] as String? ?? '',
      rollNumber: r['roll_number'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      parentIds: List<String>.from(r['parent_ids'] ?? []),
      active: r['active'] as bool? ?? true,
      photoUrl: r['photo_url'] as String?,
      linkCode: r['link_code'] as String?,
    )).toList();
  }

  @override
  Future<Student?> getStudentById(String studentId) async {
    final res = await _client.from('students').select().eq('student_id', studentId).maybeSingle();
    if (res == null) return null;
    return Student(
      studentId: res['student_id'] as String,
      name: res['name'] as String? ?? '',
      rollNumber: res['roll_number'] as String? ?? '',
      classId: res['class_id'] as String? ?? '',
      parentIds: List<String>.from(res['parent_ids'] ?? []),
      active: res['active'] as bool? ?? true,
      photoUrl: res['photo_url'] as String?,
      linkCode: res['link_code'] as String?,
    );
  }

  @override
  Future<Student?> findStudentByRollNumberAndClass(String rollNumber, String classId) async {
    final res = await _client
        .from('students')
        .select()
        .eq('class_id', classId)
        .eq('roll_number', rollNumber.trim())
        .eq('active', true)
        .maybeSingle();
    if (res == null) return null;
    return Student(
      studentId: res['student_id'] as String,
      name: res['name'] as String? ?? '',
      rollNumber: res['roll_number'] as String? ?? '',
      classId: res['class_id'] as String? ?? '',
      parentIds: List<String>.from(res['parent_ids'] ?? []),
      active: res['active'] as bool? ?? true,
      photoUrl: res['photo_url'] as String?,
      linkCode: res['link_code'] as String?,
    );
  }

  @override
  Future<Student?> findStudentByUniqueCode(String code) async {
    final clean = code.trim();
    if (clean.isEmpty) return null;

    // 1. Match by link_code
    var res = await _client
        .from('students')
        .select()
        .ilike('link_code', clean)
        .eq('active', true)
        .maybeSingle();

    // 2. If not found, match by student_id
    res ??= await _client
        .from('students')
        .select()
        .ilike('student_id', clean)
        .eq('active', true)
        .maybeSingle();

    if (res == null) return null;
    return Student(
      studentId: res['student_id'] as String,
      name: res['name'] as String? ?? '',
      rollNumber: res['roll_number'] as String? ?? '',
      classId: res['class_id'] as String? ?? '',
      parentIds: List<String>.from(res['parent_ids'] ?? []),
      active: res['active'] as bool? ?? true,
      photoUrl: res['photo_url'] as String?,
      linkCode: res['link_code'] as String?,
    );
  }

  @override
  Future<void> saveStudent(Student student) async {
    await _client.from('students').upsert({
      'student_id': student.studentId,
      'name': student.name,
      'roll_number': student.rollNumber,
      'class_id': student.classId,
      'parent_ids': student.parentIds,
      'active': student.active,
      'photo_url': student.photoUrl,
      'link_code': student.linkCode,
    });
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    await _client.from('students').update({'active': false}).eq('student_id', studentId);
  }

  // 6. Parents
  @override
  Future<List<ParentProfile>> getParents() async {
    final List res = await _client.from('parents').select();
    return res.map((r) => ParentProfile(
      parentId: r['parent_id'] as String,
      userId: r['user_id'] as String? ?? '',
      studentIds: List<String>.from(r['student_ids'] ?? []),
    )).toList();
  }

  @override
  Future<ParentProfile?> getParentByUserId(String userId) async {
    final res = await _client.from('parents').select().eq('user_id', userId).maybeSingle();
    if (res == null) return null;
    return ParentProfile(
      parentId: res['parent_id'] as String,
      userId: res['user_id'] as String? ?? '',
      studentIds: List<String>.from(res['student_ids'] ?? []),
    );
  }

  @override
  Future<void> saveParent(ParentProfile parent) async {
    await _client.from('parents').upsert({
      'parent_id': parent.parentId,
      'user_id': parent.userId,
      'student_ids': parent.studentIds,
    });
  }

  @override
  Future<bool> linkParentToStudent(String parentUserId, String studentId) async {
    // 1. Fetch Student and update parent_ids
    final student = await getStudentById(studentId);
    if (student == null) return false;

    if (!student.parentIds.contains(parentUserId)) {
      final updatedParentIds = List<String>.from(student.parentIds)..add(parentUserId);
      await saveStudent(student.copyWith(parentIds: updatedParentIds));
    }

    // 2. Fetch ParentProfile and update student_ids
    final parent = await getParentByUserId(parentUserId);
    if (parent != null) {
      if (!parent.studentIds.contains(studentId)) {
        final updatedStudents = List<String>.from(parent.studentIds)..add(studentId);
        await saveParent(parent.copyWith(studentIds: updatedStudents));
      }
    } else {
      await saveParent(ParentProfile(
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
    final student = await getStudentById(studentId);
    if (student != null) {
      final updated = List<String>.from(student.parentIds)..remove(parentUserId);
      await saveStudent(student.copyWith(parentIds: updated));
    }

    // 2. Remove from parent
    final parent = await getParentByUserId(parentUserId);
    if (parent != null) {
      final updated = List<String>.from(parent.studentIds)..remove(studentId);
      await saveParent(parent.copyWith(studentIds: updated));
    }
    return true;
  }

  // 7. Attendance
  @override
  Future<AttendanceSession?> getAttendanceSession(String classId, String date) async {
    final res = await _client
        .from('attendance')
        .select()
        .eq('class_id', classId)
        .eq('date', date)
        .maybeSingle();
    if (res == null) return null;
    return AttendanceSession(
      attendanceId: res['attendance_id'] as String,
      date: res['date'] as String? ?? '',
      classId: res['class_id'] as String? ?? '',
      submitted: res['submitted'] as bool? ?? false,
      submittedBy: res['submitted_by'] as String?,
      submittedAt: res['submitted_at'] != null ? DateTime.tryParse(res['submitted_at']) : null,
    );
  }

  @override
  Future<void> saveAttendanceSession(AttendanceSession session) async {
    await _client.from('attendance').upsert({
      'attendance_id': session.attendanceId,
      'date': session.date,
      'class_id': session.classId,
      'submitted': session.submitted,
      'submitted_by': session.submittedBy,
      'submitted_at': session.submittedAt?.toIso8601String(),
    });
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceRecords(String attendanceId) async {
    final List res = await _client.from('attendance_records').select().eq('attendance_id', attendanceId);
    return res.map((r) => AttendanceRecord(
      recordId: r['record_id'] as String,
      attendanceId: r['attendance_id'] as String? ?? '',
      studentId: r['student_id'] as String? ?? '',
      status: r['status'] as String? ?? 'present',
      updatedAt: r['updated_at'] != null ? DateTime.tryParse(r['updated_at']) ?? DateTime.now() : DateTime.now(),
      updatedBy: r['updated_by'] as String? ?? '',
    )).toList();
  }

  @override
  Future<void> saveAttendanceRecords(List<AttendanceRecord> records) async {
    if (records.isEmpty) return;
    final payload = records.map((r) => {
      'record_id': r.recordId,
      'attendance_id': r.attendanceId,
      'student_id': r.studentId,
      'status': r.status,
      'updated_at': r.updatedAt.toIso8601String(),
      'updated_by': r.updatedBy,
    }).toList();
    await _client.from('attendance_records').upsert(payload);
  }

  @override
  Future<List<AttendanceRecord>> getStudentAttendanceHistory(String studentId) async {
    final List res = await _client.from('attendance_records').select().eq('student_id', studentId);
    return res.map((r) => AttendanceRecord(
      recordId: r['record_id'] as String,
      attendanceId: r['attendance_id'] as String? ?? '',
      studentId: r['student_id'] as String? ?? '',
      status: r['status'] as String? ?? 'present',
      updatedAt: r['updated_at'] != null ? DateTime.tryParse(r['updated_at']) ?? DateTime.now() : DateTime.now(),
      updatedBy: r['updated_by'] as String? ?? '',
    )).toList();
  }

  @override
  Future<List<AttendanceSession>> getClassAttendanceHistory(String classId) async {
    final List res = await _client.from('attendance').select().eq('class_id', classId).order('date', ascending: false);
    return res.map((r) => AttendanceSession(
      attendanceId: r['attendance_id'] as String,
      date: r['date'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      submitted: r['submitted'] as bool? ?? false,
      submittedBy: r['submitted_by'] as String?,
      submittedAt: r['submitted_at'] != null ? DateTime.tryParse(r['submitted_at']) : null,
    )).toList();
  }

  @override
  Future<List<AttendanceSession>> getTodayAllAttendanceSessions(String date) async {
    final List res = await _client.from('attendance').select().eq('date', date);
    return res.map((r) => AttendanceSession(
      attendanceId: r['attendance_id'] as String,
      date: r['date'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      submitted: r['submitted'] as bool? ?? false,
      submittedBy: r['submitted_by'] as String?,
      submittedAt: r['submitted_at'] != null ? DateTime.tryParse(r['submitted_at']) : null,
    )).toList();
  }

  @override
  Future<List<AttendanceRecord>> getAllRecordsForAttendanceIds(List<String> attendanceIds) async {
    if (attendanceIds.isEmpty) return [];
    final List res = await _client.from('attendance_records').select().filter('attendance_id', 'in', attendanceIds);
    return res.map((r) => AttendanceRecord(
      recordId: r['record_id'] as String,
      attendanceId: r['attendance_id'] as String? ?? '',
      studentId: r['student_id'] as String? ?? '',
      status: r['status'] as String? ?? 'present',
      updatedAt: r['updated_at'] != null ? DateTime.tryParse(r['updated_at']) ?? DateTime.now() : DateTime.now(),
      updatedBy: r['updated_by'] as String? ?? '',
    )).toList();
  }

  // 8. Diary
  @override
  Future<ClassDiary?> getClassDiary(String classId, String date) async {
    final res = await _client
        .from('diaries')
        .select()
        .eq('class_id', classId)
        .eq('date', date)
        .maybeSingle();
    if (res == null) return null;
    return ClassDiary(
      diaryId: res['diary_id'] as String,
      date: res['date'] as String? ?? '',
      classId: res['class_id'] as String? ?? '',
      published: res['published'] as bool? ?? false,
      publishedAt: res['published_at'] != null ? DateTime.tryParse(res['published_at']) : null,
      createdBy: res['created_by'] as String? ?? '',
    );
  }

  @override
  Future<void> saveClassDiary(ClassDiary diary) async {
    await _client.from('diaries').upsert({
      'diary_id': diary.diaryId,
      'date': diary.date,
      'class_id': diary.classId,
      'published': diary.published,
      'published_at': diary.publishedAt?.toIso8601String(),
      'created_by': diary.createdBy,
    });
  }

  @override
  Future<List<DiaryEntry>> getDiaryEntries(String diaryId) async {
    final List res = await _client.from('diary_entries').select().eq('diary_id', diaryId);
    return res.map((r) => DiaryEntry(
      entryId: r['entry_id'] as String,
      diaryId: r['diary_id'] as String? ?? '',
      subjectId: r['subject_id'] as String? ?? '',
      teacherId: r['teacher_id'] as String? ?? '',
      homework: r['homework'] as String? ?? '',
      classwork: r['classwork'] as String? ?? '',
      testInfo: r['test_info'] as String? ?? '',
      instructions: r['instructions'] as String? ?? '',
      status: r['status'] as String? ?? 'draft',
      createdAt: r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now(),
    )).toList();
  }

  @override
  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    await _client.from('diary_entries').upsert({
      'entry_id': entry.entryId,
      'diary_id': entry.diaryId,
      'subject_id': entry.subjectId,
      'teacher_id': entry.teacherId,
      'homework': entry.homework,
      'classwork': entry.classwork,
      'test_info': entry.testInfo,
      'instructions': entry.instructions,
      'status': entry.status,
      'created_at': entry.createdAt.toIso8601String(),
    });
  }

  @override
  Future<List<ClassDiary>> getDiaryHistory(String classId) async {
    final List res = await _client.from('diaries').select().eq('class_id', classId).order('date', ascending: false);
    return res.map((r) => ClassDiary(
      diaryId: r['diary_id'] as String,
      date: r['date'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      published: r['published'] as bool? ?? false,
      publishedAt: r['published_at'] != null ? DateTime.tryParse(r['published_at']) : null,
      createdBy: r['created_by'] as String? ?? '',
    )).toList();
  }

  // 9. Marks
  @override
  Future<List<StudentMark>> getMarksForStudent(String studentId) async {
    final List res = await _client.from('marks').select().eq('student_id', studentId).order('created_at', ascending: false);
    return res.map((r) => StudentMark(
      markId: r['mark_id'] as String,
      studentId: r['student_id'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      subjectId: r['subject_id'] as String? ?? '',
      examType: r['exam_type'] as String? ?? 'Weekly Test',
      obtainedMarks: (r['obtained_marks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (r['total_marks'] as num?)?.toDouble() ?? 100.0,
      feedback: r['feedback'] as String? ?? '',
      createdBy: r['created_by'] as String? ?? '',
      createdAt: r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now(),
    )).toList();
  }

  @override
  Future<List<StudentMark>> getMarksForClass(String classId) async {
    final List res = await _client.from('marks').select().eq('class_id', classId).order('created_at', ascending: false);
    return res.map((r) => StudentMark(
      markId: r['mark_id'] as String,
      studentId: r['student_id'] as String? ?? '',
      classId: r['class_id'] as String? ?? '',
      subjectId: r['subject_id'] as String? ?? '',
      examType: r['exam_type'] as String? ?? 'Weekly Test',
      obtainedMarks: (r['obtained_marks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (r['total_marks'] as num?)?.toDouble() ?? 100.0,
      feedback: r['feedback'] as String? ?? '',
      createdBy: r['created_by'] as String? ?? '',
      createdAt: r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now(),
    )).toList();
  }

  @override
  Future<void> saveMark(StudentMark mark) async {
    await _client.from('marks').upsert({
      'mark_id': mark.markId,
      'student_id': mark.studentId,
      'class_id': mark.classId,
      'subject_id': mark.subjectId,
      'exam_type': mark.examType,
      'obtained_marks': mark.obtainedMarks,
      'total_marks': mark.totalMarks,
      'feedback': mark.feedback,
      'created_by': mark.createdBy,
      'created_at': mark.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteMark(String markId) async {
    await _client.from('marks').delete().eq('mark_id', markId);
  }

  // 10. Notifications
  @override
  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    final List res = await _client.from('notifications').select().eq('user_id', userId).order('created_at', ascending: false);
    return res.map((r) => AppNotification(
      notificationId: r['notification_id'] as String,
      userId: r['user_id'] as String? ?? '',
      studentId: r['student_id'] as String?,
      title: r['title'] as String? ?? '',
      body: r['body'] as String? ?? '',
      type: r['type'] as String? ?? 'system',
      read: r['read'] as bool? ?? false,
      createdAt: r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now(),
    )).toList();
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    await _client.from('notifications').upsert({
      'notification_id': notification.notificationId,
      'user_id': notification.userId,
      'student_id': notification.studentId,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type,
      'read': notification.read,
      'created_at': notification.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await _client.from('notifications').update({'read': true}).eq('notification_id', notificationId);
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    await _client.from('notifications').update({'read': true}).eq('user_id', userId).eq('read', false);
  }

  // 11. Holidays
  @override
  Future<List<SchoolHoliday>> getHolidays() async {
    final List res = await _client.from('holidays').select().order('date');
    return res.map((r) => SchoolHoliday(
      holidayId: r['holiday_id'] as String,
      date: r['date'] as String? ?? '',
      title: r['title'] as String? ?? '',
      schoolId: r['school_id'] as String? ?? '',
    )).toList();
  }

  @override
  Future<void> saveHoliday(SchoolHoliday holiday) async {
    await _client.from('holidays').upsert({
      'holiday_id': holiday.holidayId,
      'date': holiday.date,
      'title': holiday.title,
      'school_id': holiday.schoolId,
    });
  }

  @override
  Future<void> deleteHoliday(String holidayId) async {
    await _client.from('holidays').delete().eq('holiday_id', holidayId);
  }

  // 12. Settings
  @override
  Future<SchoolSettings> getSettings() async {
    final res = await _client.from('settings').select().eq('school_id', SeedData.schoolId).maybeSingle();
    if (res == null) return SeedData.settings;
    return SchoolSettings(
      schoolId: res['school_id'] as String? ?? SeedData.schoolId,
      attendanceCutoffTime: res['attendance_cutoff_time'] as String? ?? '09:30',
      diaryPublishTime: res['diary_publish_time'] as String? ?? '14:00',
      minimumAttendancePercentage: (res['minimum_attendance_percentage'] as num?)?.toDouble() ?? 75.0,
    );
  }

  @override
  Future<void> updateSettings(SchoolSettings settings) async {
    await _client.from('settings').upsert({
      'school_id': settings.schoolId,
      'attendance_cutoff_time': settings.attendanceCutoffTime,
      'diary_publish_time': settings.diaryPublishTime,
      'minimum_attendance_percentage': settings.minimumAttendancePercentage,
    });
  }

  // 13. Seed Initial Data via Supabase
  @override
  Future<void> seedInitialData() async {
    // 1. Users
    await _client.from('users').upsert(SeedData.users.map((u) => {
      'user_id': u.userId,
      'name': u.name,
      'email': u.email,
      'phone': u.phone,
      'role': u.role,
      'school_id': u.schoolId,
      'active': u.active,
    }).toList());

    // 2. Classes
    await _client.from('classes').upsert(SeedData.classes.map((c) => {
      'class_id': c.classId,
      'school_id': c.schoolId,
      'name': c.name,
      'section': c.section,
      'class_teacher_id': c.classTeacherId,
    }).toList());

    // 3. Subjects
    await _client.from('subjects').upsert(SeedData.subjects.map((s) => {
      'subject_id': s.subjectId,
      'name': s.name,
      'class_id': s.classId,
      'teacher_id': s.teacherId,
    }).toList());

    // 4. Teachers
    await _client.from('teachers').upsert(SeedData.teachers.map((t) => {
      'teacher_id': t.teacherId,
      'user_id': t.userId,
      'assigned_class_ids': t.assignedClassIds,
      'assigned_subject_ids': t.assignedSubjectIds,
    }).toList());

    // 5. Students
    await _client.from('students').upsert(SeedData.students.map((st) => {
      'student_id': st.studentId,
      'name': st.name,
      'roll_number': st.rollNumber,
      'class_id': st.classId,
      'parent_ids': st.parentIds,
      'active': st.active,
      'link_code': st.linkCode,
    }).toList());

    // 6. Parents
    await _client.from('parents').upsert(SeedData.parents.map((p) => {
      'parent_id': p.parentId,
      'user_id': p.userId,
      'student_ids': p.studentIds,
    }).toList());

    // 7. Attendance
    final attData = SeedData.generateInitialAttendance();
    final sessions = attData['sessions'] as List<AttendanceSession>;
    final records = attData['records'] as List<AttendanceRecord>;
    await _client.from('attendance').upsert(sessions.map((s) => {
      'attendance_id': s.attendanceId,
      'date': s.date,
      'class_id': s.classId,
      'submitted': s.submitted,
      'submitted_by': s.submittedBy,
      'submitted_at': s.submittedAt?.toIso8601String(),
    }).toList());
    await _client.from('attendance_records').upsert(records.map((r) => {
      'record_id': r.recordId,
      'attendance_id': r.attendanceId,
      'student_id': r.studentId,
      'status': r.status,
      'updated_at': r.updatedAt.toIso8601String(),
      'updated_by': r.updatedBy,
    }).toList());

    // 8. Diaries
    final diaryData = SeedData.generateInitialDiaries();
    final diaries = diaryData['diaries'] as List<ClassDiary>;
    final entries = diaryData['entries'] as List<DiaryEntry>;
    await _client.from('diaries').upsert(diaries.map((d) => {
      'diary_id': d.diaryId,
      'date': d.date,
      'class_id': d.classId,
      'published': d.published,
      'published_at': d.publishedAt?.toIso8601String(),
      'created_by': d.createdBy,
    }).toList());
    await _client.from('diary_entries').upsert(entries.map((e) => {
      'entry_id': e.entryId,
      'diary_id': e.diaryId,
      'subject_id': e.subjectId,
      'teacher_id': e.teacherId,
      'homework': e.homework,
      'classwork': e.classwork,
      'test_info': e.testInfo,
      'instructions': e.instructions,
      'status': e.status,
      'created_at': e.createdAt.toIso8601String(),
    }).toList());

    // 9. Marks
    await _client.from('marks').upsert(SeedData.marks.map((m) => {
      'mark_id': m.markId,
      'student_id': m.studentId,
      'class_id': m.classId,
      'subject_id': m.subjectId,
      'exam_type': m.examType,
      'obtained_marks': m.obtainedMarks,
      'total_marks': m.totalMarks,
      'feedback': m.feedback,
      'created_by': m.createdBy,
      'created_at': m.createdAt.toIso8601String(),
    }).toList());

    // 10. Notifications
    await _client.from('notifications').upsert(SeedData.notifications.map((n) => {
      'notification_id': n.notificationId,
      'user_id': n.userId,
      'student_id': n.studentId,
      'title': n.title,
      'body': n.body,
      'type': n.type,
      'read': n.read,
      'created_at': n.createdAt.toIso8601String(),
    }).toList());

    // 11. Holidays
    await _client.from('holidays').upsert(SeedData.getHolidays().map((h) => {
      'holiday_id': h.holidayId,
      'date': h.date,
      'title': h.title,
      'school_id': h.schoolId,
    }).toList());

    // 12. Settings
    await _client.from('settings').upsert({
      'school_id': SeedData.settings.schoolId,
      'attendance_cutoff_time': SeedData.settings.attendanceCutoffTime,
      'diary_publish_time': SeedData.settings.diaryPublishTime,
      'minimum_attendance_percentage': SeedData.settings.minimumAttendancePercentage,
    });
  }
}
