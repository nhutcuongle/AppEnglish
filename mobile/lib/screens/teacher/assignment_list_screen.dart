import 'package:flutter/material.dart';
import 'package:apptienganh10/db/mongodb.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/teacher_service.dart';
import 'package:apptienganh10/screens/teacher/add_assignment_screen.dart';
import 'package:apptienganh10/widgets/loading_widgets.dart';
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

  Future<void> _deleteAssignment(Assignment item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Anh có chắc muốn xóa bài "${item.title}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('XÓA VĨNH VIỄN', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MongoDatabase.deleteAssignment(item.id);
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thành công!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.filterType == 'test' ? 'Quản lý Kiểm tra' : 'Quản lý Bài tập';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        future: TeacherService.getFilteredAssignments(widget.filterType, query: _searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerWidgets.listShimmer();
          }
          
          if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());

          final assignments = snapshot.data ?? [];
          if (assignments.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final item = assignments[index];
              return _buildAssignmentCard(item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => AddAssignmentScreen(initialType: widget.filterType))
          );
          if (result == true) setState(() {});
        },
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tạo mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          hintText: 'Tìm theo tiêu đề bài tập...',
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

  Widget _buildAssignmentCard(Assignment item) {
    final isExpired = item.deadline.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTypeTag(item.type),
              Row(
                children: [
                  _buildDeadlineStatus(item.deadline, isExpired),
                  const SizedBox(width: 8),
                  _buildMoreMenu(item),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 6),
          Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4)),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 14, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Text(item.unit ?? 'Chương ?', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              const Spacer(),
              _buildActionBtn('Chi tiết nộp bài', Colors.blueAccent),
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
          _deleteAssignment(item);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B), size: 20),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [Icon(Icons.edit_rounded, size: 18, color: Colors.blue), SizedBox(width: 10), Text('Chỉnh sửa')],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 10), Text('Xóa bài', style: TextStyle(color: Colors.red))],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeTag(String type) {
    bool isTest = type == 'test';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isTest ? Colors.purple.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isTest ? 'KIỂM TRA' : 'BÀI TẬP VỀ NHÀ',
        style: TextStyle(color: isTest ? Colors.purple : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDeadlineStatus(DateTime deadline, bool isExpired) {
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 14, color: isExpired ? Colors.redAccent : const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          'Hạn: ${DateFormat('dd/MM').format(deadline)}',
          style: TextStyle(color: isExpired ? Colors.redAccent : const Color(0xFF64748B), fontSize: 12, fontWeight: isExpired ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildActionBtn(String label, Color color) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: color.withOpacity(0.05),
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
          Icon(Icons.assignment_late_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(_searchQuery.isEmpty ? 'Chưa có nội dung nào.' : 'Không tìm thấy bài tập phù hợp.', style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildErrorState(String err) {
    return Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent)));
  }
}
