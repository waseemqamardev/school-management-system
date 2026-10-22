class DiaryEntry {
  final String entryId;
  final String diaryId;
  final String subjectId;
  final String teacherId;
  final String homework;
  final String classwork;
  final String testInfo;
  final String instructions;
  final String status; // 'draft', 'completed'
  final DateTime createdAt;

  DiaryEntry({
    required this.entryId,
    required this.diaryId,
    required this.subjectId,
    required this.teacherId,
    this.homework = '',
    this.classwork = '',
    this.testInfo = '',
    this.instructions = '',
    this.status = 'draft',
    required this.createdAt,
  });

  bool get isCompleted => status == 'completed';

  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'diaryId': diaryId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'homework': homework,
      'classwork': classwork,
      'testInfo': testInfo,
      'instructions': instructions,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map, String id) {
    return DiaryEntry(
      entryId: id,
      diaryId: map['diaryId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      homework: map['homework'] ?? '',
      classwork: map['classwork'] ?? '',
      testInfo: map['testInfo'] ?? '',
      instructions: map['instructions'] ?? '',
      status: map['status'] ?? 'draft',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  DiaryEntry copyWith({
    String? homework,
    String? classwork,
    String? testInfo,
    String? instructions,
    String? status,
  }) {
    return DiaryEntry(
      entryId: entryId,
      diaryId: diaryId,
      subjectId: subjectId,
      teacherId: teacherId,
      homework: homework ?? this.homework,
      classwork: classwork ?? this.classwork,
      testInfo: testInfo ?? this.testInfo,
      instructions: instructions ?? this.instructions,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
