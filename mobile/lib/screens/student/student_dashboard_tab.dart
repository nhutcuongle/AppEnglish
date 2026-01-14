import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';

class StudentDashboardTab extends StatefulWidget {
  final Function(int)? onTabSelected;
  const StudentDashboardTab({super.key, this.onTabSelected});

  @override
  State<StudentDashboardTab> createState() => _StudentDashboardTabState();
}

class _StudentDashboardTabState extends State<StudentDashboardTab> {
  String studentName = "Học sinh";
  String className = "Đang tải...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await ApiService.getProfile();
      if (mounted) {
        setState(() {
          var data = response['data'] ?? response;
          studentName = data['fullName'] ?? "Học sinh";
          
          // Lấy thông tin lớp (có thể là object hoặc string tùy API)
          if (data['class'] != null) {
            if (data['class'] is Map) {
              className = data['class']['name'] ?? "Chưa có lớp";
            } else {
              className = data['class'].toString();
            }
          } else {
            className = "Chưa có lớp";
          }
          
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildStatsCard(),
              const SizedBox(height: 35),
              _buildSectionHeader('Công cụ học tập', 'Khám phá ngay 🚀'),
              const SizedBox(height: 20),
              _buildTaskGrid(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chào buổi sáng,', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            Text('$studentName 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text('Lớp: $className', style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w500)),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 2),
          ),
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.blueAccent, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
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
          BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Bài học', '12', Icons.auto_stories_rounded),
              _buildStatItem('Từ vựng', '85', Icons.translate_rounded),
              _buildStatItem('Thành tích', 'A+', Icons.stars_rounded),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 15),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white70, size: 14),
              SizedBox(width: 8),
              Text('Hãy cố gắng học mỗi ngày nhé!', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
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


  Widget _buildTaskGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.15,
      children: [
        _buildQuickTool('Unit', Icons.auto_stories_rounded, Colors.purple),
        _buildQuickTool('Hồ sơ', Icons.person_rounded, Colors.teal, onTap: () {
          widget.onTabSelected?.call(3); // Chuyển sang tab tài khoản (index 3)
        }),
        _buildQuickTool('Bài kiểm tra', Icons.quiz_rounded, Colors.orange),
        _buildQuickTool('Bài tập', Icons.assignment_rounded, Colors.green),
      ],
    );
  }

  Widget _buildQuickTool(String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
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
