import 'package:mongo_dart/mongo_dart.dart';

class Assignment {
  final ObjectId id;
  final String title;
  final String description;
  final DateTime deadline;
  final String teacherId;
  final String type; // 'homework' or 'test'
  final String? unit;
  final int? timeLimit; // Dành cho Bài kiểm tra
  final int? totalQuestions; // Dành cho Bài kiểm tra
  final String? submissionFormat; // Dành cho Bài tập

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.teacherId,
    required this.type,
    this.unit,
    this.timeLimit,
    this.totalQuestions,
    this.submissionFormat,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['_id'] as ObjectId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: json['deadline'] is String 
          ? DateTime.parse(json['deadline']) 
          : (json['deadline'] ?? DateTime.now()),
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
      '_id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'teacherId': teacherId,
      'type': type,
      'unit': unit,
      'timeLimit': timeLimit,
      'totalQuestions': totalQuestions,
      'submissionFormat': submissionFormat,
    };
  }
}

class Submission {
  final ObjectId id;
  final ObjectId assignmentId;
  final ObjectId studentId;
  final String content;
  final double? score;
  final String? comment;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.content,
    this.score,
    this.comment,
    required this.submittedAt,
    this.gradedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['_id'] as ObjectId,
      assignmentId: json['assignmentId'] as ObjectId,
      studentId: json['studentId'] as ObjectId,
      content: json['content'] ?? '',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      comment: json['comment'],
      submittedAt: json['submittedAt'] is String 
          ? DateTime.parse(json['submittedAt']) 
          : (json['submittedAt'] ?? DateTime.now()),
      gradedAt: json['gradedAt'] != null ? DateTime.parse(json['gradedAt']) : null,
    );
  }
}

class Student {
  final ObjectId id;
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
      id: json['_id'] as ObjectId,
      name: json['name'] ?? 'Không tên',
      classId: json['classId'],
      progress: (json['progress'] ?? 0.0).toDouble(),
      score: (json['score'] ?? 0.0).toDouble(),
    );
  }
}

class Announcement {
  final ObjectId id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String teacherId;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.teacherId,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'] as ObjectId,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] is String 
          ? DateTime.parse(json['createdAt']) 
          : (json['createdAt'] ?? DateTime.now()),
      teacherId: json['teacherId'] ?? '',
    );
  }
}

class LessonPlan {
  final ObjectId id;
  final String title;
  final String unit;
  final String topic;
  final String objectives;
  final List<String> resources; // Links tài liệu
  final String content;
  final DateTime createdAt;
  final String teacherId;

  LessonPlan({
    required this.id,
    required this.title,
    required this.unit,
    required this.topic,
    required this.objectives,
    required this.resources,
    required this.content,
    required this.createdAt,
    required this.teacherId,
  });

  factory LessonPlan.fromJson(Map<String, dynamic> json) {
    return LessonPlan(
      id: json['_id'] as ObjectId,
      title: json['title'] ?? '',
      unit: json['unit'] ?? '',
      topic: json['topic'] ?? '',
      objectives: json['objectives'] ?? '',
      resources: List<String>.from(json['resources'] ?? []),
      content: json['content'] ?? '',
      createdAt: json['createdAt'] is String 
          ? DateTime.parse(json['createdAt']) 
          : (json['createdAt'] ?? DateTime.now()),
      teacherId: json['teacherId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'unit': unit,
      'topic': topic,
      'objectives': objectives,
      'resources': resources,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'teacherId': teacherId,
    };
  }
}
