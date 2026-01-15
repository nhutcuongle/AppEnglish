import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:intl/intl.dart';

class ExamResultScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const ExamResultScreen({super.key, required this.examId, required this.examTitle});

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getExamReport(widget.examId);
      if (data.containsKey('error')) {
        _error = data['error'] ?? 'Lỗi không xác định';
      } else {
        _reportData = data;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Kết quả: ${widget.examTitle}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final submissions = _reportData?['data'] as List? ?? [];
    
    if (submissions.isEmpty) {
      return const Center(child: Text('Chưa có học sinh nào nộp bài.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(submissions.length),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              return _buildStudentCard(sub, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.assignment_turned_in, color: Colors.purple, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tổng số bài nộp', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(dynamic sub, int index) {
    final student = sub['student'];
    final score = sub['totalScore'];
    final submittedAt = sub['submittedAt'] != null 
        ? DateFormat('HH:mm dd/MM').format(DateTime.parse(sub['submittedAt'])) 
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student['fullName'] ?? student['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Nộp lúc: $submittedAt'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (score >= 5 ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$score đ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: score >= 5 ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
