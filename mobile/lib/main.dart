import 'package:flutter/material.dart';
import 'package:apptienganh10/screens/teacher/teacher_home_screen.dart';
import 'package:apptienganh10/db/mongodb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bỏ qua lỗi kết nối nếu chuỗi kết nối chưa đúng để vẫn xem được UI
  try {
    await MongoDatabase.connect(); 
  } catch (e) {
    print("Database connection failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Học Tiếng Anh 10 - Giáo viên',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto', // Hoặc font mặc định sạch sẽ
      ),
      home: const TeacherHomeScreen(),
    );
  }
}
