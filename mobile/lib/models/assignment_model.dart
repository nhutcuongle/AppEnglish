class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String teacherId;
  final String classId;
  final String type; // 'homework', 'test'
  final String? unit;
  final int? timeLimit;
  final int? totalQuestions;
  final String? submissionFormat;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.teacherId,
    this.classId = '',
    required this.type,
    this.unit,
    this.timeLimit,
    this.totalQuestions,
    this.submissionFormat,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : DateTime.now(),
      classId: json['classId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      type: json['type'] ?? 'homework',
      unit: json['unit'],
      timeLimit: json['timeLimit'],
      totalQuestions: json['totalQuestions'],
      submissionFormat: json['submissionFormat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'teacherId': teacherId,
      'classId': classId,
      'type': type,
      'unit': unit,
      'timeLimit': timeLimit,
      'totalQuestions': totalQuestions,
      'submissionFormat': submissionFormat,
    };
  }
}
