import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:apptienganh10/models/teacher_models.dart';

class ApiService {
  // Production API URL
  static const String baseUrl = 'https://appenglish-0uee.onrender.com/api';
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  
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
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'grade': grade,
          if (homeroomTeacher != null) 'homeroomTeacher': homeroomTeacher,
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

  // Assign/Unassign teacher to class
  static Future<Map<String, dynamic>> assignTeacherToClass({
    required String classId,
    String? teacherId, // null to unassign
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes/assign-teacher'),
        headers: _headers,
        body: jsonEncode({
          'classId': classId,
          'teacherId': teacherId,
        }),
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
    String? email,
    String? fullName,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? classId, // Changed from classes array to classId
  }) async {
    try {
      // Generate email from username if not provided
      final studentEmail = email ?? '$username@student.school.edu.vn';
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/students'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': studentEmail,
          'password': password,
          'fullName': fullName ?? '',
          'phone': phone ?? '',
          'gender': gender ?? '',
          'dateOfBirth': dateOfBirth,
          'classId': classId,
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

  // ==================== UNITS ====================

  static Future<List<dynamic>> getUnits() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/units'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching units: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUnitById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/units/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> createUnit({
    required String title, 
    String? description, 
    bool isPublished = true,
    int? order,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/units'), 
        headers: _headers, 
        body: jsonEncode({
          'title': title, 
          'description': description ?? '', 
          'isPublished': isPublished,
          if (order != null) 'order': order,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // Helper to get image mime type from file path
  static String _getImageMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      default:
        return 'image/jpeg'; // Default to jpeg
    }
  }

  // Helper to get audio mime type from file path
  static String _getAudioMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'flac':
        return 'audio/flac';
      default:
        return 'audio/mpeg'; // Default to mp3
    }
  }

