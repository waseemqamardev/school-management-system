class SchoolHoliday {
  final String holidayId;
  final String date; // YYYY-MM-DD
  final String title;
  final String schoolId;

  SchoolHoliday({
    required this.holidayId,
    required this.date,
    required this.title,
    required this.schoolId,
  });

  Map<String, dynamic> toMap() {
    return {
      'holidayId': holidayId,
      'date': date,
      'title': title,
      'schoolId': schoolId,
    };
  }

  factory SchoolHoliday.fromMap(Map<String, dynamic> map, String id) {
    return SchoolHoliday(
      holidayId: id,
      date: map['date'] ?? '',
      title: map['title'] ?? '',
      schoolId: map['schoolId'] ?? '',
    );
  }
}
