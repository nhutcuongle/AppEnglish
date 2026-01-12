import 'package:flutter/material.dart';

import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/teacher_service.dart';

class ClassStatisticsScreen extends StatefulWidget {
  const ClassStatisticsScreen({super.key});

  @override
  State<ClassStatisticsScreen> createState() => _ClassStatisticsScreenState();
}

class _ClassStatisticsScreenState extends State<ClassStatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thống kê Lớp học', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: FutureBuilder<List<Student>>(
        future: ApiService.getStudents().then((raw) => raw.map((e) => Student.fromJson(e)).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final students = snapshot.data ?? [];
          final overview = TeacherService.calculateClassOverview(students);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng quan kết quả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryCard('Điểm TB lớp', overview['avgScore'].toString(), Colors.blueAccent),
                    const SizedBox(width: 16),
                    _buildSummaryCard('Nộp bài (%)', '${overview['completionRate']}%', Colors.teal),
                  ],
                ),
                const SizedBox(height: 32),
                
                _buildSectionTitle('Phân bố điểm số'),
                _buildScoreChart(),
                
                const SizedBox(height: 32),
                _buildSectionTitle('Tiến độ theo Unit học tập'),
                _buildUnitProgressList(),
                
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Dữ liệu được lấy trực tiếp từ hệ thống',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
    );
  }

  Widget _buildScoreChart() {
    return FutureBuilder<Map<String, double>>(
      future: TeacherService.getScoreDistribution(),
      builder: (context, snapshot) {
        final dist = snapshot.data ?? {'0-4': 0.1, '4-6': 0.2, '6-8': 0.5, '8-10': 0.2};
        return Container(
          height: 220,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(dist['0-4']!, '0-4', Colors.redAccent),
              _buildBar(dist['4-6']!, '4-6', Colors.orangeAccent),
              _buildBar(dist['6-8']!, '6-8', Colors.blueAccent),
              _buildBar(dist['8-10']!, '8-10', Colors.teal),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(double factor, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 32,
          height: (120 * factor).clamp(10, 120),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUnitProgressList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: TeacherService.getUnitCompletionStats(),
      builder: (context, snapshot) {
        final units = snapshot.data ?? [];
        if (units.isEmpty) return const Center(child: Text('Chưa có dữ liệu bài tập'));
        
        return Column(
          children: units.map((u) => _buildProgressItem(u['title'], u['progress'])).toList(),
        );
      },
    );
  }

  Widget _buildProgressItem(String title, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
