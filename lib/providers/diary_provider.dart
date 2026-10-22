import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../models/diary_model.dart';
import '../models/diary_entry_model.dart';
import '../models/notification_model.dart';
import '../models/school_settings_model.dart';
import '../services/repository_manager.dart';

class DiaryProvider extends ChangeNotifier {
  final RepositoryManager _repoManager;
  final _uuid = const Uuid();

  List<SchoolClass> _classes = [];
  SchoolClass? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  ClassDiary? _currentDiary;
  final Map<String, DiaryEntry> _entriesBySubjectId = {};
  bool _isLoading = false;
  String? _errorMessage;
  SchoolSettings? _settings;

  DiaryProvider(this._repoManager);

  List<SchoolClass> get classes => _classes;
  SchoolClass? get selectedClass => _selectedClass;
  DateTime get selectedDate => _selectedDate;
  String get selectedDateFormatted => DateFormat('yyyy-MM-dd').format(_selectedDate);
  List<Subject> get subjects => _subjects;
  Subject? get selectedSubject => _selectedSubject;
  ClassDiary? get currentDiary => _currentDiary;
  Map<String, DiaryEntry> get entriesBySubjectId => _entriesBySubjectId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isPublished => _currentDiary?.published ?? false;

  int get totalSubjects => _subjects.length;
  int get completedSubjectsCount => _subjects
      .where((s) => _entriesBySubjectId[s.subjectId]?.status == 'completed')
      .length;
  int get pendingSubjectsCount => totalSubjects - completedSubjectsCount;

  bool get isPastPublishTime {
    if (_settings == null) return false;
    final parts = _settings!.diaryPublishTime.split(':');
    if (parts.length != 2) return false;
    final pubHour = int.tryParse(parts[0]) ?? 14;
    final pubMin = int.tryParse(parts[1]) ?? 0;

    final now = DateTime.now();
    if (DateFormat('yyyy-MM-dd').format(now) != selectedDateFormatted) return false;

    final publishTime = DateTime(now.year, now.month, now.day, pubHour, pubMin);
    return now.isAfter(publishTime) && !isPublished;
  }

  Future<void> initialize(String? classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _classes = await _repoManager.repository.getClasses();
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

      await loadDiaryForDate(_selectedDate);
    } catch (e) {
      _errorMessage = 'Failed to load diary system: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectClass(SchoolClass schoolClass) {
    _selectedClass = schoolClass;
    loadDiaryForDate(_selectedDate);
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    loadDiaryForDate(date);
  }

  void selectSubject(Subject subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  Future<void> loadDiaryForDate(DateTime date) async {
    if (_selectedClass == null) return;
    _isLoading = true;
    _selectedDate = date;
    _entriesBySubjectId.clear();
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      _subjects = await _repoManager.repository.getSubjectsByClass(_selectedClass!.classId);
      if (_subjects.isNotEmpty) {
        _selectedSubject ??= _subjects.first;
      }

      _currentDiary = await _repoManager.repository.getClassDiary(_selectedClass!.classId, dateStr);

      if (_currentDiary != null) {
        final entries = await _repoManager.repository.getDiaryEntries(_currentDiary!.diaryId);
        for (final entry in entries) {
          _entriesBySubjectId[entry.subjectId] = entry;
        }
      }
    } catch (e) {
      _errorMessage = 'Error loading diary: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DiaryEntry? getEntryForSubject(String subjectId) {
    return _entriesBySubjectId[subjectId];
  }

  Future<bool> saveSubjectEntry({
    required String subjectId,
    required String teacherId,
    required String homework,
    required String classwork,
    required String testInfo,
    required String instructions,
    required bool isDone, // true = completed, false = draft
  }) async {
    if (_selectedClass == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = selectedDateFormatted;
      var diary = _currentDiary;

      if (diary == null) {
        diary = ClassDiary(
          diaryId: 'diary_${_selectedClass!.classId}_$dateStr',
          date: dateStr,
          classId: _selectedClass!.classId,
          published: false,
          createdBy: teacherId,
        );
        await _repoManager.repository.saveClassDiary(diary);
        _currentDiary = diary;
      }

      final existingEntry = _entriesBySubjectId[subjectId];
      final entryId = existingEntry?.entryId ?? 'ent_${diary.diaryId}_$subjectId';

      final entry = DiaryEntry(
        entryId: entryId,
        diaryId: diary.diaryId,
        subjectId: subjectId,
        teacherId: teacherId,
        homework: homework.trim(),
        classwork: classwork.trim(),
        testInfo: testInfo.trim(),
        instructions: instructions.trim(),
        status: isDone ? 'completed' : 'draft',
        createdAt: DateTime.now(),
      );

      await _repoManager.repository.saveDiaryEntry(entry);
      _entriesBySubjectId[subjectId] = entry;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save subject entry: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> publishClassDiary(String teacherUserId) async {
    if (_selectedClass == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = selectedDateFormatted;
      var diary = _currentDiary;

      if (diary == null) {
        diary = ClassDiary(
          diaryId: 'diary_${_selectedClass!.classId}_$dateStr',
          date: dateStr,
          classId: _selectedClass!.classId,
          published: true,
          publishedAt: DateTime.now(),
          createdBy: teacherUserId,
        );
      } else {
        diary = diary.copyWith(
          published: true,
          publishedAt: DateTime.now(),
        );
      }

      await _repoManager.repository.saveClassDiary(diary);
      _currentDiary = diary;

      // Find all parents of this class to send ONE notification:
      // "Class 8-A today's diary is ready."
      final students = await _repoManager.repository.getStudentsByClass(_selectedClass!.classId);
      final parentUserIds = <String>{};
      for (final s in students) {
        parentUserIds.addAll(s.parentIds);
      }

      for (final pId in parentUserIds) {
        await _repoManager.repository.createNotification(
          AppNotification(
            notificationId: _uuid.v4(),
            userId: pId,
            title: "Today's Diary",
            body: "${_selectedClass!.displayName} today's diary is ready.",
            type: 'diary',
            createdAt: DateTime.now(),
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to publish diary: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<ClassDiary>> getHistory() async {
    if (_selectedClass == null) return [];
    return _repoManager.repository.getDiaryHistory(_selectedClass!.classId);
  }
}
