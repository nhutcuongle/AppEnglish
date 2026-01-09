import 'package:flutter/material.dart';

class StudentManagementScreen extends StatefulWidget {
  final String? className; // Optional: if provided, only show students of this class
  
  const StudentManagementScreen({super.key, this.className});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedClass;
  
  final List<String> _classFilters = ['Tất cả', '10A1', '10A2', '10A3', '10A4', '10A5', '10A6', '10A7', '10A8'];
  
  final List<Map<String, dynamic>> _students = [
    {'id': '1', 'name': 'Nguyễn Văn Anh', 'class': '10A1', 'gender': 'Nam', 'dob': '15/03/2010', 'phone': '0912 345 001', 'status': 'active'},
    {'id': '2', 'name': 'Trần Thị Bình', 'class': '10A1', 'gender': 'Nữ', 'dob': '22/07/2010', 'phone': '0912 345 002', 'status': 'active'},
    {'id': '3', 'name': 'Lê Hoàng Cường', 'class': '10A1', 'gender': 'Nam', 'dob': '08/11/2010', 'phone': '0912 345 003', 'status': 'active'},
    {'id': '4', 'name': 'Phạm Thị Dung', 'class': '10A2', 'gender': 'Nữ', 'dob': '30/01/2010', 'phone': '0912 345 004', 'status': 'active'},
    {'id': '5', 'name': 'Hoàng Văn Em', 'class': '10A2', 'gender': 'Nam', 'dob': '14/05/2010', 'phone': '0912 345 005', 'status': 'active'},
    {'id': '6', 'name': 'Vũ Thị Phương', 'class': '10A2', 'gender': 'Nữ', 'dob': '06/09/2010', 'phone': '0912 345 006', 'status': 'inactive'},
    {'id': '7', 'name': 'Đỗ Minh Giang', 'class': '10A3', 'gender': 'Nam', 'dob': '19/02/2010', 'phone': '0912 345 007', 'status': 'active'},
    {'id': '8', 'name': 'Bùi Thị Hương', 'class': '10A3', 'gender': 'Nữ', 'dob': '25/12/2010', 'phone': '0912 345 008', 'status': 'active'},
    {'id': '9', 'name': 'Ngô Văn Inh', 'class': '10A4', 'gender': 'Nam', 'dob': '03/08/2010', 'phone': '0912 345 009', 'status': 'active'},
    {'id': '10', 'name': 'Đinh Thị Kim', 'class': '10A4', 'gender': 'Nữ', 'dob': '11/04/2010', 'phone': '0912 345 010', 'status': 'active'},
    {'id': '11', 'name': 'Lý Văn Long', 'class': '10A5', 'gender': 'Nam', 'dob': '28/06/2010', 'phone': '0912 345 011', 'status': 'active'},
    {'id': '12', 'name': 'Mai Thị Ngọc', 'class': '10A5', 'gender': 'Nữ', 'dob': '17/10/2010', 'phone': '0912 345 012', 'status': 'active'},
  ];

  @override
  void initState() {
    super.initState();
    // If className is provided, use it; otherwise use 'Tất cả'
    _selectedClass = widget.className ?? 'Tất cả';
  }

  List<Map<String, dynamic>> get _filteredStudents {
    var result = _students;
    // If className was passed (specific class view), always filter by it
    if (widget.className != null) {
      result = result.where((s) => s['class'] == widget.className).toList();
    } else if (_selectedClass != 'Tất cả') {
      result = result.where((s) => s['class'] == _selectedClass).toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      result = result.where((s) => s['name'].toLowerCase().contains(query)).toList();
    }
    return result;
  }

