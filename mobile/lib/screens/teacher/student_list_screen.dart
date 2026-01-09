import 'package:flutter/material.dart';
import 'package:apptienganh10/db/mongodb.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/teacher_service.dart';
import 'package:apptienganh10/screens/teacher/student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Học sinh', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: FutureBuilder<List<Student>>(
        future: TeacherService.searchStudents(_searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          
          if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());

          final students = snapshot.data ?? [];
          if (students.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentCard(student);
            },
          );
        },
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
          hintText: 'Tìm kiếm tên học sinh...',
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

  Widget _buildStudentCard(Student student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StudentDetailScreen(student: student))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(student.name),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      Text('Lớp ${student.classId ?? '10A1'}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      const SizedBox(height: 12),
                      _buildLinearProgress(student.progress),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildScoreBadge(student.score),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade300, Colors.blue.shade600]),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLinearProgress(double val) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hoàn thành', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
            Text('${(val * 100).toInt()}%', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('$score', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
          const Text('điểm', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Không tìm thấy học sinh "$_searchQuery"', style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildErrorState(String err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('Lỗi kết nối: $err', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
            TextButton(onPressed: () => setState(() {}), child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

// Xóa extension cũ gây lỗi
