import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apptienganh10/models/teacher_models.dart';

class ApiService {
  // Thay đổi URL này theo server backend của bạn
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS simulator
  // static const String baseUrl = 'http://YOUR_IP:5000/api'; // Real device
  
  static String? _authToken;
  
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ==================== AUTH ====================
  
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        _authToken = data['token'];
      }
      return data;
    } catch (e) {
      return {'error': 'Lỗi kết nối: Server không phản hồi (Time out) hoặc chưa chạy.'};
    }
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== USER PROFILE ====================

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'error': 'Failed to load profile'};
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(String fullName, String academicYear) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: _headers,
        body: jsonEncode({
          'fullName': fullName,
          'academicYear': academicYear,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  // ==================== TEACHERS ====================
  
  static Future<List<dynamic>> getTeachers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teachers'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching teachers: $e');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>> createTeacher({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phone,
    List<String>? classes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teachers'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName ?? '',
          'phone': phone ?? '',
          'classes': classes ?? [],
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> updateTeacher(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/teachers/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> deleteTeacher(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/teachers/$id'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== CLASSES ====================
  
  static Future<List<dynamic>> getClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching classes: $e');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>> createClass({
    required String name,
    required int grade,
    String? homeroomTeacher,
    List<String>? schedule,
    String? room,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'grade': grade,
          if (homeroomTeacher != null) 'homeroomTeacher': homeroomTeacher,
          if (schedule != null) 'schedule': schedule,
          if (room != null) 'room': room,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  
  static Future<Map<String, dynamic>> updateClass(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/classes/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> deleteClass(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/classes/$id'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== STUDENTS ====================
  
  static Future<List<dynamic>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/students'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>> createStudent({
    required String username,
    required String password,
    String? fullName,
    String? phone,
    String? gender,
    String? dateOfBirth,
    List<String>? classes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/students'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
          'fullName': fullName ?? '',
          'phone': phone ?? '',
          'gender': gender ?? '',
          'dateOfBirth': dateOfBirth,
          'classes': classes ?? [],
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  
  static Future<Map<String, dynamic>> updateStudent(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/students/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> deleteStudent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/students/$id'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> disableStudent(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/students/$id/disable'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> enableStudent(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/students/$id/enable'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== ASSIGNMENTS ====================

  static Future<List<dynamic>> getAssignments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assignments'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching assignments: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createAssignment(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assignments'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateAssignment(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/assignments/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteAssignment(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/assignments/$id'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== SUBMISSIONS ====================

  static Future<List<dynamic>> getSubmissions({String? assignmentId, String? studentId}) async {
    try {
      String query = '';
      if (assignmentId != null) query = '?assignmentId=$assignmentId';
      if (studentId != null) query += query.isEmpty ? '?studentId=$studentId' : '&studentId=$studentId';
      
      final response = await http.get(
        Uri.parse('$baseUrl/submissions$query'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching submissions: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> gradeSubmission(String id, double score, {String? comment}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/submissions/$id/grade'),
        headers: _headers,
        body: jsonEncode({
          'score': score,
          'comment': comment
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== ANNOUNCEMENTS ====================

  static Future<List<dynamic>> getAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createAnnouncement(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/announcements'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateAnnouncement(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteAnnouncement(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== LESSON PLANS ====================

  static Future<List<LessonPlan>> getLessonPlans({String? teacherId}) async {
    try {
      final query = teacherId != null ? '?teacherId=$teacherId' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/lesson-plans$query'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LessonPlan.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching lesson plans: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createLessonPlan(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lesson-plans'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateLessonPlan(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/lesson-plans/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteLessonPlan(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/lesson-plans/$id'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }


  // ==================== QUESTIONS ====================

  static Future<List<dynamic>> getQuestions({String? lessonId, String? assignmentId}) async {
    try {
      String url = '';
      if (lessonId != null) {
        url = '$baseUrl/questions/lesson/$lessonId';
      } else if (assignmentId != null) {
        url = '$baseUrl/questions/assignment/$assignmentId';
      } else {
        return [];
      }
      
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createQuestion(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/questions'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteQuestion(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/questions/$id'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateQuestion(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/questions/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
}

