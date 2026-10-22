import 'package:flutter_test/flutter_test.dart';
import 'package:darearqam_school/services/repository_manager.dart';
import 'package:darearqam_school/providers/auth_provider.dart';
import 'package:darearqam_school/providers/attendance_provider.dart';
import 'package:darearqam_school/providers/diary_provider.dart';
import 'package:darearqam_school/providers/marks_provider.dart';
import 'package:darearqam_school/providers/parent_provider.dart';
import 'package:darearqam_school/providers/admin_provider.dart';

void main() {
  group('Dar-e-Arqam School Prototype Workflows', () {
    late RepositoryManager repoManager;

    setUp(() async {
      repoManager = RepositoryManager();
      await repoManager.initialize();
    });

    test('Auth Workflow: Login with Admin, Teacher, and Parent roles', () async {
      final auth = AuthProvider(repoManager);

      // Admin Login
      final adminSuccess = await auth.login('admin@daralarqam.demo', '123456');
      expect(adminSuccess, isTrue);
      expect(auth.isAdmin, isTrue);
      expect(auth.isTeacher, isFalse);
      expect(auth.isParent, isFalse);

      auth.logout();
      expect(auth.isAuthenticated, isFalse);

      // Teacher Login
      final teacherSuccess = await auth.login('teacher@daralarqam.demo', '123456');
      expect(teacherSuccess, isTrue);
      expect(auth.isTeacher, isTrue);
      expect(auth.teacherProfile, isNotNull);

      auth.logout();

      // Parent Login
      final parentSuccess = await auth.login('parent@daralarqam.demo', '123456');
      expect(parentSuccess, isTrue);
      expect(auth.isParent, isTrue);
      expect(auth.parentProfile, isNotNull);
    });

    test('FLOW 1 - Attendance Workflow: Default Present, Mark Absent, Submit, Parent Alert', () async {
      final attProvider = AttendanceProvider(repoManager);
      await attProvider.initializeForClass('class_8a');

      // 1. Initial State must be Pending and all students default to Present
      expect(attProvider.isSubmitted, isFalse);
      expect(attProvider.isPending, isTrue);
      expect(attProvider.students.length, 10);
      expect(attProvider.presentCount, 10);
      expect(attProvider.absentCount, 0);

      // 2. Mark Ali Khan (student_01) and Sana Ahmed (student_02) as Absent
      attProvider.setStudentStatus('student_01', 'absent');
      attProvider.setStudentStatus('student_02', 'absent');
      expect(attProvider.absentCount, 2);
      expect(attProvider.presentCount, 8);

      // 3. Submit Attendance
      final submitted = await attProvider.submitAttendance('user_teacher_ahmed');
      expect(submitted, isTrue);
      expect(attProvider.isSubmitted, isTrue);

      // 4. Verify Ali Khan's linked parent (user_parent_tariq) received Attendance Alert notification
      final parentNotifs = await repoManager.repository.getNotificationsForUser('user_parent_tariq');
      final absentAlert = parentNotifs.firstWhere(
        (n) => n.type == 'attendance' && n.studentId == 'student_01',
      );
      expect(absentAlert.title, 'Attendance Alert');
      expect(absentAlert.body, contains('Ali Khan is absent from school today'));
    });

    test('FLOW 4 - Attendance Correction Workflow: Absent -> Present triggers correction notification', () async {
      final attProvider = AttendanceProvider(repoManager);
      await attProvider.initializeForClass('class_8a');

      // Mark student_01 absent and submit
      attProvider.setStudentStatus('student_01', 'absent');
      await attProvider.submitAttendance('user_teacher_ahmed');

      // Teacher corrects Absent to Present
      attProvider.setStudentStatus('student_01', 'present');
      final corrected = await attProvider.submitAttendance('user_teacher_ahmed');
      expect(corrected, isTrue);

      // Verify Correction notification created for parent
      final parentNotifs = await repoManager.repository.getNotificationsForUser('user_parent_tariq');
      final corrNotif = parentNotifs.firstWhere(
        (n) => n.type == 'attendance_correction' && n.studentId == 'student_01',
      );
      expect(corrNotif.title, 'Attendance Corrected');
      expect(corrNotif.body, contains('Attendance for Ali Khan has been corrected to Present'));
    });

    test('FLOW 2 - Diary Workflow: Save Draft, Done, and Publish Class Diary to Parents', () async {
      final diaryProvider = DiaryProvider(repoManager);
      await diaryProvider.initialize('class_8a');

      // Save Math Diary as Done
      final doneSuccess = await diaryProvider.saveSubjectEntry(
        subjectId: 'subj_math_8a',
        teacherId: 'user_teacher_ahmed',
        homework: 'Exercise 5.2 Q1-5',
        classwork: 'Algebraic Identities Intro',
        testInfo: 'Quiz on Friday',
        instructions: 'Bring geometry box',
        isDone: true,
      );
      expect(doneSuccess, isTrue);
      expect(diaryProvider.getEntryForSubject('subj_math_8a')?.status, 'completed');

      // Publish Class Diary
      final pubSuccess = await diaryProvider.publishClassDiary('user_teacher_ahmed');
      expect(pubSuccess, isTrue);
      expect(diaryProvider.isPublished, isTrue);

      // Verify class parent received ONE notification
      final parentNotifs = await repoManager.repository.getNotificationsForUser('user_parent_tariq');
      final diaryNotif = parentNotifs.firstWhere((n) => n.type == 'diary');
      expect(diaryNotif.title, "Today's Diary");
      expect(diaryNotif.body, contains("today's diary is ready"));
    });

    test('FLOW 3 - Marks Workflow: Teacher saves marks and parent notification is generated', () async {
      final marksProvider = MarksProvider(repoManager);
      await marksProvider.initialize('class_8a');

      final markSaved = await marksProvider.saveMark(
        studentId: 'student_01',
        classId: 'class_8a',
        subjectId: 'subj_math_8a',
        examType: 'Weekly Test',
        obtainedMarks: 19.5,
        totalMarks: 20.0,
        feedback: 'Superb understanding of linear equations!',
        teacherUserId: 'user_teacher_ahmed',
      );
      expect(markSaved, isTrue);

      // Parent notification check
      final parentNotifs = await repoManager.repository.getNotificationsForUser('user_parent_tariq');
      final markNotif = parentNotifs.firstWhere(
        (n) => n.type == 'marks' && n.studentId == 'student_01',
      );
      expect(markNotif.title, 'New Test Result');
      expect(markNotif.body, contains("Ali Khan's Mathematics test report is available"));
    });

    test('Parent Child Switcher & Calculations', () async {
      final parentProvider = ParentProvider(repoManager);
      // Tariq Khan is linked to Ali Khan and Usman Khan
      await parentProvider.initializeForParent('user_parent_tariq');

      expect(parentProvider.children.length, 2);
      expect(parentProvider.selectedChild?.name, 'Ali Khan');

      // Switch to Usman Khan
      final usman = parentProvider.children.firstWhere((c) => c.name == 'Usman Khan');
      parentProvider.selectChild(usman);
      expect(parentProvider.selectedChild?.name, 'Usman Khan');
      expect(parentProvider.attendancePercentage, greaterThan(0));
    });

    test('Admin Dashboard & Low Attendance Report Calculation', () async {
      final adminProvider = AdminProvider(repoManager);
      await adminProvider.loadDashboard();

      expect(adminProvider.totalStudentsCount, greaterThanOrEqualTo(10));
      expect(adminProvider.totalTeachersCount, greaterThanOrEqualTo(3));
      expect(adminProvider.totalClassesCount, greaterThanOrEqualTo(3));
      expect(adminProvider.classSummaries.isNotEmpty, isTrue);
    });
  });
}
