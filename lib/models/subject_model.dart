class Subject {
  final String subjectId;
  final String name;
  final String classId;
  final String teacherId;

  Subject({
    required this.subjectId,
    required this.name,
    required this.classId,
    required this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'name': name,
      'classId': classId,
      'teacherId': teacherId,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map, String id) {
    return Subject(
      subjectId: id,
      name: map['name'] ?? '',
      classId: map['classId'] ?? '',
      teacherId: map['teacherId'] ?? '',
    );
  }

  Subject copyWith({
    String? name,
    String? classId,
    String? teacherId,
  }) {
    return Subject(
      subjectId: subjectId,
      name: name ?? this.name,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}
