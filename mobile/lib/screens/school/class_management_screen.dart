import 'package:flutter/material.dart';
import 'package:apptienganh10/screens/school/student_management_screen.dart';
import 'package:apptienganh10/services/api_service.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Fetch classes and students in parallel
      final results = await Future.wait([
        ApiService.getClasses(),
        ApiService.getStudents(),
      ]);
      final classData = results[0] as List;
      final studentsData = results[1] as List;
      
      // Build gender counts per class
      final Map<String, int> maleCountMap = {};
      final Map<String, int> femaleCountMap = {};
      
      for (var student in studentsData) {
        // Get class name from student's class field
        String? className;
        if (student['class'] is Map) {
          className = student['class']['name']?.toString();
        }
        if (className != null && className.isNotEmpty) {
          final gender = student['gender']?.toString().toLowerCase() ?? '';
          if (gender == 'male' || gender == 'nam') {
            maleCountMap[className] = (maleCountMap[className] ?? 0) + 1;
          } else if (gender == 'female' || gender == 'nữ' || gender == 'nu') {
            femaleCountMap[className] = (femaleCountMap[className] ?? 0) + 1;
          }
        }
      }
      
      setState(() {
        _classes = classData.map<Map<String, dynamic>>((c) {
          final className = c['name']?.toString() ?? '';
          return {
            'id': c['_id']?.toString() ?? '',
            'name': className,
            'grade': c['grade'] ?? 10,
            'homeroomTeacher': c['homeroomTeacher']?['fullName'] ?? c['homeroomTeacher']?['username'] ?? 'Chưa có',
            'homeroomTeacherId': c['homeroomTeacher']?['_id']?.toString(),
            'studentCount': (c['students'] as List?)?.length ?? c['studentCount'] ?? 0,
            'maleCount': maleCountMap[className] ?? 0,
            'femaleCount': femaleCountMap[className] ?? 0,
            'status': c['isActive'] == true ? 'active' : 'inactive',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredClasses {
    if (_searchController.text.isEmpty) return _classes;
    final query = _searchController.text.toLowerCase();
    return _classes.where((c) => 
      c['name'].toLowerCase().contains(query) || 
      c['homeroomTeacher'].toLowerCase().contains(query)
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildStatsRow(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadClasses,
                    child: _buildClassList(),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClassDialog(context),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm lớp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2196F3)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lớp học Tiếng Anh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text('Quản lý danh sách lớp học', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3F2FD)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm lớp học...',
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
    );
  }

  Widget _buildStatsRow() {
    int totalStudents = _classes.fold(0, (sum, c) => sum + (c['studentCount'] as int));
    int activeCount = _classes.where((c) => c['status'] == 'active').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMiniStat('Tổng lớp', '${_classes.length}', const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          _buildMiniStat('Học sinh', '$totalStudents', const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          _buildMiniStat('Hoạt động', '$activeCount', const Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildClassList() {
    final classes = _filteredClasses;
    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 80, color: const Color(0xFF94A3B8).withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Không tìm thấy lớp học', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: classes.length,
      itemBuilder: (context, index) => _buildClassCard(classes[index]),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    bool isActive = classData['status'] == 'active';
    const Color primaryBlue = Color(0xFF2196F3);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3F2FD)),
        boxShadow: [BoxShadow(color: primaryBlue.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showClassDetail(context, classData),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: primaryBlue.withValues(alpha: 0.3), blurRadius: 10)],
                      ),
                      child: Center(child: Text(classData['name'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text('Lớp ${classData['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: isActive ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : const Color(0xFFFF9800).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(isActive ? 'Hoạt động' : 'Tạm đóng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Khối ${classData['grade']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 18, color: Color(0xFF2196F3)),
                      const SizedBox(width: 10),
                      Expanded(child: Text('GV: ${classData['homeroomTeacher']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                      _buildStudentStat(Icons.groups_rounded, '${classData['studentCount']}', 'HS', const Color(0xFF2196F3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentStat(IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      ],
    );
  }

  void _showClassDetail(BuildContext context, Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ClassDetailSheet(
        classData: classData,
        onEdit: () {
          Navigator.pop(ctx);
          _showEditClassDialog(context, classData);
        },
        onDelete: () {
          Navigator.pop(ctx);
          _confirmDeleteClass(context, classData);
        },
      ),
    );
  }

  void _confirmDeleteClass(BuildContext context, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa lớp ${classData['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
              final result = await ApiService.deleteClass(classData['id']);
              if (!mounted) return;
              Navigator.pop(context);
              if (result['error'] != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${result['error']}'), backgroundColor: const Color(0xFFEF4444)));
              } else {
                await _loadClasses();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa lớp ${classData['name']}'), backgroundColor: const Color(0xFF4CAF50)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditClassDialog(BuildContext context, Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddClassSheet(
        classToEdit: classData,
        onSave: (updatedData) async {
          Navigator.pop(ctx);
          showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
          final result = await ApiService.updateClass(classData['id'], {'name': updatedData['name'], 'grade': updatedData['grade']});
          if (!mounted) return;
          Navigator.pop(context);
          if (result['error'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${result['error']}'), backgroundColor: const Color(0xFFEF4444)));
          } else {
            await _loadClasses();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật lớp ${updatedData['name']}'), backgroundColor: const Color(0xFF4CAF50)));
          }
        },
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddClassSheet(
        onSave: (classData) async {
          Navigator.pop(ctx);
          showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
          final result = await ApiService.createClass(name: classData['name'], grade: classData['grade']);
          if (!mounted) return;
          Navigator.pop(context);
          if (result['error'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${result['error']}'), backgroundColor: const Color(0xFFEF4444)));
          } else {
            await _loadClasses();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã tạo lớp ${classData['name']}'), backgroundColor: const Color(0xFF4CAF50)));
          }
        },
      ),
    );
  }
}

class _ClassDetailSheet extends StatelessWidget {
  final Map<String, dynamic> classData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ClassDetailSheet({required this.classData, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3);
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: primaryBlue.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.class_rounded, color: Colors.white, size: 40)),
                        const SizedBox(height: 16),
                        Text('Lớp ${classData['name']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('Khối ${classData['grade']}', style: const TextStyle(fontSize: 14, color: Colors.white)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildHeaderStat('${classData['studentCount']}', 'Học sinh'),
                            Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                            _buildHeaderStat('${classData['maleCount']}', 'Nam'),
                            Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                            _buildHeaderStat('${classData['femaleCount']}', 'Nữ'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTeacherCard(classData),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildQuickAction(context, Icons.list_alt_rounded, 'Danh sách HS', const Color(0xFF2196F3), () { 
                        Navigator.pop(context); 
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StudentManagementScreen(className: classData['name']))); 
                      })),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(context, Icons.bar_chart_rounded, 'Thống kê', const Color(0xFF10B981), () {})),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_rounded), label: const Text('Sửa lớp'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF59E0B), side: const BorderSide(color: Color(0xFFF59E0B)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_rounded), label: const Text('Xóa lớp'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0))),
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

  Widget _buildHeaderStat(String value, String label) {
    return Column(children: [Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)))]);
  }

  Widget _buildTeacherCard(Map<String, dynamic> classData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3F2FD))),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]), borderRadius: BorderRadius.circular(14)), child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 26))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Giáo viên chủ nhiệm', style: TextStyle(fontSize: 12, color: Colors.grey)), Text(classData['homeroomTeacher'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]))
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color))]),
      ),
    );
  }
}

