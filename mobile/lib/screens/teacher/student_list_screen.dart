import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/models/teacher_models.dart';

class StudentListScreen extends StatefulWidget {
  final String? classId;
  final String? className;

  const StudentListScreen({super.key, this.classId, this.className});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> _allStudents = [];
  List<ClassInfo> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch both classes and students
      final results = await Future.wait([
        ApiService.getTeacherClasses(),
        ApiService.getMyStudents(),
      ]);

      if (!mounted) return;

      setState(() {
        _classes = (results[0] as List).map((e) => ClassInfo.fromJson(e)).toList();
        _allStudents = (results[1] as List).map((e) => Student.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Quản lý Lớp học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchData, 
            icon: const Icon(Icons.sync_rounded, color: Colors.blueAccent)
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty && _allStudents.isEmpty
              ? _buildEmptyState()
              : _buildGroupedList(),
    );
  }

  Widget _buildGroupedList() {
    // If we have a specific class filter passed from widget, filter students
    if (widget.classId != null) {
      final students = _allStudents.where((s) => s.classId == widget.classId).toList();
      return _buildStudentListView(students);
    }

    // Otherwise, show all classes as expanding tiles
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final cls = _classes[index];
        final classStudents = _allStudents.where((s) => s.classId == cls.id).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.class_rounded, color: Colors.blueAccent, size: 22),
              ),
              title: Text(
                'Lớp: ${cls.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B)),
              ),
              subtitle: Text(
                '${classStudents.length} học sinh • Khối ${cls.grade}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: classStudents.isEmpty
                  ? [const Padding(padding: EdgeInsets.all(16), child: Text('Chưa có học sinh trong lớp này'))]
                  : classStudents.map((s) => _buildStudentItem(s)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentListView(List<Student> students) {
    if (students.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) => _buildStudentItem(students[index]),
    );
  }

  Widget _buildStudentItem(Student student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.indigoAccent.withOpacity(0.1),
            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : '?', 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigoAccent)
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155))),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Điểm TB: ${student.score}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Chưa có học sinh nào.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
        ],
      ),
    );
  }
}
