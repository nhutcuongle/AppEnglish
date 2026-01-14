import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:apptienganh10/models/teacher_models.dart';

class ApiService {
  static const String baseUrl = 'https://appenglish-0uee.onrender.com/api';

  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  static List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      if (data is Map && data.containsKey('data')) return data['data'] ?? [];
      if (data is Map) return [data];
      return [];
    }
    return [];
  }

  // ==================== AUTH ====================

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 60)); // Tăng timeout lên 60s cho Render

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        _authToken = data['token'];
      }
      return data;
    } on SocketException {
      return {'error': 'Không có kết nối internet hoặc server không phản hồi'};
    } catch (e) {
      return {'error': 'Lỗi: $e'};
    }
  }

  // ==================== USER PROFILE ====================

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/profile'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> updateProfile(String fullName, String academicYear) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: _headers,
        body: jsonEncode({'fullName': fullName, 'academicYear': academicYear}),
      );
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // ==================== TEACHERS ====================

  static Future<List<dynamic>> getTeachers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teachers'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> createTeacher({
    required String username,
    required String password,
    String? fullName,
    String? email,
    String? phone,
    List<String>? classes,
  }) async {
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/teachers'),
          headers: _headers,
          body: jsonEncode({
            'username': username,
            'password': password,
            'fullName': fullName,
            'email': email,
            'phone': phone,
            'classes': classes,
          })
      );
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> updateTeacher(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put( Uri.parse('$baseUrl/teachers/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> deleteTeacher(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/teachers/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // ==================== CLASSES ====================

  static Future<List<dynamic>> getClasses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/classes'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> createClass({required String name, required int grade}) async {
    try {
      final response = await http.post( Uri.parse('$baseUrl/classes'), headers: _headers, body: jsonEncode({'name': name, 'grade': grade}));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> updateClass(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put( Uri.parse('$baseUrl/classes/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> deleteClass(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/classes/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // ==================== STUDENTS ====================

  static Future<List<dynamic>> getStudents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/students'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
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
            'fullName': fullName,
            'phone': phone,
            'gender': gender,
            'dateOfBirth': dateOfBirth,
            'classes': classes,
          })
      );
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> updateStudent(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put( Uri.parse('$baseUrl/users/students/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> deleteStudent(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/students/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // ==================== EXAMS ====================

  static Future<List<dynamic>> getTeacherExams() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/exams/teacher'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> createExam(Map<String, dynamic> data) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/exams'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> updateExam(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/exams/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> deleteExam(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/exams/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // ==================== LESSON PLANS ====================

  static Future<List<LessonPlan>> getLessonPlans({String? teacherId}) async {
    try {
      final query = teacherId != null ? '?teacherId=$teacherId' : '';
      final response = await http.get(Uri.parse('$baseUrl/lesson-plans$query'), headers: _headers);
      final List<dynamic> data = _handleListResponse(response);
      return data.map((e) => LessonPlan.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> createLessonPlan(Map<String, dynamic> data) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/lesson-plans'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> updateLessonPlan(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/lesson-plans/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> deleteLessonPlan(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/lesson-plans/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // ==================== ANNOUNCEMENTS ====================

  static Future<List<dynamic>> getAnnouncements() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/announcements'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> createAnnouncement(Map<String, dynamic> data) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/announcements'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> updateAnnouncement(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/announcements/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> deleteAnnouncement(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/announcements/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // ==================== QUESTIONS ====================

  static Future<List<dynamic>> getQuestions({String? examId}) async {
    try {
      if (examId == null) return [];
      final response = await http.get(Uri.parse('$baseUrl/exams/$examId/questions'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> createQuestion(Map<String, dynamic> data) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/questions'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> deleteQuestion(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/questions/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // ==================== SUBMISSIONS ====================

  static Future<List<dynamic>> getSubmissions({String? studentId, String? examId}) async {
    try {
      String query = '';
      if (examId != null) query = '?examId=$examId';
      if (studentId != null) query += (query.isEmpty ? '?' : '&') + 'studentId=$studentId';

      final response = await http.get(Uri.parse('$baseUrl/submissions$query'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> gradeSubmission(String id, double score, {String? comment}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/submissions/$id/grade'),
        headers: _headers,
        body: jsonEncode({'score': score, 'comment': comment}),
      );
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }
}