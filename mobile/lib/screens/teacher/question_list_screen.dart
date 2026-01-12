import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/widgets/loading_widgets.dart';

class QuestionListScreen extends StatefulWidget {
  final String assignmentId;
  final String assignmentTitle;

  const QuestionListScreen({super.key, required this.assignmentId, required this.assignmentTitle});

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
    setState(() => _isLoading = true);
    final questions = await ApiService.getQuestions(assignmentId: widget.assignmentId);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
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
                      const Text('Chưa có câu hỏi nào'),
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
    showDialog(
      context: context,
      builder: (context) => AddQuestionDialog(assignmentId: widget.assignmentId),
    ).then((_) => _loadQuestions());
  }
}

class AddQuestionDialog extends StatefulWidget {
  final String assignmentId;
  const AddQuestionDialog({super.key, required this.assignmentId});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _contentController = TextEditingController();
  String _type = 'mcq';
  // Simplified for demo: MCQ options
  final _opt1 = TextEditingController();
  final _opt2 = TextEditingController();
  final _opt3 = TextEditingController();
  final _opt4 = TextEditingController();
  int _correctIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm câu hỏi mới'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: _type,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'mcq', child: Text('Trắc nghiệm (MCQ)')),
                DropdownMenuItem(value: 'true_false', child: Text('Đúng / Sai')),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 10),
            TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Nội dung câu hỏi')),
            const SizedBox(height: 10),
            if (_type == 'mcq') ...[
              TextField(controller: _opt1, decoration: const InputDecoration(labelText: 'Đáp án A')),
              TextField(controller: _opt2, decoration: const InputDecoration(labelText: 'Đáp án B')),
              TextField(controller: _opt3, decoration: const InputDecoration(labelText: 'Đáp án C')),
              TextField(controller: _opt4, decoration: const InputDecoration(labelText: 'Đáp án D')),
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: _correctIndex,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Đúng là A')),
                  DropdownMenuItem(value: 1, child: Text('Đúng là B')),
                  DropdownMenuItem(value: 2, child: Text('Đúng là C')),
                  DropdownMenuItem(value: 3, child: Text('Đúng là D')),
                ],
                onChanged: (v) => setState(() => _correctIndex = v!),
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            final data = {
              'assignment': widget.assignmentId,
              'content': _contentController.text,
              'type': _type,
              'skill': 'reading', // Default
              'options': [_opt1.text, _opt2.text, _opt3.text, _opt4.text],
              'correctAnswer': _correctIndex,
            };
            await ApiService.createQuestion(data);
            if (!mounted) return;
            Navigator.pop(context);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
