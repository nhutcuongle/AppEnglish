import 'package:flutter/material.dart';
import 'package:apptienganh10/services/teacher_service.dart';
import 'package:apptienganh10/widgets/loading_widgets.dart';

class ClassStatisticsScreen extends StatelessWidget {
  const ClassStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thống kê Lớp học', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Phân bổ điểm số', 'Dựa trên tất cả bài thi'),
            const SizedBox(height: 20),
            _buildScoreDistribution(),
            const SizedBox(height: 35),
            _buildSectionHeader('Tiến độ hoàn thành', 'Theo loại bài kiểm tra'),
            const SizedBox(height: 20),
            _buildCompletionStats(),
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

  Widget _buildScoreDistribution() {
    return FutureBuilder<Map<String, double>>(
      future: TeacherService.getScoreDistribution(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _buildErrorState('Lỗi tải phân bổ điểm');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        
        if (data.values.every((v) => v == 0)) {
          return _buildEmptyContent('Chưa có dữ liệu điểm số');
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            children: data.entries.map((e) => _buildBarRow(e.key, e.value)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBarRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 45, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: const Color(0xFFF1F5F9),
                color: _getColorForRange(label),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildCompletionStats() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: TeacherService.getUnitCompletionStats(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _buildErrorState('Lỗi tải tiến độ bài tập');
        if (!snapshot.hasData) return ShimmerWidgets.listShimmer();
        final stats = snapshot.data!;

        if (stats.isEmpty || stats.every((s) => s['progress'] == 0)) {
           return _buildEmptyContent('Chưa có bài tập nào được hoàn thành');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final item = stats[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.quiz_rounded, color: Colors.purple, size: 20),
                  const SizedBox(width: 15),
                  Expanded(child: Text(item['title'] ?? 'Bài tập', style: const TextStyle(fontWeight: FontWeight.bold))),
                  Text('${((item['progress'] ?? 0.0) * 100).toInt()}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, color: Colors.grey[300], size: 50),
          const SizedBox(height: 15),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Color _getColorForRange(String range) {
    if (range.contains('8-10')) return Colors.green;
    if (range.contains('6-8')) return Colors.blue;
    if (range.contains('4-6')) return Colors.orange;
    return Colors.red;
  }
}
