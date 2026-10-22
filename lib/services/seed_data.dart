import 'package:intl/intl.dart';
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

class SeedData {
  static const String schoolId = 'school_darearqam_01';
  static const String class8AId = 'class_8a';

  // User IDs
  static const String adminUserId = 'user_admin_01';
  static const String teacherSirAhmedId = 'user_teacher_ahmed';
  static const String teacherMissSanaId = 'user_teacher_sana';
  static const String teacherSirAliId = 'user_teacher_ali';
  static const String parentTariqKhanId = 'user_parent_tariq';
  static const String parentMrAhmedId = 'user_parent_ahmed';

  // Profile IDs
  static const String teacherProfileAhmedId = 'teacher_prof_ahmed';
  static const String teacherProfileSanaId = 'teacher_prof_sana';
  static const String teacherProfileAliId = 'teacher_prof_ali';
  static const String parentProfileTariqId = 'parent_prof_tariq';
  static const String parentProfileAhmedId = 'parent_prof_ahmed';

  // Demo Users
  static List<AppUser> get users => [
        AppUser(
          userId: adminUserId,
          name: 'Principal Tariq Mehmood',
          email: 'admin@daralarqam.demo',
          phone: '+92 300 1112233',
          role: 'admin',
          schoolId: schoolId,
        ),
        AppUser(
          userId: teacherSirAhmedId,
          name: 'Sir Ahmed',
          email: 'teacher@daralarqam.demo',
          phone: '+92 300 2223344',
          role: 'teacher',
          schoolId: schoolId,
        ),
        AppUser(
          userId: teacherMissSanaId,
          name: 'Miss Sana',
          email: 'sana.teacher@daralarqam.demo',
          phone: '+92 300 3334455',
          role: 'teacher',
          schoolId: schoolId,
        ),
        AppUser(
          userId: teacherSirAliId,
          name: 'Sir Ali',
          email: 'ali.teacher@daralarqam.demo',
          phone: '+92 300 4445566',
          role: 'teacher',
          schoolId: schoolId,
        ),
        AppUser(
          userId: parentTariqKhanId,
          name: 'Tariq Khan (Parent)',
          email: 'parent@daralarqam.demo',
          phone: '+92 300 5556677',
          role: 'parent',
          schoolId: schoolId,
        ),
        AppUser(
          userId: parentMrAhmedId,
          name: 'Mr. Zahid Ahmed',
          email: 'zahid.parent@daralarqam.demo',
          phone: '+92 300 6667788',
          role: 'parent',
          schoolId: schoolId,
        ),
      ];

  // Demo Classes
  static List<SchoolClass> get classes => [
        SchoolClass(
          classId: class8AId,
          schoolId: schoolId,
          name: 'Class 8',
          section: 'A',
          classTeacherId: teacherSirAhmedId,
        ),
        SchoolClass(
          classId: 'class_7a',
          schoolId: schoolId,
          name: 'Class 7',
          section: 'A',
          classTeacherId: teacherMissSanaId,
        ),
        SchoolClass(
          classId: 'class_9b',
          schoolId: schoolId,
          name: 'Class 9',
          section: 'B',
          classTeacherId: teacherSirAliId,
        ),
      ];

  // Demo Subjects for Class 8-A
  static List<Subject> get subjects => [
        Subject(
          subjectId: 'subj_eng_8a',
          name: 'English',
          classId: class8AId,
          teacherId: teacherMissSanaId,
        ),
        Subject(
          subjectId: 'subj_urdu_8a',
          name: 'Urdu',
          classId: class8AId,
          teacherId: teacherMissSanaId,
        ),
        Subject(
          subjectId: 'subj_math_8a',
          name: 'Mathematics',
          classId: class8AId,
          teacherId: teacherSirAhmedId,
        ),
        Subject(
          subjectId: 'subj_sci_8a',
          name: 'Science',
          classId: class8AId,
          teacherId: teacherSirAhmedId,
        ),
        Subject(
          subjectId: 'subj_isl_8a',
          name: 'Islamiat',
          classId: class8AId,
          teacherId: teacherSirAliId,
        ),
        Subject(
          subjectId: 'subj_comp_8a',
          name: 'Computer',
          classId: class8AId,
          teacherId: teacherSirAliId,
        ),
      ];

