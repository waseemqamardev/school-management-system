class AppUser {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role; // 'admin', 'teacher', 'parent'
  final String schoolId;
  final bool active;

  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.schoolId,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'schoolId': schoolId,
      'active': active,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      userId: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'parent',
      schoolId: map['schoolId'] ?? '',
      active: map['active'] ?? true,
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? schoolId,
    bool? active,
  }) {
    return AppUser(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      active: active ?? this.active,
    );
  }
}
