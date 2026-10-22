class ParentProfile {
  final String parentId;
  final String userId;
  final List<String> studentIds;

  ParentProfile({
    required this.parentId,
    required this.userId,
    required this.studentIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'userId': userId,
      'studentIds': studentIds,
    };
  }

  factory ParentProfile.fromMap(Map<String, dynamic> map, String id) {
    return ParentProfile(
      parentId: id,
      userId: map['userId'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
    );
  }

  ParentProfile copyWith({
    String? userId,
    List<String>? studentIds,
  }) {
    return ParentProfile(
      parentId: parentId,
      userId: userId ?? this.userId,
      studentIds: studentIds ?? this.studentIds,
    );
  }
}
