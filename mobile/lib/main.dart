import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'theme/app_theme.dart';
import 'package:apptienganh10/services/auth_service.dart';
import 'package:apptienganh10/screens/login_screen.dart';
import 'package:apptienganh10/screens/teacher/teacher_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Tiếng Anh 10',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder(
        future: AuthService.tryAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Nếu đã login -> Check role để chuyển trang (Mock logic)
          if (snapshot.data == true) {
             // Logic check role đơn giản dựa trên tên (hoặc lưu role trong AuthService)
             // Tạm thời mặc định vào TeacherHomeScreen nếu tên chứa 'teacher'
             if (AuthService.teacherName.toLowerCase().contains('teacher')) {
               return const TeacherHomeScreen(); 
             }
             return const HomeScreen();
          }
          return const LoginScreen();
        }
      ),
    );
  }
}
