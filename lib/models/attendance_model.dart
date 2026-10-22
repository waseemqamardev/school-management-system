class AttendanceSession {
  final String attendanceId;
  final String date; // Format: YYYY-MM-DD
  final String classId;
  final bool submitted;
  final String? submittedBy;
  final DateTime? submittedAt;

  AttendanceSession({
    required this.attendanceId,
    required this.date,
    required this.classId,
    this.submitted = false,
    this.submittedBy,
    this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'date': date,
      'classId': classId,
      'submitted': submitted,
      'submittedBy': submittedBy,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  factory AttendanceSession.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceSession(
      attendanceId: id,
      date: map['date'] ?? '',
      classId: map['classId'] ?? '',
      submitted: map['submitted'] ?? false,
      submittedBy: map['submittedBy'],
      submittedAt: map['submittedAt'] != null
          ? DateTime.tryParse(map['submittedAt'])
          : null,
    );
  }

  AttendanceSession copyWith({
    String? date,
    String? classId,
    bool? submitted,
    String? submittedBy,
    DateTime? submittedAt,
  }) {
    return AttendanceSession(
      attendanceId: attendanceId,
      date: date ?? this.date,
      classId: classId ?? this.classId,
      submitted: submitted ?? this.submitted,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
