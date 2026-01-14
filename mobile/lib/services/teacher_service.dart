import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/api_service.dart';

class TeacherService {
  // --- Quản lý Học sinh ---

  static Future<List<Student>> searchStudents(String query) async {
    final studentsRaw = await ApiService.getStudents();
    final students = studentsRaw.map((e) => Student.fromJson(e)).toList();
    
    if (query.isEmpty) return students;
    return students.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  static Future<List<Student>> getTopPerformer() async {
    final studentsRaw = await ApiService.getStudents();
    final students = studentsRaw.map((e) => Student.fromJson(e)).toList();
    students.sort((a, b) => b.score.compareTo(a.score));
    return students.take(5).toList();
  }

  // --- Quản lý Bài kiểm tra ---

  static Future<List<Assignment>> getFilteredAssignments(String? type, {String query = ''}) async {
    // Lấy dữ liệu bài kiểm tra (Exams) từ backend
    final List<dynamic> data = await ApiService.getTeacherExams();

    // Sử dụng factory Assignment.fromJson để tự động map dữ liệu
    List<Assignment> allExams = data.map((e) => Assignment.fromJson(e)).toList();

    // Lọc theo từ khóa tìm kiếm
    if (query.isNotEmpty) {
      allExams = allExams.where((a) => a.title.toLowerCase().contains(query.toLowerCase())).toList();
    }

    return allExams;
  }

  // --- Thống kê ---

  static Map<String, dynamic> calculateClassOverview(List<Student> students) {
    if (students.isEmpty) return {'avgScore': 0.0, 'completionRate': 0.0};
    
    double totalScore = 0;
    double totalProgress = 0;
    
    for (var s in students) {
      totalScore += s.score;
      totalProgress += s.progress;
    }
    
    return {
      'avgScore': (totalScore / students.length).toStringAsFixed(1),
      'completionRate': (totalProgress / students.length * 100).toInt(),
    };
  }

  static Future<Map<String, double>> getScoreDistribution() async {
    final studentsRaw = await ApiService.getStudents();
    final students = studentsRaw.map((e) => Student.fromJson(e)).toList();

    if (students.isEmpty) return {'0-4': 0, '4-6': 0, '6-8': 0, '8-10': 0};

    int c1 = 0, c2 = 0, c3 = 0, c4 = 0;
    for (var s in students) {
      if (s.score < 4) c1++;
      else if (s.score < 6) c2++;
      else if (s.score < 8) c3++;
      else c4++;
    }

    int total = students.length;
    return {
      '0-4': c1 / total,
      '4-6': c2 / total,
      '6-8': c3 / total,
      '8-10': c4 / total,
    };
  }

  static Future<List<Map<String, dynamic>>> getUnitCompletionStats() async {
    final data = await ApiService.getTeacherExams();
    
    if (data.isEmpty) {
      return [
        {'title': 'Kiểm tra 15p', 'progress': 0.0},
        {'title': 'Kiểm tra 45p', 'progress': 0.0},
      ];
    }

    int m15 = data.where((e) => e['type'] == '15m').length;
    int m45 = data.where((e) => e['type'] == '45m').length;

    return [
      {'title': 'Kiểm tra 15p', 'progress': (m15 / 10).clamp(0.0, 1.0)},
      {'title': 'Kiểm tra 45p', 'progress': (m45 / 10).clamp(0.0, 1.0)},
    ];
  }

  // --- Thông báo ---
  
  static Future<void> postNewAnnouncement(String title, String content) async {
    await ApiService.createAnnouncement({
      'title': title,
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
