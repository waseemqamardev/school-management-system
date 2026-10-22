import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../models/student_model.dart';
import '../models/mark_model.dart';
import '../models/notification_model.dart';
import '../services/repository_manager.dart';

class MarksProvider extends ChangeNotifier {
  final RepositoryManager _repoManager;
  final _uuid = const Uuid();

  List<SchoolClass> _classes = [];
  SchoolClass? _selectedClass;
  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  List<Student> _students = [];
  Student? _selectedStudent;

  List<StudentMark> _classMarks = [];
  List<StudentMark> _studentMarks = [];
  bool _isLoading = false;
  String? _errorMessage;

  MarksProvider(this._repoManager);

  List<SchoolClass> get classes => _classes;
  SchoolClass? get selectedClass => _selectedClass;
  List<Subject> get subjects => _subjects;
  Subject? get selectedSubject => _selectedSubject;
  List<Student> get students => _students;
  Student? get selectedStudent => _selectedStudent;
  List<StudentMark> get classMarks => _classMarks;
  List<StudentMark> get studentMarks => _studentMarks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize(String? classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _classes = await _repoManager.repository.getClasses();
      if (_classes.isNotEmpty) {
        if (classId != null) {
          _selectedClass = _classes.firstWhere(
            (c) => c.classId == classId,
            orElse: () => _classes.first,
          );
        } else {
          _selectedClass ??= _classes.first;
        }
        await _loadClassData(_selectedClass!.classId);
      }
    } catch (e) {
      _errorMessage = 'Failed to load marks setup: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectClass(SchoolClass schoolClass) {
    _selectedClass = schoolClass;
    _loadClassData(schoolClass.classId);
  }

  void selectSubject(Subject subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void selectStudent(Student student) {
    _selectedStudent = student;
    loadMarksForStudent(student.studentId);
  }

  Future<void> _loadClassData(String classId) async {
    _subjects = await _repoManager.repository.getSubjectsByClass(classId);
    if (_subjects.isNotEmpty) {
      _selectedSubject ??= _subjects.first;
    }
    _students = await _repoManager.repository.getStudentsByClass(classId);
    if (_students.isNotEmpty) {
      _selectedStudent ??= _students.first;
    }
    _classMarks = await _repoManager.repository.getMarksForClass(classId);
    if (_selectedStudent != null) {
      await loadMarksForStudent(_selectedStudent!.studentId);
    }
    notifyListeners();
  }

  Future<void> loadMarksForStudent(String studentId) async {
    _studentMarks = await _repoManager.repository.getMarksForStudent(studentId);
    notifyListeners();
  }

  Future<bool> saveMark({
    required String studentId,
    required String classId,
    required String subjectId,
    required String examType,
    required double obtainedMarks,
    required double totalMarks,
    required String feedback,
    required String teacherUserId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final markId = _uuid.v4();
      final mark = StudentMark(
        markId: markId,
        studentId: studentId,
        classId: classId,
        subjectId: subjectId,
        examType: examType,
        obtainedMarks: obtainedMarks,
        totalMarks: totalMarks,
        feedback: feedback.trim(),
        createdBy: teacherUserId,
        createdAt: DateTime.now(),
      );

      await _repoManager.repository.saveMark(mark);

      // Create parent notification:
      // "Ali Khan's Mathematics test report is available."
      final student = await _repoManager.repository.getStudentById(studentId);
      final subject = _subjects.firstWhere((s) => s.subjectId == subjectId, orElse: () => Subject(subjectId: '', name: 'Subject', classId: '', teacherId: ''));

      if (student != null) {
        for (final pId in student.parentIds) {
          await _repoManager.repository.createNotification(
            AppNotification(
              notificationId: _uuid.v4(),
              userId: pId,
              studentId: studentId,
              title: 'New Test Result',
              body: "${student.name}'s ${subject.name} test report is available.",
              type: 'marks',
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      await _loadClassData(classId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save marks: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  double calculateAveragePercentage(List<StudentMark> marks) {
    if (marks.isEmpty) return 0.0;
    double totalObtained = 0.0;
    double totalMax = 0.0;
    for (final m in marks) {
      totalObtained += m.obtainedMarks;
      totalMax += m.totalMarks;
    }
    return totalMax > 0 ? (totalObtained / totalMax) * 100 : 0.0;
  }
}
