class ClassDiary {
  final String diaryId;
  final String date; // YYYY-MM-DD
  final String classId;
  final bool published;
  final DateTime? publishedAt;
  final String createdBy;

  ClassDiary({
    required this.diaryId,
    required this.date,
    required this.classId,
    this.published = false,
    this.publishedAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'diaryId': diaryId,
      'date': date,
      'classId': classId,
      'published': published,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory ClassDiary.fromMap(Map<String, dynamic> map, String id) {
    return ClassDiary(
      diaryId: id,
      date: map['date'] ?? '',
      classId: map['classId'] ?? '',
      published: map['published'] ?? false,
      publishedAt: map['publishedAt'] != null
          ? DateTime.tryParse(map['publishedAt'])
          : null,
      createdBy: map['createdBy'] ?? '',
    );
  }

  ClassDiary copyWith({
    String? date,
    String? classId,
    bool? published,
    DateTime? publishedAt,
    String? createdBy,
  }) {
    return ClassDiary(
      diaryId: diaryId,
      date: date ?? this.date,
      classId: classId ?? this.classId,
      published: published ?? this.published,
      publishedAt: publishedAt ?? this.publishedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
