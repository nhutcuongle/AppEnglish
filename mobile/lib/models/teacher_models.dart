class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime deadline; 
  final String teacherId;
  final String? classId;
  final String type; // "15m" hoặc "45m"
  final String? unit; 
  final int? timeLimit; 

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.deadline,
    required this.teacherId,
    this.classId,
    required this.type,
    this.unit,
    this.timeLimit,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    String? cid;
    String? cname;
    if (json['class'] is Map) {
      cid = json['class']['_id']?.toString();
      cname = json['class']['name']?.toString();
    } else {
      cid = json['class']?.toString();
    }

    return Assignment(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: cname != null ? 'Lớp: $cname' : (json['description'] ?? ''),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
      deadline: json['endTime'] != null ? DateTime.parse(json['endTime']) : DateTime.now(),
      teacherId: (json['teacher'] is Map) ? json['teacher']['_id']?.toString() ?? '' : (json['teacher']?.toString() ?? ''),
      classId: cid,
      type: json['type'] ?? '15m',
      unit: json['type'] == '15m' ? '15 Phút' : '45 Phút',
      timeLimit: json['type'] == '15m' ? 15 : 45,
    );
  }
}

class Student {
  final String id;
  final String name;
  final String? classId;
  final double progress;
  final double score;

  Student({
    required this.id,
    required this.name,
    this.classId,
    required this.progress,
    required this.score,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id']?.toString() ?? '',
      name: json['fullName'] ?? json['username'] ?? 'Không tên',
      classId: json['classId'],
      progress: (json['progress'] ?? 0.0).toDouble(),
      score: (json['score'] ?? 0.0).toDouble(),
    );
  }
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class LessonPlan {
  final String id;
  final String title;
  final String unit;
  final String topic;
  final String objectives;
  final String content;
  final List<String> resources;
  final DateTime createdAt;

  LessonPlan({
    required this.id,
    required this.title,
    required this.unit,
    required this.topic,
    required this.objectives,
    required this.content,
    required this.resources,
    required this.createdAt,
  });

  factory LessonPlan.fromJson(Map<String, dynamic> json) {
    return LessonPlan(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      unit: json['unit'] ?? 'Unit ?',
      topic: json['topic'] ?? 'Chủ đề',
      objectives: json['objectives'] ?? '',
      content: json['content'] ?? '',
      resources: json['resources'] != null ? List<String>.from(json['resources']) : [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class Submission {
  final String id;
  final String examId;
  final String studentId;
  final double? score;
  final String? comment;
  final DateTime submittedAt;

  Submission({
    required this.id,
    required this.examId,
    required this.studentId,
    this.score,
    this.comment,
    required this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['_id']?.toString() ?? '',
      examId: json['exam']?.toString() ?? '',
      studentId: json['user']?.toString() ?? '',
      score: json['totalScore'] != null ? (json['totalScore'] as num).toDouble() : null,
      comment: json['comment'],
      submittedAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
