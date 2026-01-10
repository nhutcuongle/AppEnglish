import 'dart:convert';
import 'package:apptienganh10/models/announcement_models.dart';
import 'package:apptienganh10/models/assignment_model.dart';
import 'package:http/http.dart' as http;
import 'package:apptienganh10/services/auth_service.dart';

class ApiService {
  // Đối với Android Emulator, 10.0.2.2 là localhost của máy chủ
  static const String baseUrl = "http://10.0.2.2:5000/api";
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (AuthService.token != null) 'Authorization': 'Bearer ${AuthService.token}',
  };

  // --- Generic Methods ---

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? body['error'] ?? 'Lỗi không xác định');
    }
  }

  // --- Specific Endpoints ---

  // Lấy danh sách học sinh (Teacher/School)
  static Future<List<dynamic>> getStudents() async {
    // Tùy thuộc vào backend, endpoint có thể khác nhau
    // Đối với giáo viên: /teachers/my-class/students
    try {
      final data = await get('/teachers/my-class/students');
      return data['students'] as List<dynamic>;
    } catch (e) {
      // Fallback nếu chưa có dữ liệu thật hoặc lỗi
      print('ApiService Error: $e');
      return [];
    }
  }

  // Lấy danh sách bài tập
  static Future<List<dynamic>> getAssignments({String? type}) async {
    final query = type != null ? '?type=$type' : '';
    final data = await get('/assignments$query');
    return data as List<dynamic>;
  }
  // --- Assignments ---

  static Future<dynamic> createAssignment(Map<String, dynamic> data) async {
    return await post('/assignments', data);
  }

  static Future<List<Assignment>> getAssignments({String? classId}) async {
    final query = classId != null ? '?classId=$classId' : '';
    final data = await get('/assignments$query');
    return (data as List).map((e) => Assignment.fromJson(e)).toList();
  }

  static Future<dynamic> updateAssignment(String id, Map<String, dynamic> data) async {
    return await put('/assignments/$id', data);
  }

  static Future<dynamic> deleteAssignment(String id) async {
    return await delete('/assignments/$id');
  }

  // --- Announcements ---

  static Future<dynamic> createAnnouncement(Map<String, dynamic> data) async {
    return await post('/announcements', data);
  }

  static Future<List<Announcement>> getAnnouncements({String? classId}) async {
    final query = classId != null ? '?classId=$classId' : '';
    final data = await get('/announcements$query');
    return (data as List).map((e) => Announcement.fromJson(e)).toList();
  }

  static Future<dynamic> updateAnnouncement(String id, Map<String, dynamic> data) async {
    return await put('/announcements/$id', data);
  }

  static Future<dynamic> deleteAnnouncement(String id) async {
    return await delete('/announcements/$id');
  }
}