  List<Map<String, dynamic>> get _displayStudents {
    // For stats calculation, use students based on selected/filtered class
    if (widget.className != null) {
      return _students.where((s) => s['class'] == widget.className).toList();
    } else if (_selectedClass != 'Tất cả') {
      return _students.where((s) => s['class'] == _selectedClass).toList();
    }
    return _students;
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchAndFilter(),
            _buildStatsRow(),
            Expanded(child: _buildStudentList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentDialog(context),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Thêm HS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2196F3)), onPressed: () => Navigator.pop(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.className != null ? 'Học sinh lớp ${widget.className}' : 'Danh sách Học sinh', 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                  child: Text(widget.className ?? 'Khối 10', style: const TextStyle(fontSize: 12, color: Color(0xFF2196F3), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3F2FD))),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm học sinh...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2196F3)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8)), onPressed: () { _searchController.clear(); setState(() {}); })
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          // Only show class filter if no specific className was passed
          if (widget.className == null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _classFilters.length,
                itemBuilder: (context, index) {
                  final filter = _classFilters[index];
                  final isSelected = _selectedClass == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedClass = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE3F2FD)),
                        ),
                        child: Center(child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final students = _displayStudents;
    int maleCount = students.where((s) => s['gender'] == 'Nam').length;
    int femaleCount = students.where((s) => s['gender'] == 'Nữ').length;
    int activeCount = students.where((s) => s['status'] == 'active').length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMiniStat('Tổng cộng', '${_students.length}', const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          _buildMiniStat('Nam', '$maleCount', const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          _buildMiniStat('Nữ', '$femaleCount', const Color(0xFFE91E63)),
          const SizedBox(width: 12),
          _buildMiniStat('Đang học', '$activeCount', const Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE3F2FD))),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    final students = _filteredStudents;
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 80, color: const Color(0xFF94A3B8).withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Không tìm thấy học sinh', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: students.length,
      itemBuilder: (context, index) => _buildStudentCard(students[index]),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    bool isActive = student['status'] == 'active';
    bool isMale = student['gender'] == 'Nam';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3F2FD)),
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showStudentDetail(context, student),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: isMale ? [const Color(0xFF2196F3), const Color(0xFF1976D2)] : [const Color(0xFFE91E63), const Color(0xFFD81B60)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Icon(isMale ? Icons.male : Icons.female, color: Colors.white, size: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(student['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: isActive ? const Color(0xFF4CAF50).withOpacity(0.1) : const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(isActive ? 'Đang học' : 'Nghỉ học', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                            child: Text(student['class'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.cake_rounded, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(student['dob'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStudentDetail(BuildContext context, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StudentDetailSheet(
        student: student,
        onEdit: () {
          Navigator.pop(ctx);
          _showEditStudentDialog(context, student);
        },
        onDelete: () {
          Navigator.pop(ctx);
          _showDeleteConfirmDialog(context, student);
        },
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StudentFormSheet(
        student: student,
        defaultClass: widget.className,
        onSave: (updatedStudent) {
          setState(() {
            int index = _students.indexWhere((s) => s['id'] == student['id']);
            if (index != -1) _students[index] = updatedStudent;
          });
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Đã cập nhật thông tin học sinh!'), backgroundColor: const Color(0xFF2196F3), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.warning_rounded, color: Color(0xFFEF4444)), SizedBox(width: 12), Text('Xác nhận xóa')]),
        content: Text('Bạn có chắc muốn xóa học sinh "${student['name']}"?\n\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              setState(() => _students.removeWhere((s) => s['id'] == student['id']));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Đã xóa học sinh!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    // Calculate next order number for the selected class
    String targetClass = widget.className ?? '10A1';
    int classStudentCount = _students.where((s) => s['class'] == targetClass).length;
    int nextOrder = classStudentCount + 1;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StudentFormSheet(
        defaultClass: widget.className,
        nextOrderNumber: nextOrder,
        onSave: (newStudent) {
          setState(() {
            newStudent['id'] = DateTime.now().millisecondsSinceEpoch.toString();
            _students.add(newStudent);
          });
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã tạo tài khoản: ${newStudent['username']}'), backgroundColor: const Color(0xFF4CAF50), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
          );
        },
      ),
    );
  }
}

class _StudentDetailSheet extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const _StudentDetailSheet({required this.student, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    bool isMale = student['gender'] == 'Nam';
    const Color primaryBlue = Color(0xFF2196F3);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: isMale ? [const Color(0xFF2196F3), const Color(0xFF1976D2)] : [const Color(0xFFE91E63), const Color(0xFFD81B60)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: (isMale ? primaryBlue : const Color(0xFFE91E63)).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Center(child: Icon(isMale ? Icons.male : Icons.female, color: Colors.white, size: 40)),
                  ),
                  const SizedBox(height: 20),
                  Text(student['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
                    child: Text('Học sinh lớp ${student['class']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoRow(Icons.cake_rounded, 'Ngày sinh', student['dob']),
                  _buildInfoRow(Icons.wc_rounded, 'Giới tính', student['gender']),
                  _buildInfoRow(Icons.phone_rounded, 'Điện thoại', student['phone']),
                  _buildInfoRow(Icons.class_rounded, 'Lớp học', student['class']),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit, icon: const Icon(Icons.edit_rounded), label: const Text('Chỉnh sửa'),
                          style: OutlinedButton.styleFrom(foregroundColor: primaryBlue, side: const BorderSide(color: Color(0xFF2196F3)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete, icon: const Icon(Icons.delete_rounded), label: const Text('Xóa'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF2196F3), size: 20)),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))), Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF334155)))]),
        ],
      ),
    );
  }
}

class _StudentFormSheet extends StatefulWidget {
  final Map<String, dynamic>? student;
  final String? defaultClass;
  final Function(Map<String, dynamic>) onSave;
  final int nextOrderNumber; // For auto-generating username

