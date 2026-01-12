import 'package:shared_preferences/shared_preferences.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static String? _token;
  static Map<String, dynamic>? _userData;

  static String get teacherName => _userData?['fullName'] ?? 'Giáo viên';
  static String? get currentTeacherId => _userData?['_id'];
  static String? get currentUserId => _userData?['_id'];
  static bool get isLoggedIn => _token != null;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        _userData = jsonDecode(userStr);
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }
    if (_token != null) {
      ApiService.setAuthToken(_token!);
    }
  }

  static Future<void> saveLoginData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
    _token = token;
    _userData = user;
    ApiService.setAuthToken(token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    _token = null;
    _userData = null;
    ApiService.setAuthToken('');
  }
}
