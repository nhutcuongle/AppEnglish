import 'package:flutter/material.dart';
import 'package:apptienganh10/screens/student/translate_screen.dart';
import 'package:apptienganh10/screens/student/student_dashboard_tab.dart';
import 'package:apptienganh10/screens/student/unit_list_tab.dart';
import 'package:apptienganh10/screens/student/student_profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StudentDashboardTab(onTabSelected: (index) => setState(() => _currentIndex = index)),
          const UnitListTab(),
          const TranslateScreen(),
          StudentProfileTab(onBack: () => setState(() => _currentIndex = 0)),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex > 2 ? 0 : _currentIndex, // Nếu đang ở tab Hồ sơ (index 3) thì không highlight dưới thanh bar hoặc highlight về Home
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: const Color(0xFF64748B),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Bài học'),
            BottomNavigationBarItem(icon: Icon(Icons.translate_rounded), label: 'Dịch thuật'),
          ],
        ),
      ),
    );
  }
}
