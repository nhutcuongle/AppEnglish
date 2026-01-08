import 'package:flutter/material.dart';
import 'package:apptienganh10/db/mongodb.dart';
import 'package:apptienganh10/models/teacher_models.dart';

class GradeSubmissionScreen extends StatefulWidget {
  final Submission submission;
  final String studentName;
  const GradeSubmissionScreen({super.key, required this.submission, required this.studentName});

  @override
  State<GradeSubmissionScreen> createState() => _GradeSubmissionScreenState();
}

class _GradeSubmissionScreenState extends State<GradeSubmissionScreen> {
  late TextEditingController _scoreController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(text: widget.submission.score?.toString() ?? '');
    _commentController = TextEditingController(text: widget.submission.comment ?? '');
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitGrade() async {
    final double? score = double.tryParse(_scoreController.text);
    if (score == null || score < 0 || score > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập điểm hợp lệ (0-10)')),
      );
      return;
    }

    _showLoading();

    try {
      await MongoDatabase.gradeSubmission(
        widget.submission.id,
        score,
        _commentController.text,
      );
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      Navigator.pop(context, true); // Return success
      _showSuccessSnack();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnack(e.toString());
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSuccessSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật điểm thành công!', style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  void _showErrorSnack(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $error')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chấm điểm', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 25),
            
            _buildLabel('Nội dung bài làm:'),
            _buildContentPreview(),
            const SizedBox(height: 30),
            
            _buildLabel('Nhập điểm số (0 - 10)'),
            _buildScoreInput(),
            
            const SizedBox(height: 25),
            _buildLabel('Nhận xét của giáo viên'),
            _buildCommentInput(),
            
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Colors.blue, size: 30),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Học sinh đang chấm:', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text(widget.studentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildContentPreview() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        widget.submission.content.isNotEmpty ? widget.submission.content : 'Không có nội dung bài làm.',
        style: const TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _buildScoreInput() {
    return TextField(
      controller: _scoreController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: _buildInputDecoration('Nhập điểm VD: 9.0'),
    );
  }

  Widget _buildCommentInput() {
    return TextField(
      controller: _commentController,
      maxLines: 4,
      decoration: _buildInputDecoration('Ghi nhận xét của anh cho học sinh tại đây...'),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _submitGrade,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
        child: const Text('Xác nhận & Lưu điểm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
