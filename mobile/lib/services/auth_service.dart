import 'dart:convert';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // Biến lưu trữ người dùng hiện tại sau khi đăng nhập thành công
  static Map<String, dynamic>? _currentUser;
  static String? _token;

  // Lấy Token
  static String? get token => _token;

  // Lấy ID giáo viên hiện tại (dùng để lọc dữ liệu)
  static String get currentTeacherId => _currentUser?['id'] ?? 'teacher_01';

  // Lấy tên giáo viên
  static String get teacherName => _currentUser?['username'] ?? 'Giáo viên';

  // Kiểm tra đã đăng nhập chưa
  static bool get isLoggedIn => _currentUser != null;

  // Hàm để bên khác gọi khi có kết quả từ API Đăng nhập/Đăng ký
  static Future<void> setUser(Map<String, dynamic> userData, {String? token}) async {
    _currentUser = userData;
    _token = token;
    
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    }
    await prefs.setString(_userKey, jsonEncode(userData));

    print("AuthService: Đã thiết lập người dùng mới: ${userData['username']}");
  }

  // Khôi phục trạng thái đăng nhập
  static Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_tokenKey)) return false;

    final token = prefs.getString(_tokenKey);
    final userStr = prefs.getString(_userKey);

    if (token != null && userStr != null) {
      _token = token;
      _currentUser = jsonDecode(userStr);
      print("AuthService: Auto login success for ${_currentUser?['username']}");
      return true;
    }
    return false;
  }

  // Đăng xuất
  // Đăng xuất
  static Future<void> logout() async {
    _currentUser = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
