import 'package:flutter/material.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/teacher_service.dart';
import 'package:apptienganh10/screens/teacher/student_list_screen.dart';
import 'package:apptienganh10/screens/teacher/assignment_list_screen.dart';
import 'package:apptienganh10/screens/teacher/class_statistics_screen.dart';
import 'package:apptienganh10/screens/teacher/announcement_list_screen.dart';
import 'package:apptienganh10/screens/teacher/lesson_plan_list_screen.dart';
import 'package:apptienganh10/screens/teacher/gradebook_screen.dart';

import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/teacher/teacher_profile_screen.dart';
import 'package:apptienganh10/screens/teacher/school_gradebook_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TeacherDashboardTab(),
    const LessonPlanListScreen(),
    const AnnouncementListScreen(),
    const TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: const Color(0xFF64748B),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Bàn làm việc'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded), label: 'Giáo án'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Thông báo'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }
}

class TeacherDashboardTab extends StatelessWidget {
  const TeacherDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 15),
            _buildClassOverview(),
            const SizedBox(height: 20),
            
            _buildSectionHeader('Bảng Vinh Danh', 'Học sinh xuất sắc 🏆'),
            const SizedBox(height: 10),
            _buildPremiumLeaderboard(),
            
            const SizedBox(height: 20),
            _buildSectionHeader('Công cụ quản lý', 'Dành cho giáo viên'),
            const SizedBox(height: 15),
            _buildToolsGrid(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getProfile(),
      builder: (context, snapshot) {
        String name = 'Giáo viên';
        if (snapshot.hasData && snapshot.data!['fullName'] != null) {
          name = snapshot.data!['fullName'];
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chào buổi sáng,', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                Text('$name 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2), width: 2),
              ),
              child: const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blueAccent, size: 30),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildClassOverview() {
    return FutureBuilder<List<Student>>(
      future: ApiService.getMyStudents().then((raw) => raw.map((e) => Student.fromJson(e)).toList()),
      builder: (context, snapshot) {
        final stats = TeacherService.calculateClassOverview(snapshot.data ?? []);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Học sinh', '${snapshot.data?.length ?? 0}', Icons.groups_rounded),
                  _buildStatItem('Điểm TB', '${stats['avgScore']}', Icons.auto_graph_rounded),
                  _buildStatItem('Đã nộp', '${stats['completionRate']}%', Icons.task_alt_rounded),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 15),
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.white70, size: 14),
                  SizedBox(width: 8),
                  Text('Dữ liệu lớp học cập nhật theo thời gian thực', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildPremiumLeaderboard() {
    return FutureBuilder<List<Student>>(
      future: TeacherService.getTopPerformer(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final topStudents = snapshot.data!;
        if (topStudents.isEmpty) return const SizedBox.shrink();

        return Column(
          children: topStudents.asMap().entries.map((entry) {
            int idx = entry.key;
            Student student = entry.value;
            return _buildLeaderboardTile(idx, student);
          }).toList(),
        );
      },
    );
  }

  Widget _buildLeaderboardTile(int index, Student student) {
    bool isTop3 = index < 3;
    List<Color> medalColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isTop3 ? Border.all(color: medalColors[index].withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isTop3 ? medalColors[index].withValues(alpha: 0.1) : const Color(0xFF64748B).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: isTop3 
              ? Icon(Icons.emoji_events_rounded, color: medalColors[index], size: 18)
              : Text('${index + 1}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${student.score}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isTop3 ? Colors.blueAccent : const Color(0xFF64748B))),
              const Text('đương nhiệm', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildToolCard(context, 'Học sinh', Icons.people_rounded, Colors.blue, const StudentListScreen()),
        _buildToolCard(context, 'Bài kiểm tra', Icons.quiz_rounded, Colors.purple, const AssignmentListScreen(filterType: 'test')),
        _buildToolCard(context, 'Sổ Điểm', Icons.grid_view_rounded, Colors.teal, const GradebookScreen()),
        _buildToolCard(context, 'B.Tập Trường', Icons.school_rounded, Colors.orange, const SchoolGradebookScreen()),

        _buildToolCard(context, 'Thống kê', Icons.insert_chart_rounded, Colors.green, const ClassStatisticsScreen()),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }
}
