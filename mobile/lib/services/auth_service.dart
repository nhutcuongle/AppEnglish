import 'package:apptienganh10/models/teacher_models.dart';

class AuthService {
  // Biến lưu trữ người dùng hiện tại sau khi đăng nhập thành công
  static Map<String, dynamic>? _currentUser;

  // Lấy ID giáo viên hiện tại (dùng để lọc dữ liệu)
  static String get currentTeacherId => _currentUser?['id'] ?? 'teacher_01';

  // Lấy tên giáo viên
  static String get teacherName => _currentUser?['name'] ?? 'Giáo viên';

  // Kiểm tra đã đăng nhập chưa
  static bool get isLoggedIn => _currentUser != null;

  // Hàm để bên khác gọi khi có kết quả từ API Đăng nhập/Đăng ký
  static void setUser(Map<String, dynamic> userData) {
    _currentUser = userData;
    print("AuthService: Đã thiết lập người dùng mới: ${userData['name']}");
  }

  // Đăng xuất
  static void logout() {
    _currentUser = null;
  }
}
