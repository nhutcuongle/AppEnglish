import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
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

  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: _headers,
        body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
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

  static Future<List<dynamic>> getTeacherClasses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/classes/teacher/my-classes'), headers: _headers);
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
      final response = await http.get(Uri.parse('$baseUrl/users/students'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
  }

  // Get all students managed by the teacher
  static Future<List<dynamic>> getMyStudents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/teacher/my-students'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
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

  static Future<List<dynamic>> getStudentsByClassForTeacher(String classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/teacher/class-students/$classId'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
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
      final response = await http.post(
        Uri.parse('$baseUrl/exams'),
        headers: _headers,
        body: jsonEncode({
          'title': data['title'],
          'type': data['type'],
          'classId': data['classId'],
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'description': data['description'],
          'semester': data['semester'],
          'academicYear': data['academicYear'],
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateExam(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/exams/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<List<dynamic>> getExamReport(String examId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/exams/report/$examId'), headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
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

  static Future<dynamic> getPublicUnits() async {
    try {
      final url = '$baseUrl/units/public';
      print('=== CALLING URL: $url ===');
      final response = await http.get(Uri.parse(url), headers: _headers);
      print('=== STATUS CODE: ${response.statusCode} ===');
      print('=== RAW BODY: ${response.body} ===');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          return data['data'];
        }
        return data;
      }
      return [];
    } catch (e) {
      print('=== getPublicUnits ERROR: $e ===');
      return [];
    }
  }

  // ==================== QUESTIONS ====================

  static Future<List<dynamic>> getQuestions({String? examId, String? lessonId}) async {
    try {
      if (examId != null) {
        final response = await http.get(Uri.parse('$baseUrl/exams/$examId/questions'), headers: _headers);
        return _handleListResponse(response);
      } else if (lessonId != null) {
        final response = await http.get(Uri.parse('$baseUrl/questions/lesson/$lessonId'), headers: _headers);
        return _handleListResponse(response);
      }
      return [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> createQuestion(Map<String, dynamic> data) async {
    try {
      final response = await http.post( Uri.parse('$baseUrl/questions'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  // Create Question for Teacher with Media Support
  static Future<void> createQuestionForTeacher({
    required String examId,
    required String skill,
    required String type,
    required String content,
    List<String>? options,
    dynamic correctAnswer,
    String? explanation,
    double points = 1.0,
    List<File>? images,
    List<String>? imageCaptions,
    List<File>? audios,
    List<String>? audioCaptions,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/questions/teacher'));
      request.headers.addAll(_headers);

      request.fields['examId'] = examId;
      request.fields['skill'] = skill;
      request.fields['type'] = type;
      request.fields['content'] = content;
      request.fields['explanation'] = explanation ?? '';
      request.fields['points'] = points.toString();
      request.fields['isPublished'] = 'true';

      if (options != null) {
        for (int i = 0; i < options.length; i++) {
          request.fields['options[$i]'] = options[i];
        }
      }

      request.fields['correctAnswer'] = correctAnswer.toString();

      // Images
      if (images != null) {
        for (int i = 0; i < images.length; i++) {
          request.files.add(await http.MultipartFile.fromPath('images', images[i].path));
          if (imageCaptions != null && i < imageCaptions.length) {
            request.fields['imageCaptions[$i]'] = imageCaptions[i];
          }
        }
      }

      // Audios
      if (audios != null) {
        for (int i = 0; i < audios.length; i++) {
          request.files.add(await http.MultipartFile.fromPath('audios', audios[i].path));
          if (audioCaptions != null && i < audioCaptions.length) {
            request.fields['audioCaptions[$i]'] = audioCaptions[i];
          }
        }
      }

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode != 201) {
        final resp = await http.Response.fromStream(streamedResponse);
        throw Exception(jsonDecode(resp.body)['message'] ?? 'Lỗi tạo câu hỏi');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  static Future<Map<String, dynamic>> updateQuestion(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/questions/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
  }

  static Future<void> updateQuestionForTeacher({
    required String id,
    required String skill,
    required String type,
    required String content,
    List<String>? options,
    dynamic correctAnswer,
    String? explanation,
    double points = 1.0,
    List<File>? images,
    List<File>? audios,
  }) async {
    try {
      var request = http.MultipartRequest('PATCH', Uri.parse('$baseUrl/questions/$id'));
      request.headers.addAll(_headers);

      request.fields['skill'] = skill;
      request.fields['type'] = type;
      request.fields['content'] = content;
      request.fields['explanation'] = explanation ?? '';
      request.fields['points'] = points.toString();

      if (options != null) {
        for (int i = 0; i < options.length; i++) {
          request.fields['options[$i]'] = options[i];
        }
      }

      request.fields['correctAnswer'] = correctAnswer.toString();

      // Images
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          request.files.add(await http.MultipartFile.fromPath('images', image.path));
        }
      }

      // Audios
      if (audios != null && audios.isNotEmpty) {
        for (var audio in audios) {
          request.files.add(await http.MultipartFile.fromPath('audios', audio.path));
        }
      }

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode != 200) {
        final resp = await http.Response.fromStream(streamedResponse);
        throw Exception(jsonDecode(resp.body)['message'] ?? 'Lỗi cập nhật câu hỏi');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
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


  static Future<Map<String, dynamic>> submitLesson({
    required String lessonId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submissions/submit'),
        headers: _headers,
        body: jsonEncode({
          'lessonId': lessonId,
          'answers': answers,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<List<dynamic>> getMySubmissions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/submissions/my'),
        headers: _headers,
      );
      return _handleListResponse(response);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getSubmissionById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/submissions/$id'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }

  static Future<List<dynamic>> getScoresByLesson(String lessonId, {String? classId}) async {
    try {
      String url = '$baseUrl/submissions/lesson/$lessonId/scores';
      if (classId != null) url += '?classId=$classId';
      final response = await http.get(Uri.parse(url), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> getSubmissionDetailForTeacher(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/submissions/teacher/$id'), headers: _headers);
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }

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

  static Future<List<dynamic>> getTeacherUnits() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/units/teacher/all'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) { return []; }
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



  // ==================== VOCABULARY FETCH ====================

  static Future<List<dynamic>> getVocabularyByLesson(String lessonId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vocabularies/lesson/$lessonId'), headers: _headers);
      return _handleListResponse(response);
    } catch (e) {
      return [];
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

  static Future<Map<String, dynamic>> getPublicUnitById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/units/public/$id'),
        headers: _headers,
      );
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
      final response = await http.put(Uri.parse('$baseUrl/lessons/$id'), headers: _headers, body: jsonEncode(data));
      return jsonDecode(response.body);
    } catch (e) { return {'error': e.toString()}; }
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

<<<<<<< HEAD
  /* ================= EXAM APIs ================= */

  static Future<List<dynamic>> getStudentExams() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/exams/student'), headers: _headers);
      if (response.statusCode == 200) {
       // Response is List<Exam>
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error getStudentExams: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getExamQuestions(String examId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/exams/$examId/questions'), headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Returns List<Question>
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Lỗi tải câu hỏi (${response.statusCode})');
      }
    } catch (e) {
      print('Error getExamQuestions: $e');
      rethrow; 
    }
  }

  static Future<Map<String, dynamic>> submitExam({
    required String examId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/exams/submit'),
        headers: _headers,
        body: jsonEncode({
          'examId': examId,
          'answers': answers,
        }),
=======
  // ==================== ASSIGNMENTS (Bài tập nhà trường) ====================

  static Future<Map<String, dynamic>> createOrUpdateAssignment(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assignments'),
        headers: _headers,
        body: jsonEncode(data),
>>>>>>> origin/trandangkhoa
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Lỗi kết nối: $e'};
    }
  }
<<<<<<< HEAD
=======

  static Future<Map<String, dynamic>?> getAssignmentSettings(String lessonId, {String? classId}) async {
    try {
      String url = '$baseUrl/assignments/lesson/$lessonId';
      if (classId != null) url += '?classId=$classId';
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
>>>>>>> origin/trandangkhoa
}
