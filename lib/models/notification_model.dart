class AppNotification {
  final String notificationId;
  final String userId;
  final String? studentId;
  final String title;
  final String body;
  final String type; // 'attendance', 'attendance_correction', 'diary', 'marks', 'warning', 'system'
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.notificationId,
    required this.userId,
    this.studentId,
    required this.title,
    required this.body,
    required this.type,
    this.read = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'studentId': studentId,
      'title': title,
      'body': body,
      'type': type,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      notificationId: id,
      userId: map['userId'] ?? '',
      studentId: map['studentId'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'system',
      read: map['read'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AppNotification copyWith({
    bool? read,
  }) {
    return AppNotification(
      notificationId: notificationId,
      userId: userId,
      studentId: studentId,
      title: title,
      body: body,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
