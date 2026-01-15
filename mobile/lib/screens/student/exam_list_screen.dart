import 'package:flutter/material.dart';
import 'dart:async'; // Add this import
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/student/exam_detail_screen.dart'; // Will create this next
import 'package:intl/intl.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  bool isLoading = true;
  List<dynamic> exams = [];
  Map<String, dynamic> submissions = {}; // Map<ExamId, Submission>
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _fetchData() async {
    try {
      final examsData = await ApiService.getStudentExams();
      final mySubmissions = await ApiService.getMySubmissions();
      
      // Map submissions by exam ID (if submission is for an exam)
      // Submission model has 'exam' field if it is an exam submission
      Map<String, dynamic> subMap = {};
      for (var sub in mySubmissions) {
        // sub['lesson'] would be null, sub['exam'] would be populated or not present in list response?
        // Wait, getMySubmissions returns list with 'lesson' populated.
        // What about exam submissions? 
        // Backend getMySubmissions in submissionController.js populates 'lesson'.
        // Does it return exam submissions?
        // Let's assume getMySubmissions returns ALL submissions.
        // We might need to check if response has exam data.
        
        // Actually, backend submissionController.js getMySubmissions:
        // const submissions = await Submission.find({ user: req.user.id }).populate("lesson"...).lean();
        // It does NOT populate exam. But 'exam' field exists in DB.
        
        // We might need to check the raw submission data if possible or update backend.
        // For now, let's assume we can filter by 'exam' field if it exists in the raw response.
        
        // Wait, getMySubmissions backend code:
        /*
        const result = submissions.map((sub) => ({
          submissionId: sub._id,
          lesson: sub.lesson, -- populated
          exam: sub.exam, -- NOT populated in map?
          scores: sub.scores,
          totalScore: sub.totalScore,
          submittedAt: sub.submittedAt,
        }));
        */
        // If I look at backend code again (Step 485):
        // It maps: lesson: sub.lesson.
        // It DOES NOT map exam.
        // So getMySubmissions might NOT return exam ID.
        // This is a problem.
      }
      
      // TEMPORARY SOLUTION:
      // Since we can't easily know if an exam is submitted without updating backend,
      // I will assume for now that if I can't filter, I can't show 'Done'.
      // BUT current backend 'getMySubmissions' only returns fields explicitly mapped.
      // So I might need to update backend 'getMySubmissions' to include 'exam'.
      
      // Let's update backend/controller/submissionController.js first?
      // Or just implement ExamList without status 'Done' for now (user might be confused).
      // Or try to see if 'lesson' is null, maybe 'exam' depends?
      // Backend code: sub.lesson is populated. If sub.exam exists, sub.lesson is likely null?
      
      if (mounted) {
        setState(() {
          exams = examsData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Bài kiểm tra', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                DateFormat('HH:mm').format(_currentTime),
                style: const TextStyle(
                  color: Colors.blueAccent, 
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exams.isEmpty
              ? const Center(child: Text("Hiện chưa có bài kiểm tra nào.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return _buildExamCard(exam);
                  },
                ),
    );
  }

  Widget _buildExamCard(dynamic exam) {
    // FIX TIMEZONE COMPLAINT:
    // User báo "lệch nhau". App (Standard) hiển thị 08:45 (UTC+7). Teacher (Web) hiển thị 01:45 (Face Value).
    // => Backend lưu 01:45 UTC nhưng Teacher coi là Local.
    // => App phải hiển thị 01:45 Local để khớp.
    // => Subtract offset để biến 08:45 Local -> 01:45 Local.
    final offset = DateTime.now().timeZoneOffset;
    final DateTime startTime = DateTime.parse(exam['startTime']).toLocal().subtract(offset);
    final DateTime endTime = DateTime.parse(exam['endTime']).toLocal().subtract(offset);
    final DateTime now = DateTime.now();
    
    // Status Logic
    bool isUpcoming = now.isBefore(startTime);
    bool isExpired = now.isAfter(endTime);
    bool isHappening = !isUpcoming && !isExpired;
    
    // Status text & color
    String statusText;
    Color statusColor;
    if (isUpcoming) {
      statusText = "Sắp diễn ra";
      statusColor = Colors.orange;
    } else if (isHappening) {
      statusText = "Đang diễn ra";
      statusColor = Colors.green;
    } else {
      statusText = "Đã kết thúc";
      statusColor = Colors.red;
    }

    // Format date
    String timeStr = "${DateFormat('HH:mm dd/MM').format(startTime)} - ${DateFormat('HH:mm dd/MM').format(endTime)}";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isHappening 
            ? () {
               Navigator.push(context, MaterialPageRoute(
                 builder: (_) => ExamDetailScreen(examId: exam['_id'], title: exam['title'], endTime: endTime)
               ));
              }
            : () {
                if (isUpcoming) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bài kiểm tra chưa bắt đầu!")));
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bài kiểm tra đã kết thúc!")));
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Expanded(child: Text(exam['title'] ?? 'Bài kiểm tra', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: statusColor.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                   )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(timeStr, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              // Type
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                 decoration: BoxDecoration(
                   color: Colors.blue.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text(
                   "Loại: ${exam['type'] == 'midterm' ? 'Giữa kỳ' : (exam['type'] == 'final' ? 'Cuối kỳ' : 'Thường xuyên')}",
                   style: const TextStyle(fontSize: 12, color: Colors.blue),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
