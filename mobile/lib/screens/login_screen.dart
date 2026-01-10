import 'package:flutter/material.dart';
import 'package:apptienganh10/services/auth_service.dart';
import 'package:apptienganh10/screens/teacher/teacher_home_screen.dart';
import 'package:apptienganh10/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'teacher01');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    // Giả lập login API call (Bạn nên implement API login thật sự ở đây)
    // Hiện tại dùng mock data để demo chuyển màn
    await Future.delayed(const Duration(seconds: 1));

    final username = _usernameController.text;
    
    // Mock user data
    final userData = {
      'id': 'teacher_01',
      'username': username,
      'email': '$username@school.com',
      'role': username.contains('teacher') ? 'teacher' : 'student'
    };
    
    // Lưu session
    await AuthService.setUser(userData, token: 'mock-token-123');

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (userData['role'] == 'teacher') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherHomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text('App Tiếng Anh 10', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Tài khoản', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng Nhập'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