  // Demo Teachers Profiles
  static List<TeacherProfile> get teachers => [
        TeacherProfile(
          teacherId: teacherProfileAhmedId,
          userId: teacherSirAhmedId,
          assignedClassIds: [class8AId],
          assignedSubjectIds: ['subj_math_8a', 'subj_sci_8a'],
        ),
        TeacherProfile(
          teacherId: teacherProfileSanaId,
          userId: teacherMissSanaId,
          assignedClassIds: [class8AId, 'class_7a'],
          assignedSubjectIds: ['subj_eng_8a', 'subj_urdu_8a'],
        ),
        TeacherProfile(
          teacherId: teacherProfileAliId,
          userId: teacherSirAliId,
          assignedClassIds: [class8AId, 'class_9b'],
          assignedSubjectIds: ['subj_isl_8a', 'subj_comp_8a'],
        ),
      ];

  // Demo Students (10 students as requested)
  static List<Student> get students => [
        Student(
          studentId: 'student_01',
          name: 'Ali Khan',
          rollNumber: '01',
          classId: class8AId,
          parentIds: [parentTariqKhanId],
          linkCode: 'ARQ-8A-01',
        ),
        Student(
          studentId: 'student_02',
          name: 'Sana Ahmed',
          rollNumber: '02',
          classId: class8AId,
          parentIds: [parentMrAhmedId],
          linkCode: 'ARQ-8A-02',
        ),
        Student(
          studentId: 'student_03',
          name: 'Usman Khan',
          rollNumber: '03',
          classId: class8AId,
          parentIds: [parentTariqKhanId], // Tariq Khan has 2 children (Ali & Usman) for child switcher!
          linkCode: 'ARQ-8A-03',
        ),
        Student(
          studentId: 'student_04',
          name: 'Ayesha Noor',
          rollNumber: '04',
          classId: class8AId,
          parentIds: [parentMrAhmedId],
          linkCode: 'ARQ-8A-04',
        ),
        Student(
          studentId: 'student_05',
          name: 'Hamza Ali',
          rollNumber: '05',
          classId: class8AId,
          parentIds: [],
          linkCode: 'ARQ-8A-05',
        ),
        Student(
          studentId: 'student_06',
          name: 'Fatima Khan',
          rollNumber: '06',
          classId: class8AId,
          parentIds: [],
          linkCode: 'ARQ-8A-06',
        ),
        Student(
          studentId: 'student_07',
          name: 'Zain Ahmed',
          rollNumber: '07',
          classId: class8AId,
          parentIds: [parentMrAhmedId],
          linkCode: 'ARQ-8A-07',
        ),
        Student(
          studentId: 'student_08',
          name: 'Maryam Ali',
          rollNumber: '08',
          classId: class8AId,
          parentIds: [],
          linkCode: 'ARQ-8A-08',
        ),
        Student(
          studentId: 'student_09',
          name: 'Abdullah Khan',
          rollNumber: '09',
          classId: class8AId,
          parentIds: [],
          linkCode: 'ARQ-8A-09',
        ),
        Student(
          studentId: 'student_10',
          name: 'Hira Noor',
          rollNumber: '10',
          classId: class8AId,
          parentIds: [],
          linkCode: 'ARQ-8A-10',
        ),
      ];

  // Demo Parents
  static List<ParentProfile> get parents => [
        ParentProfile(
          parentId: parentProfileTariqId,
          userId: parentTariqKhanId,
          studentIds: ['student_01', 'student_03'], // Ali Khan & Usman Khan
        ),
        ParentProfile(
          parentId: parentProfileAhmedId,
          userId: parentMrAhmedId,
          studentIds: ['student_02', 'student_04', 'student_07'], // Sana, Ayesha, Zain
        ),
      ];

  // Demo Settings
  static SchoolSettings get settings => SchoolSettings(
        schoolId: schoolId,
        attendanceCutoffTime: '09:30',
        diaryPublishTime: '14:00',
        minimumAttendancePercentage: 75.0,
      );

