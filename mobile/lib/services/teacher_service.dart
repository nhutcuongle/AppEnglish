
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/api_service.dart';

class TeacherService {
  // --- Quản lý Học sinh ---

  static Future<List<Student>> searchStudents(String query) async {
    // Gọi API thay vì DB trực tiếp
    final studentsRaw = await ApiService.getStudents();
    final students = studentsRaw.map((e) => Student.fromJson(e)).toList();
    
    if (query.isEmpty) return students;
    return students.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  static Future<List<Student>> getTopPerformer() async {
    // Lấy top 5 học sinh có điểm cao nhất từ API
    final studentsRaw = await ApiService.getStudents();
    final students = studentsRaw.map((e) => Student.fromJson(e)).toList();
    students.sort((a, b) => b.score.compareTo(a.score));
    return students.take(5).toList();
  }

  // --- Quản lý Bài tập ---

  static Future<List<Assignment>> getFilteredAssignments(String? type, {String query = ''}) async {
    // Gọi API để lấy danh sách bài tập
    final data = await ApiService.getAssignments();
    final all = data.map((e) => Assignment.fromJson(e)).toList();

    // Lọc theo loại (nếu có)
    List<Assignment> filtered = type != null 
        ? all.where((a) => a.type == type).toList() 
        : all;

    // Lọc theo từ khóa tìm kiếm
    if (query.isNotEmpty) {
      filtered = filtered.where((a) => a.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
    
    return filtered;
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
    final data = await ApiService.getAssignments();
    final assignments = data.map((e) => Assignment.fromJson(e)).toList();
    
    Map<String, List<Assignment>> unitGroups = {};
    for (var a in assignments) {
      if (a.unit != null) {
        unitGroups.putIfAbsent(a.unit!, () => []).add(a);
      }
    }

    List<Map<String, dynamic>> stats = [];
    unitGroups.forEach((unit, list) {
      stats.add({
        'title': 'Unit $unit',
        'progress': (list.length * 0.15).clamp(0.1, 1.0), 
      });
    });

    if (stats.isEmpty) {
      return [
        {'title': 'Unit 1: Family Life', 'progress': 0.8},
        {'title': 'Unit 2: Environment', 'progress': 0.6},
      ];
    }

    return stats;
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
