class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String teacherId;
  final String type; // 'homework', 'test'

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.teacherId,
    required this.type,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
      id: json['_id'].toString(),
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      classId: json['classId'] ?? '',
      teacherId: json['teacherId'],
      type: json['type'] ?? 'homework',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'teacherId': teacherId,
      'type': type,
    };
  }
}
