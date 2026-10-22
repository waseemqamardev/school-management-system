class Student {
  final String studentId;
  final String name;
  final String rollNumber;
  final String classId;
  final List<String> parentIds;
  final bool active;
  final String? photoUrl;
  final String linkCode;

  Student({
    required this.studentId,
    required this.name,
    required this.rollNumber,
    required this.classId,
    required this.parentIds,
    this.active = true,
    this.photoUrl,
    String? linkCode,
  }) : linkCode = (linkCode != null && linkCode.trim().isNotEmpty)
            ? linkCode.trim().toUpperCase()
            : studentId.toUpperCase();

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'rollNumber': rollNumber,
      'classId': classId,
      'parentIds': parentIds,
      'active': active,
      'photoUrl': photoUrl,
      'linkCode': linkCode,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      studentId: id,
      name: map['name'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      classId: map['classId'] ?? '',
      parentIds: List<String>.from(map['parentIds'] ?? []),
      active: map['active'] ?? true,
      photoUrl: map['photoUrl'],
      linkCode: map['linkCode'] ?? map['link_code'] ?? id.toUpperCase(),
    );
  }

  Student copyWith({
    String? name,
    String? rollNumber,
    String? classId,
    List<String>? parentIds,
    bool? active,
    String? photoUrl,
    String? linkCode,
  }) {
    return Student(
      studentId: studentId,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      classId: classId ?? this.classId,
      parentIds: parentIds ?? this.parentIds,
      active: active ?? this.active,
      photoUrl: photoUrl ?? this.photoUrl,
      linkCode: linkCode ?? this.linkCode,
    );
  }
}
