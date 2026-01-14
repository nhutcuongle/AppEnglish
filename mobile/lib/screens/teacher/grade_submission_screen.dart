import 'package:flutter/material.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/api_service.dart';

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
  bool _isSaving = false;

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

    setState(() => _isSaving = true);

    try {
      final result = await ApiService.gradeSubmission(
        widget.submission.id,
        score,
        comment: _commentController.text,
      );
      
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result.containsKey('error')) {
        _showErrorSnack(result['error']);
      } else {
        _showSuccessSnack();
        Navigator.pop(context, true); // Trả về true để màn hình trước đó load lại data
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showErrorSnack(e.toString());
    }
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
        title: const Text('Chấm điểm Bài thi', style: TextStyle(fontWeight: FontWeight.bold)),
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
            
            _buildLabel('Thông tin bài làm:'),
            _buildInfoCard(),
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
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
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

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Loại bài nộp: Bài kiểm tra hệ thống', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('ID bài thi: ${widget.submission.examId}'),
          const SizedBox(height: 8),
          const Text('Trạng thái: Đã nhận dữ liệu từ backend.', style: TextStyle(color: Colors.blue, fontSize: 13)),
        ],
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
      decoration: _buildInputDecoration('Ghi nhận xét cho học sinh tại đây...'),
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
        onPressed: _isSaving ? null : _submitGrade,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Xác nhận & Lưu điểm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