class _AddClassSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? classToEdit;
  const _AddClassSheet({required this.onSave, this.classToEdit});
  @override
  State<_AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<_AddClassSheet> {
  late TextEditingController _nameController;
  late int _selectedGrade;
  final List<int> _grades = [10, 11, 12];
  bool get isEditing => widget.classToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classToEdit?['name'] ?? '');
    _selectedGrade = widget.classToEdit?['grade'] ?? 10;
  }

  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: (isEditing ? const Color(0xFF2196F3) : const Color(0xFFF59E0B)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(isEditing ? Icons.edit_rounded : Icons.add_rounded, color: isEditing ? const Color(0xFF2196F3) : const Color(0xFFF59E0B), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEditing ? 'Sửa lớp học' : 'Thêm Lớp học mới', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const Text('Điền thông tin lớp học', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
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
                  const Text('Tên lớp *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'VD: 10A4, 11B2...', prefixIcon: const Icon(Icons.class_rounded, color: Color(0xFF94A3B8)),
                      filled: true, fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Khối *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: DropdownButton<int>(
                      value: _selectedGrade, isExpanded: true, underline: const SizedBox(),
                      items: _grades.map((g) => DropdownMenuItem(value: g, child: Text('Khối $g'))).toList(),
                      onChanged: (value) => setState(() => _selectedGrade = value!),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên lớp!'), backgroundColor: Color(0xFFEF4444)));
                          return;
                        }
                        widget.onSave({'name': _nameController.text.trim(), 'grade': _selectedGrade});
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      child: Text(isEditing ? 'CẬP NHẬT' : 'THÊM LỚP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}
