import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/teacher_service.dart';
import 'package:apptienganh10/screens/teacher/add_assignment_screen.dart';
import 'package:apptienganh10/screens/teacher/question_list_screen.dart';
import 'package:intl/intl.dart';

class AssignmentListScreen extends StatefulWidget {
  final String? filterType;
  const AssignmentListScreen({super.key, this.filterType});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteExam(Assignment item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Anh có chắc muốn xóa bài kiểm tra "${item.title}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('XÓA', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteExam(item.id);
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa bài kiểm tra thành công!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Kiểm tra', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: FutureBuilder<List<Assignment>>(
        future: TeacherService.getFilteredAssignments(null, query: _searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());

          final exams = snapshot.data ?? [];
          if (exams.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final item = exams[index];
              return _buildExamCard(item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddAssignmentScreen())
          );
          if (result == true) setState(() {});
        },
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tạo bài thi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Tìm bài kiểm tra...',
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildExamCard(Assignment item) {
    final isExpired = item.deadline.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  'KIỂM TRA ${item.type.toUpperCase()}', 
                  style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              _buildMoreMenu(item),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 6),
          Text(item.description, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 14, color: isExpired ? Colors.redAccent : Colors.blueAccent),
              const SizedBox(width: 6),
              Text(
                'Hết hạn: ${DateFormat('dd/MM HH:mm').format(item.deadline)}',
                style: TextStyle(color: isExpired ? Colors.redAccent : Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Spacer(),
              _buildActionBtn('Câu hỏi', Colors.blueAccent, onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionListScreen(
                      examId: item.id,
                      assignmentTitle: item.title,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              _buildActionBtn('Kết quả', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreMenu(Assignment item) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAssignmentScreen(assignmentToEdit: item)),
          );
          if (result == true) setState(() {});
        } else if (value == 'delete') {
          _deleteExam(item);
        } else if (value == 'questions') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionListScreen(
                examId: item.id,
                assignmentTitle: item.title,
              ),
            ),
          );
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B), size: 20),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: Colors.blue), SizedBox(width: 10), Text('Chỉnh sửa')]),
        ),
        const PopupMenuItem(
          value: 'questions',
          child: Row(children: [Icon(Icons.quiz_rounded, size: 18, color: Colors.purple), SizedBox(width: 10), Text('Quản lý câu hỏi')]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 10), Text('Xóa bài', style: TextStyle(color: Colors.red))]),
        ),
      ],
    );
  }

  Widget _buildActionBtn(String label, Color color, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed ?? () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: color.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Chưa có bài kiểm tra nào.', style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildErrorState(String err) {
    return Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent)));
  }
}
