class SchoolSettings {
  final String schoolId;
  final String attendanceCutoffTime; // e.g. "09:30"
  final String diaryPublishTime; // e.g. "14:00"
  final double minimumAttendancePercentage; // e.g. 75.0

  SchoolSettings({
    required this.schoolId,
    this.attendanceCutoffTime = '09:30',
    this.diaryPublishTime = '14:00',
    this.minimumAttendancePercentage = 75.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'attendanceCutoffTime': attendanceCutoffTime,
      'diaryPublishTime': diaryPublishTime,
      'minimumAttendancePercentage': minimumAttendancePercentage,
    };
  }

  factory SchoolSettings.fromMap(Map<String, dynamic> map, String id) {
    return SchoolSettings(
      schoolId: id,
      attendanceCutoffTime: map['attendanceCutoffTime'] ?? '09:30',
      diaryPublishTime: map['diaryPublishTime'] ?? '14:00',
      minimumAttendancePercentage:
          (map['minimumAttendancePercentage'] as num?)?.toDouble() ?? 75.0,
    );
  }

  SchoolSettings copyWith({
    String? attendanceCutoffTime,
    String? diaryPublishTime,
    double? minimumAttendancePercentage,
  }) {
    return SchoolSettings(
      schoolId: schoolId,
      attendanceCutoffTime: attendanceCutoffTime ?? this.attendanceCutoffTime,
      diaryPublishTime: diaryPublishTime ?? this.diaryPublishTime,
      minimumAttendancePercentage:
          minimumAttendancePercentage ?? this.minimumAttendancePercentage,
    );
  }
}