  // Helper to get video mime type from file path
  static String _getVideoMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      case '3gp':
        return 'video/3gpp';
      default:
        return 'video/mp4'; // Default to mp4
    }
  }

  static Future<Map<String, dynamic>> createUnitWithImage({
    required String title, 
    String? description, 
    bool isPublished = true,
    int? order,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/units'));
      request.headers.addAll({
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      
      request.fields['title'] = title;
      request.fields['description'] = description ?? '';
      request.fields['isPublished'] = isPublished.toString();
      if (order != null) request.fields['order'] = order.toString();
      
      if (imagePath != null) {
        final mimeType = _getImageMimeType(imagePath);
        final fileName = imagePath.split('/').last.split('\\').last;
        request.files.add(await http.MultipartFile.fromPath(
          'image', 
          imagePath,
          contentType: http_parser.MediaType.parse(mimeType),
          filename: fileName,
        ));
      }

      // Add timeout for upload (60 seconds for image upload to Cloudinary)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout - Vui lòng thử lại hoặc chọn ảnh nhỏ hơn');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        return {'error': errorBody['message'] ?? 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('createUnitWithImage error: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUnit(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/units/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUnitWithImage(String id, Map<String, dynamic> data, {String? imagePath}) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/units/$id'));
      request.headers.addAll({
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      
      data.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });
      
      if (imagePath != null) {
        final mimeType = _getImageMimeType(imagePath);
        final fileName = imagePath.split('/').last.split('\\').last;
        request.files.add(await http.MultipartFile.fromPath(
          'image', 
          imagePath,
          contentType: http_parser.MediaType.parse(mimeType),
          filename: fileName,
        ));
      }

      // Add timeout for upload (60 seconds for image upload to Cloudinary)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout - Vui lòng thử lại hoặc chọn ảnh nhỏ hơn');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        return {'error': errorBody['message'] ?? 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('updateUnitWithImage error: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUnit(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/units/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== LESSONS ====================

  static Future<List<dynamic>> getLessonsByUnit(String unitId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lessons/unit/$unitId'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createLesson({required String unitId, required String lessonType, required String title, String? content, bool isPublished = true}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/lessons'), headers: _headers, body: jsonEncode({'unit': unitId, 'lessonType': lessonType, 'title': title, 'content': content ?? '', 'isPublished': isPublished}));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> createLessonWithMedia({
    required String unitId,
    required String lessonType,
    required String title,
    String? content,
    bool isPublished = true,
    List<String>? imagePaths,
    List<String>? audioPaths,
    List<String>? videoPaths,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/lessons'));
      request.headers.addAll({
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      
      request.fields['unit'] = unitId;
      request.fields['lessonType'] = lessonType;
      request.fields['title'] = title;
      request.fields['content'] = content ?? '';
      request.fields['isPublished'] = isPublished.toString();

      if (imagePaths != null) {
        for (var path in imagePaths) {
          final mimeType = _getImageMimeType(path);
          final fileName = path.split('/').last.split('\\').last;
          request.files.add(await http.MultipartFile.fromPath(
            'images', 
            path,
            contentType: http_parser.MediaType.parse(mimeType),
            filename: fileName,
          ));
        }
      }
      if (audioPaths != null) {
        for (var path in audioPaths) {
          final mimeType = _getAudioMimeType(path);
          final fileName = path.split('/').last.split('\\').last;
          request.files.add(await http.MultipartFile.fromPath(
            'audios', 
            path,
            contentType: http_parser.MediaType.parse(mimeType),
            filename: fileName,
          ));
        }
      }
      if (videoPaths != null) {
        for (var path in videoPaths) {
          final mimeType = _getVideoMimeType(path);
          final fileName = path.split('/').last.split('\\').last;
          request.files.add(await http.MultipartFile.fromPath(
            'videos', 
            path,
            contentType: http_parser.MediaType.parse(mimeType),
            filename: fileName,
          ));
        }
      }

      // Longer timeout for video uploads (120 seconds)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw Exception('Upload timeout - Vui lòng thử lại hoặc chọn file nhỏ hơn');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        return {'error': errorBody['message'] ?? 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('createLessonWithMedia error: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateLesson(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/lessons/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteLesson(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/lessons/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== GRAMMAR ====================

  static Future<List<dynamic>> getGrammarByLesson(String lessonId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/grammar/lesson/$lessonId'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching grammar: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createGrammar({required String lessonId, required String title, required String theory, List<String>? examples, bool isPublished = true}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/grammar'), headers: _headers, body: jsonEncode({'lesson': lessonId, 'title': title, 'theory': theory, 'examples': examples ?? [], 'isPublished': isPublished}));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> createGrammarWithMedia({
    required String lessonId,
    required String title,
    required String theory,
    List<String>? examples,
    bool isPublished = true,
    List<String>? imagePaths,
    List<String>? audioPaths,
    List<String>? videoPaths,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/grammar'));
      request.headers.addAll({
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      
      request.fields['lesson'] = lessonId;
      request.fields['title'] = title;
      request.fields['theory'] = theory;
      request.fields['isPublished'] = isPublished.toString();
      if (examples != null) {
        for (var i = 0; i < examples.length; i++) {
          request.fields['examples[$i]'] = examples[i];
        }
      }

      if (imagePaths != null) {
        for (var path in imagePaths) {
          request.files.add(await http.MultipartFile.fromPath('images', path));
        }
      }
      if (audioPaths != null) {
        for (var path in audioPaths) {
          request.files.add(await http.MultipartFile.fromPath('audios', path));
        }
      }
      if (videoPaths != null) {
        for (var path in videoPaths) {
          request.files.add(await http.MultipartFile.fromPath('videos', path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateGrammar(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/grammar/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteGrammar(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/grammar/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // ==================== VOCABULARY ====================

  static Future<List<dynamic>> getVocabularyByLesson(String lessonId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vocabularies/lesson/$lessonId'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching vocabulary: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createVocabulary({required String lessonId, required String word, String? phonetic, String? meaning, String? example, bool isPublished = true}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/vocabularies'), headers: _headers, body: jsonEncode({'lesson': lessonId, 'word': word, 'phonetic': phonetic ?? '', 'meaning': meaning ?? '', 'example': example ?? '', 'isPublished': isPublished}));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> createVocabularyWithMedia({
    required String lessonId,
    required String word,
    String? phonetic,
    String? meaning,
    String? example,
    bool isPublished = true,
    List<String>? imagePaths,
    List<String>? audioPaths,
    List<String>? videoPaths,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/vocabularies'));
      request.headers.addAll({
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      
      request.fields['lesson'] = lessonId;
      request.fields['word'] = word;
      request.fields['phonetic'] = phonetic ?? '';
      request.fields['meaning'] = meaning ?? '';
      request.fields['example'] = example ?? '';
      request.fields['isPublished'] = isPublished.toString();

      if (imagePaths != null) {
        for (var path in imagePaths) {
          request.files.add(await http.MultipartFile.fromPath('images', path));
        }
      }
      if (audioPaths != null) {
        for (var path in audioPaths) {
          request.files.add(await http.MultipartFile.fromPath('audios', path));
        }
      }
      if (videoPaths != null) {
        for (var path in videoPaths) {
          request.files.add(await http.MultipartFile.fromPath('videos', path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateVocabulary(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/vocabularies/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteVocabulary(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/vocabularies/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
}

