class School {
  final String schoolId;
  final String name;
  final String address;

  School({
    required this.schoolId,
    required this.name,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'address': address,
    };
  }

  factory School.fromMap(Map<String, dynamic> map, String id) {
    return School(
      schoolId: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
