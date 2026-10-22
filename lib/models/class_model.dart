class SchoolClass {
  final String classId;
  final String schoolId;
  final String name;
  final String section;
  final String classTeacherId;

  SchoolClass({
    required this.classId,
    required this.schoolId,
    required this.name,
    required this.section,
    required this.classTeacherId,
  });

  String get displayName => '$name-$section';

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'schoolId': schoolId,
      'name': name,
      'section': section,
      'classTeacherId': classTeacherId,
    };
  }

  factory SchoolClass.fromMap(Map<String, dynamic> map, String id) {
    return SchoolClass(
      classId: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      section: map['section'] ?? '',
      classTeacherId: map['classTeacherId'] ?? '',
    );
  }

  SchoolClass copyWith({
    String? name,
    String? section,
    String? classTeacherId,
  }) {
    return SchoolClass(
      classId: classId,
      schoolId: schoolId,
      name: name ?? this.name,
      section: section ?? this.section,
      classTeacherId: classTeacherId ?? this.classTeacherId,
    );
  }
}
