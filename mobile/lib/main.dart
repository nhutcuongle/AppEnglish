import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:apptienganh10/screens/login_screen.dart';
import 'package:apptienganh10/screens/school/school_home_screen.dart';
import 'package:apptienganh10/screens/teacher/teacher_home_screen.dart';
import 'package:apptienganh10/screens/student/home_screen.dart';
import 'package:apptienganh10/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize dotenv
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  // Initialize AuthService to load saved token
  await AuthService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Trường học',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    // Check if user is logged in with valid token
    if (AuthService.isLoggedIn) {
      final role = AuthService.userRole;
      if (role == 'school' || role == 'admin') {
        return const SchoolHomeScreen();
      } else if (role == 'teacher') {
        return const TeacherHomeScreen();
      } else {
        return const HomeScreen();
      }
    }
    return const LoginScreen();
  }
}

