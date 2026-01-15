import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class QuestionManagementScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  final String? classId; // Optional, nếu không có sẽ cho user chọn

  const QuestionManagementScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    this.classId,
  });

  @override
  State<QuestionManagementScreen> createState() => _QuestionManagementScreenState();
}

class _QuestionManagementScreenState extends State<QuestionManagementScreen> {
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _questionTypes = [
    {'value': 'mcq', 'label': 'Trắc nghiệm', 'icon': Icons.radio_button_checked, 'color': Colors.blue},
    {'value': 'true_false', 'label': 'Đúng/Sai', 'icon': Icons.check_circle, 'color': Colors.green},
    {'value': 'fill_blank', 'label': 'Điền khuyết', 'icon': Icons.text_fields, 'color': Colors.orange},
    {'value': 'essay', 'label': 'Tự luận', 'icon': Icons.edit_note, 'color': Colors.purple},
  ];

  final List<Map<String, dynamic>> _skills = [
    {'value': 'vocabulary', 'label': 'Từ vựng'},
    {'value': 'grammar', 'label': 'Ngữ pháp'},
    {'value': 'reading', 'label': 'Đọc hiểu'},
    {'value': 'listening', 'label': 'Nghe'},
    {'value': 'speaking', 'label': 'Nói'},
    {'value': 'writing', 'label': 'Viết'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
    _initData();
  }

  Future<void> _initData() async {
    await _loadClasses();
    await _loadQuestions();
  }

  Future<void> _loadClasses() async {
    try {
      final result = await ApiService.getClasses();
      setState(() {
        _classes = (result as List).map((c) => <String, dynamic>{
          'id': c['_id']?.toString() ?? '',
          'name': c['name'] ?? 'Lớp không tên',
        }).toList();
        // Auto select first class if none provided
        if (_selectedClassId == null && _classes.isNotEmpty) {
          _selectedClassId = _classes.first['id'];
        }
      });
    } catch (e) {
      // Ignore error, classes list remains empty
    }
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getQuestions(lessonId: widget.lessonId);
      setState(() {
        _questions = (result as List).map((q) => <String, dynamic>{
          'id': q['_id']?.toString() ?? '',
          'content': q['content'] ?? '',
          'type': q['type'] ?? 'mcq',
          'skill': q['skill'] ?? 'vocabulary',
          'options': q['options'] ?? [],
          'correctAnswer': q['correctAnswer'],
          'explanation': q['explanation'] ?? '',
          'points': q['points'] ?? 1,
          'isPublished': q['isPublished'] ?? true,
          'order': q['order'] ?? 1,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Lỗi tải câu hỏi: $e');
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));

  Future<void> _showAddEditDialog({Map<String, dynamic>? question}) async {
    final contentController = TextEditingController(text: question?['content'] ?? '');
    final explanationController = TextEditingController(text: question?['explanation'] ?? '');
    final pointsController = TextEditingController(text: (question?['points'] ?? 1).toString());
    
    String selectedType = question?['type'] ?? 'mcq';
    String selectedSkill = question?['skill'] ?? 'vocabulary';
    bool isPublished = question?['isPublished'] ?? true;
    
    // Options for MCQ
    List<String> options = List<String>.from(question?['options'] ?? ['', '', '', '']);
    if (options.length < 4) options.addAll(List.filled(4 - options.length, ''));
    
    dynamic correctAnswer = question?['correctAnswer'];
    int selectedCorrectIndex = 0;
    if (correctAnswer is int) selectedCorrectIndex = correctAnswer;
    else if (correctAnswer is String && options.contains(correctAnswer)) {
      selectedCorrectIndex = options.indexOf(correctAnswer);
    }
    
    // True/False
    bool trueFalseAnswer = correctAnswer == true || correctAnswer == 'true';
    
    // Fill blank / Essay
    final fillBlankController = TextEditingController(text: correctAnswer?.toString() ?? '');

    final parentContext = context;

    final shouldSubmit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          height: MediaQuery.of(modalContext).size.height * 0.95,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(modalContext).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(question == null ? Icons.add_circle : Icons.edit, color: Colors.blue)),
                    const SizedBox(width: 12),
                    Text(question == null ? 'Thêm Câu hỏi' : 'Sửa Câu hỏi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx, false), icon: const Icon(Icons.close)),
                  ]),
                  const SizedBox(height: 20),

                  // Skill selector
                  const Text('Kỹ năng *', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedSkill,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC)),
                    items: _skills.map((s) => DropdownMenuItem(value: s['value'] as String, child: Text(s['label'] as String))).toList(),
                    onChanged: (v) => setModalState(() => selectedSkill = v!),
                  ),
                  const SizedBox(height: 16),

                  // Type selector
                  const Text('Loại câu hỏi *', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: _questionTypes.map((t) {
                    final isSelected = selectedType == t['value'];
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedType = t['value']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? (t['color'] as Color).withOpacity(0.2) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? t['color'] as Color : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(t['icon'] as IconData, size: 16, color: t['color'] as Color),
                          const SizedBox(width: 4),
                          Text(t['label'] as String, style: TextStyle(color: isSelected ? t['color'] as Color : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        ]),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 16),

                  // Content
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: 'Nội dung câu hỏi *', hintText: 'Nhập câu hỏi...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC)),
                  ),
                  const SizedBox(height: 16),

                  // Options based on type
                  if (selectedType == 'mcq') ...[
                    const Text('Các đáp án (Chọn đáp án đúng)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...List.generate(4, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Radio<int>(value: i, groupValue: selectedCorrectIndex, onChanged: (v) => setModalState(() => selectedCorrectIndex = v!)),
                        Expanded(child: TextField(
                          controller: TextEditingController(text: options[i]),
                          onChanged: (v) => options[i] = v,
                          decoration: InputDecoration(
                            hintText: 'Đáp án ${String.fromCharCode(65 + i)}',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: selectedCorrectIndex == i,
                            fillColor: selectedCorrectIndex == i ? Colors.green.withOpacity(0.1) : null,
                          ),
                        )),
                      ]),
                    )),
                  ],

                  if (selectedType == 'true_false') ...[
                    const Text('Đáp án đúng', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: RadioListTile<bool>(title: const Text('Đúng'), value: true, groupValue: trueFalseAnswer, onChanged: (v) => setModalState(() => trueFalseAnswer = v!))),
                      Expanded(child: RadioListTile<bool>(title: const Text('Sai'), value: false, groupValue: trueFalseAnswer, onChanged: (v) => setModalState(() => trueFalseAnswer = v!))),
                    ]),
                  ],

                  if (selectedType == 'fill_blank') ...[
                    const Text('Đáp án đúng', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(controller: fillBlankController, decoration: InputDecoration(hintText: 'Nhập đáp án...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  ],

                  if (selectedType == 'essay') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Row(children: [Icon(Icons.info, color: Colors.amber), SizedBox(width: 8), Expanded(child: Text('Câu hỏi tự luận sẽ được chấm điểm thủ công', style: TextStyle(color: Colors.amber)))]),
                    ),
                  ],

                  const SizedBox(height: 16),
                  TextField(controller: explanationController, maxLines: 2, decoration: InputDecoration(labelText: 'Giải thích (tùy chọn)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  TextField(controller: pointsController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Điểm', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  SwitchListTile(title: const Text('Xuất bản'), value: isPublished, onChanged: (v) => setModalState(() => isPublished = v), activeColor: Colors.blue, contentPadding: EdgeInsets.zero),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (contentController.text.isEmpty) { _showError('Vui lòng nhập nội dung câu hỏi!'); return; }
                        Navigator.pop(ctx, true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(question == null ? 'Thêm Câu hỏi' : 'Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (shouldSubmit == true && mounted) {
      showDialog(context: parentContext, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      try {
        // Prepare correct answer based on type
        dynamic finalCorrectAnswer;
        List<String> finalOptions = [];
        
        if (selectedType == 'mcq') {
          finalOptions = options.where((o) => o.isNotEmpty).toList();
          finalCorrectAnswer = selectedCorrectIndex < finalOptions.length ? finalOptions[selectedCorrectIndex] : null;
        } else if (selectedType == 'true_false') {
          finalCorrectAnswer = trueFalseAnswer;
        } else if (selectedType == 'fill_blank') {
          finalCorrectAnswer = fillBlankController.text.trim();
        }

        Map<String, dynamic> data = {
          'lessonId': widget.lessonId,
          'classId': _selectedClassId,
          'skill': selectedSkill,
          'type': selectedType,
          'content': contentController.text.trim(),
          'options': finalOptions,
          'correctAnswer': finalCorrectAnswer,
          'explanation': explanationController.text.trim(),
          'points': int.tryParse(pointsController.text) ?? 1,
          'isPublished': isPublished,
        };

        Map<String, dynamic> result;
        if (question == null) {
          result = await ApiService.createQuestion(data);
        } else {
          result = await ApiService.updateQuestion(question['id'], data);
        }

        if (mounted) Navigator.pop(parentContext);

        if (result['error'] != null) {
          _showError(result['error']);
        } else {
          _showSuccess(question == null ? 'Thêm câu hỏi thành công!' : 'Cập nhật thành công!');
          await _loadQuestions();
        }
      } catch (e) {
        if (mounted) Navigator.pop(parentContext);
        _showError('Lỗi: $e');
      }
    }
  }

  Future<void> _deleteQuestion(Map<String, dynamic> question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa câu hỏi này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      final result = await ApiService.deleteQuestion(question['id']);
      Navigator.pop(context);
      
      if (result['error'] != null) {
        _showError(result['error']);
      } else {
        _showSuccess('Đã xóa câu hỏi!');
        _loadQuestions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Câu hỏi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(widget.lessonTitle, style: const TextStyle(fontSize: 12)),
        ]),
        actions: [IconButton(onPressed: _loadQuestions, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Chưa có câu hỏi nào', style: TextStyle(color: Colors.grey[600])),
                ]))
              : RefreshIndicator(
                  onRefresh: _loadQuestions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _questions.length,
                    itemBuilder: (ctx, i) => _buildQuestionCard(_questions[i], i + 1),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm Câu hỏi', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int number) {
    final typeInfo = _questionTypes.firstWhere((t) => t['value'] == question['type'], orElse: () => _questionTypes[0]);
    final color = typeInfo['color'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('$number', style: TextStyle(fontWeight: FontWeight.bold, color: color))),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(typeInfo['icon'] as IconData, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(typeInfo['label'] as String, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                ]),
              ),
              const Spacer(),
              Text('${question['points']} điểm', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _showAddEditDialog(question: question);
                  if (v == 'delete') _deleteQuestion(question);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                ],
              ),
            ]),
            const SizedBox(height: 12),
            Text(question['content'], style: const TextStyle(fontSize: 15)),
            if ((question['options'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              ...List.generate((question['options'] as List).length, (i) {
                final isCorrect = question['correctAnswer'] == question['options'][i];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    Icon(isCorrect ? Icons.check_circle : Icons.circle_outlined, size: 16, color: isCorrect ? Colors.green : Colors.grey),
                    const SizedBox(width: 8),
                    Text('${String.fromCharCode(65 + i)}. ${question['options'][i]}', style: TextStyle(color: isCorrect ? Colors.green : Colors.black87)),
                  ]),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
