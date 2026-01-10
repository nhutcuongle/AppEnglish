import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/auth_service.dart';

class AddLessonPlanScreen extends StatefulWidget {
  final LessonPlan? planToEdit;
  const AddLessonPlanScreen({super.key, this.planToEdit});

  @override
  State<AddLessonPlanScreen> createState() => _AddLessonPlanScreenState();
}

class _AddLessonPlanScreenState extends State<AddLessonPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _unitController = TextEditingController();
  final _topicController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _contentController = TextEditingController();
  final _resourceController = TextEditingController();
  
  List<String> _resources = [];
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.planToEdit != null) {
      _isEdit = true;
      final p = widget.planToEdit!;
      _titleController.text = p.title;
      _unitController.text = p.unit;
      _topicController.text = p.topic;
      _objectivesController.text = p.objectives;
      _contentController.text = p.content;
      _resources = List.from(p.resources);
    }
  }

  Future<void> _savePlan() async {
    if (_formKey.currentState!.validate()) {
      final doc = {
        'title': _titleController.text,
        'unit': _unitController.text,
        'topic': _topicController.text,
        'objectives': _objectivesController.text,
        'content': _contentController.text,
        'resources': _resources,
        'teacherId': AuthService.currentTeacherId,
        'createdAt': _isEdit ? widget.planToEdit!.createdAt.toIso8601String() : DateTime.now().toIso8601String(),
      };

      if (_isEdit) {
        await ApiService.updateLessonPlan(widget.planToEdit!.id, doc);
      } else {
        await ApiService.createLessonPlan(doc);
      }
      
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEdit ? 'Chỉnh sửa Giáo án' : 'Soạn Giáo án mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(onPressed: _savePlan, icon: const Icon(Icons.check_circle_rounded, color: Colors.teal, size: 28)),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput('Tiêu đề bài dạy', _titleController, 'VD: Luyện nghe Unit 3...'),
               Row(
                children: [
                  Expanded(child: _buildInput('Chương (Unit)', _unitController, 'VD: Unit 3')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput('Chủ đề (Topic)', _topicController, 'VD: Music')),
                ],
              ),
              _buildInput('Mục tiêu bài học', _objectivesController, 'VD: Hiểu được cấu trúc...', maxLines: 2),
              _buildInput('Nội dung chi tiết', _contentController, 'Các hoạt động giảng dạy...', maxLines: 8),
              
              const Text('Tài liệu / Link đính kèm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569))),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _resourceController,
                      decoration: InputDecoration(
                        hintText: 'Dán link tài liệu...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_resourceController.text.isNotEmpty) {
                        setState(() {
                          _resources.add(_resourceController.text);
                          _resourceController.clear();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _resources.map((r) => Chip(
                  label: Text(r.length > 20 ? '${r.substring(0, 20)}...' : r, style: const TextStyle(fontSize: 12)),
                  onDeleted: () => setState(() => _resources.remove(r)),
                  deleteIcon: const Icon(Icons.cancel, size: 16),
                  backgroundColor: Colors.teal.withOpacity(0.1),
                )).toList(),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _savePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(_isEdit ? 'LƯU THAY ĐỔI' : 'LƯU GIÁO ÁN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569))),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
