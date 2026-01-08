class User {
  final String id;
  final String name;
  final String role; // 'school', 'teacher', 'student'
  final String? classId;

  User({required this.id, required this.name, required this.role, this.classId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'].toString(),
      name: json['name'],
      role: json['role'],
      classId: json['classId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'classId': classId,
    };
  }
}
