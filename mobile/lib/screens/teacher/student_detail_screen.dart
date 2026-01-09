import 'package:flutter/material.dart';
import 'package:apptienganh10/db/mongodb.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/screens/teacher/grade_submission_screen.dart';
import 'package:intl/intl.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Thông tin chung
            _buildProfileHeader(),
            
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lịch sử nộp bài & Chấm điểm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Danh sách bài tập từ submissions
            FutureBuilder<List<Submission>>(
              future: MongoDatabase.getSubmissionsByStudent(widget.student.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final submissions = snapshot.data ?? [];

                if (submissions.isEmpty) {
                  return _buildEmptySubmissions();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    final bool isGraded = sub.score != null;
                    
                    return _buildSubmissionCard(sub, index, isGraded);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.person, size: 50, color: Colors.blue),
          ),
          const SizedBox(height: 15),
          Text(
            widget.student.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text('Lớp ${widget.student.classId ?? '10A1'}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Điểm TB', '${widget.student.score}', Colors.orange),
              _buildStatItem('Hoàn thành', '${(widget.student.progress * 100).toInt()}%', Colors.green),
              _buildStatItem('Xếp loại', widget.student.progress > 0.8 ? 'Giỏi' : 'Khá', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(Submission sub, int index, bool isGraded) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradeSubmissionScreen(
              submission: sub,
              studentName: widget.student.name,
            ),
          ),
        );
        if (result == true) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
          ],
          border: isGraded ? null : Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isGraded ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
              color: isGraded ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bài nộp #${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Nộp lúc: ${DateFormat('HH:mm - dd/MM/yyyy').format(sub.submittedAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isGraded)
              _buildScoreBadge(sub.score!)
            else
              _buildGradeAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$score',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15),
      ),
    );
  }

  Widget _buildGradeAction() {
    return const Column(
      children: [
        Icon(Icons.edit_note, color: Colors.orange, size: 20),
        Text('Chấm bài', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptySubmissions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.history_edu_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text('Chưa có lịch sử làm bài.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(child: Text('Lỗi: $error', style: const TextStyle(color: Colors.red)));
  }
}