  const _StudentFormSheet({this.student, this.defaultClass, required this.onSave, this.nextOrderNumber = 1});

  @override
  State<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<_StudentFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _passwordController;
  String _selectedClass = '10A1';
  String _selectedGender = 'Nam';
  String _generatedUsername = '';
  
  final List<String> _classes = ['10A1', '10A2', '10A3', '10A4', '10A5', '10A6', '10A7', '10A8'];
  final List<String> _genders = ['Nam', 'Nữ'];

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.student?['phone'] ?? '');
    _dobController = TextEditingController(text: widget.student?['dob'] ?? '');
    _passwordController = TextEditingController();
    _selectedClass = widget.student?['class'] ?? widget.defaultClass ?? '10A1';
    _selectedGender = widget.student?['gender'] ?? 'Nam';
    _generatedUsername = widget.student?['username'] ?? '';
    _updateUsername();
  }

  void _updateUsername() {
    if (!isEditing) {
      String orderStr = widget.nextOrderNumber.toString().padLeft(2, '0');
      _generatedUsername = '$_selectedClass$orderStr';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)), child: Icon(isEditing ? Icons.edit_rounded : Icons.person_add_rounded, color: primaryBlue, size: 24)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isEditing ? 'Chỉnh sửa Học sinh' : 'Thêm Học sinh mới', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), Text(isEditing ? 'Cập nhật thông tin' : 'Tạo tài khoản học sinh', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))])),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account info section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [Icon(Icons.account_circle_rounded, color: Color(0xFF2196F3), size: 20), SizedBox(width: 8), Text('Thông tin tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3)))]),
                        const SizedBox(height: 12),
                        Row(children: [const Text('Tên đăng nhập: ', style: TextStyle(color: Color(0xFF64748B))), Text(_generatedUsername.isEmpty ? '(Tự động tạo)' : _generatedUsername, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                        if (isEditing && widget.student?['username'] != null) const SizedBox(height: 4),
                        if (isEditing && widget.student?['username'] != null) Row(children: [const Text('Mật khẩu: ', style: TextStyle(color: Color(0xFF64748B))), Text(widget.student?['password'] ?? '******', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, 'Họ và tên *', 'Nhập họ và tên', Icons.person_rounded),
                  const SizedBox(height: 16),
                  _buildDropdown('Lớp học *', _selectedClass, _classes, (v) {
                    setState(() {
                      _selectedClass = v!;
                      _updateUsername();
                    });
                  }),
                  const SizedBox(height: 16),
                  if (!isEditing) ...[
                    _buildTextField(_passwordController, 'Mật khẩu *', 'Nhập mật khẩu', Icons.lock_rounded),
                    const SizedBox(height: 16),
                  ],
                  _buildTextField(_phoneController, 'Số điện thoại PH', '0912 345 678', Icons.phone_rounded, TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(_dobController, 'Ngày sinh', 'DD/MM/YYYY', Icons.cake_rounded),
                  const SizedBox(height: 16),
                  const Text('Giới tính', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Row(
                    children: _genders.map((g) {
                      bool isSelected = _selectedGender == g;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = g),
                          child: Container(
                            margin: EdgeInsets.only(right: g == 'Nam' ? 12 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(color: isSelected ? primaryBlue : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? primaryBlue : const Color(0xFFE3F2FD))),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(g == 'Nam' ? Icons.male : Icons.female, color: isSelected ? Colors.white : const Color(0xFF64748B)), const SizedBox(width: 8), Text(g, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF64748B)))]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveStudent,
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                      child: Text(isEditing ? 'Cập nhật' : 'Tạo tài khoản', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveStudent() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Vui lòng nhập họ tên học sinh!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
      return;
    }
    if (!isEditing && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Vui lòng nhập mật khẩu!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
      return;
    }
    final student = {
      'id': widget.student?['id'] ?? '',
      'name': _nameController.text,
      'username': isEditing ? (widget.student?['username'] ?? '') : _generatedUsername,
      'password': isEditing ? (widget.student?['password'] ?? '') : _passwordController.text,
      'phone': _phoneController.text.isEmpty ? '' : _phoneController.text,
      'dob': _dobController.text.isEmpty ? '' : _dobController.text,
      'class': _selectedClass,
      'gender': _selectedGender,
      'status': widget.student?['status'] ?? 'active',
    };
    widget.onSave(student);
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, [TextInputType type = TextInputType.text]) {
    bool isPassword = label.contains('Mật khẩu');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE3F2FD))),
        child: TextField(controller: controller, keyboardType: type, obscureText: isPassword, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94A3B8)), prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
      ),
    ]);
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE3F2FD))),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged)),
      ),
    ]);
  }
}

