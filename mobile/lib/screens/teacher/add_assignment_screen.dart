import 'package:flutter/material.dart';
import 'package:apptienganh10/db/mongodb.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/auth_service.dart';
import 'package:intl/intl.dart';

class AddAssignmentScreen extends StatefulWidget {
  final String? initialType;
  final Assignment? assignmentToEdit; // Object để chỉnh sửa

  const AddAssignmentScreen({super.key, this.initialType, this.assignmentToEdit});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _unitController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final _totalQuestionsController = TextEditingController();
  final _formatController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  late String _selectedType;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.assignmentToEdit != null;
    
    if (_isEditMode) {
      final a = widget.assignmentToEdit!;
      _titleController.text = a.title;
      _descController.text = a.description;
      _unitController.text = a.unit ?? '';
      _selectedType = a.type;
      _selectedDate = a.deadline;
      _timeLimitController.text = a.timeLimit?.toString() ?? '';
      _totalQuestionsController.text = a.totalQuestions?.toString() ?? '';
      _formatController.text = a.submissionFormat ?? '';
    } else {
      _selectedType = widget.initialType ?? 'homework';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _unitController.dispose();
    _timeLimitController.dispose();
    _totalQuestionsController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  Future<void> _saveAssignment() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final data = {
        'title': _titleController.text,
        'description': _descController.text,
        'unit': _unitController.text,
        'deadline': _selectedDate.toIso8601String(),
        'type': _selectedType,
        'createdAt': _isEditMode ? widget.assignmentToEdit!.deadline.toIso8601String() : DateTime.now().toIso8601String(), 
        'teacherId': AuthService.currentTeacherId,
        if (_selectedType == 'test') ...{
          'timeLimit': int.tryParse(_timeLimitController.text),
          'totalQuestions': int.tryParse(_totalQuestionsController.text),
        },
        if (_selectedType == 'homework') ...{
          'submissionFormat': _formatController.text,
        },
      };

      try {
        if (_isEditMode) {
          await MongoDatabase.updateAssignment(widget.assignmentToEdit!.id, data);
        } else {
          await MongoDatabase.insertAssignment(data);
        }
        
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        Navigator.pop(context, true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode ? 'Đã cập nhật thay đổi!' : 'Đã tạo thành công!')),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTest = _selectedType == 'test';
    Color themeColor = isTest ? Colors.purple : Colors.blueAccent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Cập nhật Nội dung' : (isTest ? 'Thiết kế Bài Kiểm Tra' : 'Giao Bài Tập Về Nhà'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditMode) _buildTypeSelector(themeColor),
              const SizedBox(height: 30),
              
              _buildLabel('Tiêu đề nội dung'),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('VD: Kiểm tra giữa kỳ, Viết luận Unit 2...'),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Chương học (Unit)'),
                        TextFormField(
                          controller: _unitController,
                          decoration: _buildInputDecoration('Unit 1'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Hạn nộp/làm bài'),
                        _buildDatePicker(themeColor),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              if (isTest) _buildTestFields() else _buildHomeworkFields(),
              
              const SizedBox(height: 25),
              _buildLabel('Mô tả chi tiết / Hướng dẫn'),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: _buildInputDecoration('Nhập các yêu cầu hoặc hướng dẫn cho học sinh...'),
              ),
              
              const SizedBox(height: 40),
              _buildSubmitButton(themeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTypeOption('homework', 'Bài tập', Icons.edit_document),
          _buildTypeOption('test', 'Kiểm tra', Icons.quiz),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String type, String label, IconData icon) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? (type == 'test' ? Colors.purple : Colors.blueAccent) : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF1E293B) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('TG làm bài (phút)'),
              TextFormField(
                controller: _timeLimitController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('VD: 45'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Số câu hỏi'),
              TextFormField(
                controller: _totalQuestionsController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('VD: 40'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeworkFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Định dạng nộp bài (Không bắt buộc)'),
        TextFormField(
          controller: _formatController,
          decoration: _buildInputDecoration('Ví dụ: File PDF, Word, Ảnh chụp...'),
        ),
      ],
    );
  }

  Widget _buildDatePicker(Color themeColor) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: themeColor),
            const SizedBox(width: 10),
            Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color themeColor) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _saveAssignment,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          _isEditMode ? 'CẬP NHẬT THAY ĐỔI' : (_selectedType == 'test' ? 'HOÀN TẤT THIẾT KẾ' : 'GIAO BÀI TẬP VỀ NHÀ'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569))),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blueAccent, width: 1)),
    );
  }
}
