import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/screens/teacher/question_list_screen.dart';
import 'package:intl/intl.dart';


class AddAssignmentScreen extends StatefulWidget {
  final String? initialType;
  final Assignment? assignmentToEdit; 

  const AddAssignmentScreen({super.key, this.initialType, this.assignmentToEdit});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2));
  
  String _selectedType = "15m"; 
  bool _isEditMode = false;
  
  List<dynamic> _classes = [];
  String? _selectedClassId;
  bool _isLoadingClasses = true;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.assignmentToEdit != null;
    
    if (_isEditMode) {
      final a = widget.assignmentToEdit!;
      _titleController.text = a.title;
      _descController.text = a.description;
      _selectedType = a.timeLimit == 45 ? "45m" : "15m";
      _startTime = DateTime.now(); // Cần backend trả về startTime
      _endTime = a.deadline;
      _selectedClassId = a.classId;
    }

    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final classes = await ApiService.getClasses();
      if (!mounted) return;
      setState(() {
        _classes = classes;
        if (_classes.isNotEmpty) {
          bool exists = _classes.any((c) => c['_id'] == _selectedClassId);
          if (!exists) {
             _selectedClassId = _classes[0]['_id'];
          }
        }
        _isLoadingClasses = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingClasses = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveExam() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClassId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn lớp học')));
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final data = {
        'title': _titleController.text,
        'type': _selectedType, // "15m" hoặc "45m"
        'classId': _selectedClassId,
        'startTime': _startTime.toIso8601String(),
        'endTime': _endTime.toIso8601String(),
        'description': _descController.text,
      };

      try {
        if (_isEditMode) {
          await ApiService.updateExam(widget.assignmentToEdit!.id, data);
        } else {
          await ApiService.createExam(data);
        }
        
        if (!mounted) return;
        Navigator.pop(context); 
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode ? 'Đã cập nhật!' : 'Đã tạo bài kiểm tra thành công!')),
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
    const Color themeColor = Colors.purple;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Cập nhật Bài Kiểm Tra' : 'Thiết kế Bài Kiểm Tra',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: _isLoadingClasses 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Chọn lớp học (Bạn đang chủ nhiệm)'),
              _buildClassDropdown(themeColor),
              const SizedBox(height: 25),

              _buildLabel('Tiêu đề bài kiểm tra'),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('VD: Kiểm tra 15p Unit 1...'),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 25),

              _buildLabel('Loại bài kiểm tra'),
              Row(
                children: [
                  _buildDurationChip("15m", "15 Phút", themeColor),
                  const SizedBox(width: 15),
                  _buildDurationChip("45m", "45 Phút", themeColor),
                ],
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Giờ bắt đầu'),
                        _buildDateTimePicker(true, themeColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Hạn nộp bài'),
                        _buildDateTimePicker(false, themeColor),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              
              _buildLabel('Mô tả chi tiết'),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _buildInputDecoration('Hướng dẫn cho học sinh...'),
              ),
              
              const SizedBox(height: 40),
              _buildSubmitButton(themeColor),
              if (_isEditMode) _buildManageQuestionsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassDropdown(Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedClassId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: themeColor),
          hint: const Text('Chọn lớp học'),
          items: _classes.map((c) {
            return DropdownMenuItem<String>(
              value: c['_id'],
              child: Text(c['name'] ?? 'Lớp không tên'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedClassId = val),
        ),
      ),
    );
  }

  Widget _buildDurationChip(String type, String label, Color themeColor) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? themeColor : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? themeColor : const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(bool isStart, Color themeColor) {
    DateTime current = isStart ? _startTime : _endTime;
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: current,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(current),
          );
          if (pickedTime != null) {
            setState(() {
              DateTime newDt = DateTime(
                pickedDate.year, pickedDate.month, pickedDate.day,
                pickedTime.hour, pickedTime.minute
              );
              if (isStart) _startTime = newDt;
              else _endTime = newDt;
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: themeColor),
            const SizedBox(width: 10),
            Text(
              DateFormat('dd/MM HH:mm').format(current),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
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
        onPressed: _saveExam,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          _isEditMode ? 'CẬP NHẬT BÀI KIỂM TRA' : 'HOÀN TẤT THIẾT KẾ',
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
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    );
  }

  Widget _buildManageQuestionsButton() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionListScreen(
                examId: widget.assignmentToEdit!.id,
                assignmentTitle: widget.assignmentToEdit!.title,
              ),
            ),
          );
        },
        icon: const Icon(Icons.list_alt),
        label: const Text('QUẢN LÝ CÂU HỎI', style: TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.purple,
          side: const BorderSide(color: Colors.purple, width: 2),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