  // Demo Holidays
  static List<SchoolHoliday> getHolidays() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return [
      SchoolHoliday(
        holidayId: 'hol_01',
        date: formatter.format(now.subtract(const Duration(days: 3))),
        title: 'Sunday Holiday',
        schoolId: schoolId,
      ),
      SchoolHoliday(
        holidayId: 'hol_02',
        date: formatter.format(now.subtract(const Duration(days: 10))),
        title: 'Sunday Holiday',
        schoolId: schoolId,
      ),
      SchoolHoliday(
        holidayId: 'hol_03',
        date: formatter.format(now.add(const Duration(days: 12))),
        title: 'Iqbal Day Commemoration',
        schoolId: schoolId,
      ),
    ];
  }

  // Pre-seed Historical Attendance (for past 5 school days)
  static Map<String, dynamic> generateInitialAttendance() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final sessions = <AttendanceSession>[];
    final records = <AttendanceRecord>[];

    // Days -5 to -1
    for (int dayOffset = 5; dayOffset >= 1; dayOffset--) {
      final date = now.subtract(Duration(days: dayOffset));
      if (date.weekday == DateTime.sunday) continue; // skip Sunday

      final dateStr = formatter.format(date);
      final sessionId = 'att_${class8AId}_$dateStr';

      sessions.add(AttendanceSession(
        attendanceId: sessionId,
        date: dateStr,
        classId: class8AId,
        submitted: true,
        submittedBy: teacherSirAhmedId,
        submittedAt: date.add(const Duration(hours: 9, minutes: 15)),
      ));

      // Records for each student
      for (final student in students) {
        String status = 'present';
        // Give Ali Khan 1 late and 1 absent in the past to demonstrate history
        if (student.studentId == 'student_01' && dayOffset == 2) {
          status = 'late';
        } else if (student.studentId == 'student_01' && dayOffset == 4) {
          status = 'absent';
        } else if (student.studentId == 'student_02' && dayOffset == 3) {
          status = 'leave';
        }

        records.add(AttendanceRecord(
          recordId: 'rec_${sessionId}_${student.studentId}',
          attendanceId: sessionId,
          studentId: student.studentId,
          status: status,
          updatedAt: date.add(const Duration(hours: 9, minutes: 15)),
          updatedBy: teacherSirAhmedId,
        ));
      }
    }

    return {'sessions': sessions, 'records': records};
  }

  // Pre-seed Historical Diaries
  static Map<String, dynamic> generateInitialDiaries() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final diaries = <ClassDiary>[];
    final entries = <DiaryEntry>[];

    // Yesterday diary (completed and published)
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = formatter.format(yesterday);
    final yesterdayDiaryId = 'diary_${class8AId}_$yesterdayStr';

    diaries.add(ClassDiary(
      diaryId: yesterdayDiaryId,
      date: yesterdayStr,
      classId: class8AId,
      published: true,
      publishedAt: yesterday.add(const Duration(hours: 13, minutes: 45)),
      createdBy: teacherSirAhmedId,
    ));

    entries.addAll([
      DiaryEntry(
        entryId: 'ent_${yesterdayDiaryId}_math',
        diaryId: yesterdayDiaryId,
        subjectId: 'subj_math_8a',
        teacherId: teacherSirAhmedId,
        classwork: 'Chapter 4 Algebraic Expressions, Exercise 4.1 Q1-Q3 solved in class.',
        homework: 'Complete Exercise 4.1 Q4 & Q5 on neat notebook.',
        testInfo: 'Short diagnostic quiz this Friday.',
        instructions: 'Bring geometry compass & sharp pencil.',
        status: 'completed',
        createdAt: yesterday.add(const Duration(hours: 10, minutes: 30)),
      ),
      DiaryEntry(
        entryId: 'ent_${yesterdayDiaryId}_sci',
        diaryId: yesterdayDiaryId,
        subjectId: 'subj_sci_8a',
        teacherId: teacherSirAhmedId,
        classwork: 'Photosynthesis process and diagram explanation.',
        homework: 'Read page 52 and draw the chloroplast diagram.',
        testInfo: 'Oral test on Thursday.',
        instructions: 'Prepare definition of chlorophyll.',
        status: 'completed',
        createdAt: yesterday.add(const Duration(hours: 11, minutes: 15)),
      ),
      DiaryEntry(
        entryId: 'ent_${yesterdayDiaryId}_eng',
        diaryId: yesterdayDiaryId,
        subjectId: 'subj_eng_8a',
        teacherId: teacherMissSanaId,
        classwork: 'Unit 3 Reading and Vocabulary words with Urdu meanings.',
        homework: 'Make sentences of 5 vocabulary words in grammar book.',
        testInfo: 'Spelling test tomorrow morning.',
        instructions: 'Revise idioms list #2.',
        status: 'completed',
        createdAt: yesterday.add(const Duration(hours: 12, minutes: 0)),
      ),
      DiaryEntry(
        entryId: 'ent_${yesterdayDiaryId}_urdu',
        diaryId: yesterdayDiaryId,
        subjectId: 'subj_urdu_8a',
        teacherId: teacherMissSanaId,
        classwork: 'Sabaq: Hamd o Naat ki tashreeh.',
        homework: 'Ashar ki tashreeh copy par mukammal karein.',
        testInfo: 'Qawaid test on Monday.',
        instructions: 'Khush-khati ka khayal rakhein.',
        status: 'completed',
        createdAt: yesterday.add(const Duration(hours: 12, minutes: 30)),
      ),
      DiaryEntry(
        entryId: 'ent_${yesterdayDiaryId}_isl',
        diaryId: yesterdayDiaryId,
        subjectId: 'subj_isl_8a',
        teacherId: teacherSirAliId,
        classwork: 'Surah Al-Hujurat Ayat 10-12 translation.',
        homework: 'Hifz of Ayat 10 with meaning.',
        testInfo: 'Nazira test in next period.',
        instructions: 'Follow tajweed rules strictly.',
        status: 'completed',
        createdAt: yesterday.add(const Duration(hours: 13, minutes: 0)),
      ),
      DiaryEntry(
        entryId: 'ent_${yesterdayDiaryId}_comp',
        diaryId: yesterdayDiaryId,
        subjectId: 'subj_comp_8a',
        teacherId: teacherSirAliId,
        classwork: 'Introduction to Python variables and data types.',
        homework: 'Write pseudo-code for adding two numbers.',
        testInfo: 'Lab practical test next Tuesday.',
        instructions: 'Bring lab manual to school.',
        status: 'completed',
        createdAt: yesterday.add(const Duration(hours: 13, minutes: 20)),
      ),
    ]);

    return {'diaries': diaries, 'entries': entries};
  }

  // Pre-seed Demo Marks
  static List<StudentMark> get marks {
    final now = DateTime.now();
    return [
      StudentMark(
        markId: 'mark_01',
        studentId: 'student_01', // Ali Khan
        classId: class8AId,
        subjectId: 'subj_math_8a',
        examType: 'Weekly Test',
        obtainedMarks: 18.0,
        totalMarks: 20.0,
        feedback: 'Good progress. Needs more practice with fractions and algebraic identities.',
        createdBy: teacherSirAhmedId,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      StudentMark(
        markId: 'mark_02',
        studentId: 'student_01', // Ali Khan
        classId: class8AId,
        subjectId: 'subj_sci_8a',
        examType: 'Weekly Test',
        obtainedMarks: 23.5,
        totalMarks: 25.0,
        feedback: 'Excellent conceptual grasp of Photosynthesis and respiration.',
        createdBy: teacherSirAhmedId,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      StudentMark(
        markId: 'mark_03',
        studentId: 'student_01', // Ali Khan
        classId: class8AId,
        subjectId: 'subj_eng_8a',
        examType: 'Monthly Test',
        obtainedMarks: 44.0,
        totalMarks: 50.0,
        feedback: 'Good essay structure, but needs improvement in punctuation.',
        createdBy: teacherMissSanaId,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      StudentMark(
        markId: 'mark_04',
        studentId: 'student_03', // Usman Khan (Ali Khan's brother)
        classId: class8AId,
        subjectId: 'subj_math_8a',
        examType: 'Weekly Test',
        obtainedMarks: 19.0,
        totalMarks: 20.0,
        feedback: 'Outstanding mathematical problem-solving skills!',
        createdBy: teacherSirAhmedId,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      StudentMark(
        markId: 'mark_05',
        studentId: 'student_02', // Sana Ahmed
        classId: class8AId,
        subjectId: 'subj_math_8a',
        examType: 'Weekly Test',
        obtainedMarks: 17.0,
        totalMarks: 20.0,
        feedback: 'Well attempted. Revise linear equations.',
        createdBy: teacherSirAhmedId,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  // Pre-seed Notifications
  static List<AppNotification> get notifications {
    final now = DateTime.now();
    return [
      AppNotification(
        notificationId: 'notif_01',
        userId: parentTariqKhanId,
        studentId: 'student_01',
        title: 'Today\'s Diary',
        body: 'Class 8-A today\'s diary is ready for review.',
        type: 'diary',
        read: false,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        notificationId: 'notif_02',
        userId: parentTariqKhanId,
        studentId: 'student_01',
        title: 'Weekly Test Result',
        body: 'Ali Khan\'s Mathematics test report is available: 18/20 (90%).',
        type: 'marks',
        read: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      AppNotification(
        notificationId: 'notif_03',
        userId: parentTariqKhanId,
        studentId: 'student_01',
        title: 'Attendance Alert',
        body: 'Ali Khan was marked Late to school on earlier date.',
        type: 'attendance',
        read: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
