class TeacherProfile {
  final String teacherId;
  final String userId;
  final List<String> assignedClassIds;
  final List<String> assignedSubjectIds;

  TeacherProfile({
    required this.teacherId,
    required this.userId,
    required this.assignedClassIds,
    required this.assignedSubjectIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'userId': userId,
      'assignedClassIds': assignedClassIds,
      'assignedSubjectIds': assignedSubjectIds,
    };
  }

  factory TeacherProfile.fromMap(Map<String, dynamic> map, String id) {
    return TeacherProfile(
      teacherId: id,
      userId: map['userId'] ?? '',
      assignedClassIds: List<String>.from(map['assignedClassIds'] ?? []),
      assignedSubjectIds: List<String>.from(map['assignedSubjectIds'] ?? []),
    );
  }

  TeacherProfile copyWith({
    String? userId,
    List<String>? assignedClassIds,
    List<String>? assignedSubjectIds,
  }) {
    return TeacherProfile(
      teacherId: teacherId,
      userId: userId ?? this.userId,
      assignedClassIds: assignedClassIds ?? this.assignedClassIds,
      assignedSubjectIds: assignedSubjectIds ?? this.assignedSubjectIds,
    );
  }
}
