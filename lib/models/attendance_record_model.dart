class AttendanceRecord {
  final String recordId;
  final String attendanceId;
  final String studentId;
  final String status; // 'present', 'absent', 'late', 'leave'
  final DateTime updatedAt;
  final String updatedBy;

  AttendanceRecord({
    required this.recordId,
    required this.attendanceId,
    required this.studentId,
    required this.status,
    required this.updatedAt,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'attendanceId': attendanceId,
      'studentId': studentId,
      'status': status,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceRecord(
      recordId: id,
      attendanceId: map['attendanceId'] ?? '',
      studentId: map['studentId'] ?? '',
      status: map['status'] ?? 'present',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedBy: map['updatedBy'] ?? '',
    );
  }

  AttendanceRecord copyWith({
    String? status,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return AttendanceRecord(
      recordId: recordId,
      attendanceId: attendanceId,
      studentId: studentId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
