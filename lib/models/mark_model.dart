class StudentMark {
  final String markId;
  final String studentId;
  final String classId;
  final String subjectId;
  final String examType; // Weekly Test, Monthly Test, Exam
  final double obtainedMarks;
  final double totalMarks;
  final String feedback;
  final String createdBy;
  final DateTime createdAt;

  StudentMark({
    required this.markId,
    required this.studentId,
    required this.classId,
    required this.subjectId,
    required this.examType,
    required this.obtainedMarks,
    required this.totalMarks,
    this.feedback = '',
    required this.createdBy,
    required this.createdAt,
  });

  double get percentage => totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'markId': markId,
      'studentId': studentId,
      'classId': classId,
      'subjectId': subjectId,
      'examType': examType,
      'obtainedMarks': obtainedMarks,
      'totalMarks': totalMarks,
      'feedback': feedback,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudentMark.fromMap(Map<String, dynamic> map, String id) {
    return StudentMark(
      markId: id,
      studentId: map['studentId'] ?? '',
      classId: map['classId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      examType: map['examType'] ?? 'Weekly Test',
      obtainedMarks: (map['obtainedMarks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (map['totalMarks'] as num?)?.toDouble() ?? 100.0,
      feedback: map['feedback'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  StudentMark copyWith({
    String? examType,
    double? obtainedMarks,
    double? totalMarks,
    String? feedback,
  }) {
    return StudentMark(
      markId: markId,
      studentId: studentId,
      classId: classId,
      subjectId: subjectId,
      examType: examType ?? this.examType,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      feedback: feedback ?? this.feedback,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
