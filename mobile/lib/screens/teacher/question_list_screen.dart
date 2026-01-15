import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/teacher/add_question_screen.dart';

class QuestionListScreen extends StatefulWidget {
  final String examId;
  final String assignmentTitle;

  const QuestionListScreen({
    super.key, 
    required this.examId,
    required this.assignmentTitle
  });

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  List<dynamic> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Chỉ sử dụng examId vì phần Bài tập (Assignments) đã bị xóa
      final questions = await ApiService.getQuestions(
        examId: widget.examId,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error loading questions: $e');
    }
  }

  Future<void> _deleteQuestion(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa câu hỏi?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.deleteQuestion(id);
      _loadQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Câu hỏi: ${widget.assignmentTitle}'),
        actions: [
          IconButton(onPressed: _loadQuestions, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text('Chưa có câu hỏi nào cho bài thi này'),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _openAddQuestion(),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm câu hỏi ngay'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  separatorBuilder: (ctx, i) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final q = _questions[i];
                    return ListTile(
                      title: Text('Câu ${i + 1}: ${q['content']}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('Loại: ${q['type']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteQuestion(q['_id']),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddQuestion(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddQuestion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(examId: widget.examId),
      ),
    ).then((value) {
      if (value == true) _loadQuestions();
    });
  }
}

