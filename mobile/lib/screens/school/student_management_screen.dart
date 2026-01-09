import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';

class StudentManagementScreen extends StatefulWidget {
  final String? className;
  const StudentManagementScreen({super.key, this.className});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;



  @override
  void initState() {
    super.initState();
    if (widget.className != null) {
      _searchController.text = widget.className!;
    }
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getStudents();
      setState(() {
        _students = data.map<Map<String, dynamic>>((s) => {
          'id': s['_id']?.toString() ?? '',
          'name': (s['fullName'] != null && s['fullName'].toString().isNotEmpty) ? s['fullName'] : (s['username']?.toString() ?? 'Chưa có tên'),
          'username': s['username']?.toString() ?? '',
          'email': s['email']?.toString() ?? '',
          'phone': s['phone']?.toString() ?? '',
          'classes': s['classes'] ?? [],
          'status': s['isDisabled'] == true ? 'inactive' : 'active',
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading students: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    if (_searchController.text.isEmpty) return _students;
    final query = _searchController.text.toLowerCase();
    final queryUpper = _searchController.text.toUpperCase();
    
    // Check if query is a class name pattern (e.g., 10A1, 10A2...)
    bool isClassSearch = _allClasses().contains(queryUpper);
    
    if (isClassSearch) {
      // Only filter by classes field - exact match
      return _students.where((s) => 
        s['classes'] != null && (s['classes'] as List).contains(queryUpper)
      ).toList();
    }
    
    // General search: match name, email, or classes
    return _students.where((s) => 
      (s['name'] ?? '').toLowerCase().contains(query) || 
      (s['email'] ?? '').toLowerCase().contains(query) ||
      (s['classes'] != null && (s['classes'] as List).any((c) => c.toString().toLowerCase().contains(query)))
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
            Expanded(child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildStudentList()),
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
                const Text('Quản lý Học sinh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Khối 10', style: TextStyle(fontSize: 12, color: Color(0xFF2196F3), fontWeight: FontWeight.w600)),
                ),
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
    );
  }

  Widget _buildStatsRow() {
    final students = _filteredStudents;
    int activeCount = students.where((t) => t['status'] == 'active').length;
    int inactiveCount = students.where((t) => t['status'] == 'inactive').length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMiniStat('Tổng cộng', '${students.length}', const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          _buildMiniStat('Đang học', '$activeCount', const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          _buildMiniStat('Đã nghỉ', '$inactiveCount', const Color(0xFFFF9800)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
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
            Icon(Icons.search_off_rounded, size: 80, color: const Color(0xFF94A3B8).withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy học sinh',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
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
    const Color primaryBlue = Color(0xFF2196F3);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3F2FD)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showStudentDetail(context, student),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(student['name'] ?? 'HS'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(student['name'] ?? 'Chưa có tên', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF4CAF50).withOpacity(0.1) : const Color(0xFFFF9800).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 6, height: 6, decoration: BoxDecoration(color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800), shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text(isActive ? 'Đang học' : 'Đã nghỉ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.class_rounded, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text((student['classes'] as List? ?? []).isNotEmpty ? (student['classes'] as List).first.toString() : 'Chưa xếp lớp', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.email_rounded, size: 16, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                student['email'] ?? 'Chưa có email',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                      const SizedBox(width: 14),
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          Text(
                            student['phone'] ?? 'Chưa có SĐT',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
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

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'HS';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'HS';
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
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
        onSave: (updatedStudent) async {
          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator()),
          );
          
          final Map<String, dynamic> updateData = {
            'username': updatedStudent['username'],
            'fullName': updatedStudent['name'],
            'email': updatedStudent['email'],
            'phone': updatedStudent['phone'],
            'classes': updatedStudent['classes'], // Should be [newClass] only
            'isDisabled': updatedStudent['status'] == 'active' ? false : true,
          };
          if (updatedStudent['password'] != null && updatedStudent['password'].toString().isNotEmpty) {
            updateData['password'] = updatedStudent['password'];
          }

          print('DEBUG: Updating student with classes: ${updateData['classes']}');

          final result = await ApiService.updateStudent(updatedStudent['id'], updateData);
          
          Navigator.pop(context); // Close loading
          Navigator.pop(ctx); // Close form
          
          if (result['error'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi cập nhật: ${result['error']}'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
            );
          } else {
            // Use API response to update local state
            final updatedFromApi = {
              'id': result['_id'] ?? updatedStudent['id'],
              'name': result['fullName'] ?? updatedStudent['name'],
              'username': result['username'] ?? updatedStudent['username'],
              'email': result['email'] ?? updatedStudent['email'],
              'phone': result['phone'] ?? updatedStudent['phone'],
              'classes': result['classes'] ?? updatedStudent['classes'],
              'status': result['isDisabled'] == true ? 'inactive' : 'active',
            };
            print('DEBUG: API returned classes: ${result['classes']}');
            setState(() {
              int index = _students.indexWhere((t) => t['id'] == student['id']);
              if (index != -1) _students[index] = updatedFromApi;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Đã cập nhật thông tin học sinh!'), backgroundColor: const Color(0xFF2196F3), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
            );
          }
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
            onPressed: () async {
              Navigator.pop(ctx); 
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator()),
              );

              final result = await ApiService.deleteStudent(student['id']);
              
              Navigator.pop(context); // Close loading

              if (result['error'] != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi xóa: ${result['error']}'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
                );
              } else {
                setState(() => _students.removeWhere((t) => t['id'] == student['id']));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Đã xóa học sinh!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    String? currentClass;
    int nextIndex = 1;
    
    // Determine current class from search/filter
    String searchText = _searchController.text.trim().toUpperCase();
    if (_allClasses().contains(searchText)) {
      currentClass = searchText;
    } else if (widget.className != null && _allClasses().contains(widget.className)) {
      currentClass = widget.className;
    } else if (_students.isNotEmpty) {
       // Try to infer? No, safety first.
    }

    if (currentClass != null) {
      // Find max index to avoid duplicates (e.g. if 10A102 exists, next should be 10A103)
      int maxIndex = 0;
      for (var s in _students) {
        if (s['classes'] != null && (s['classes'] as List).contains(currentClass)) {
          String u = s['username'] ?? '';
          if (u.startsWith(currentClass)) {
             // Handle both old format (with _) and new format
             String suffix = u.substring(currentClass.length).replaceAll('_', '');
             int? val = int.tryParse(suffix);
             if (val != null && val > maxIndex) maxIndex = val;
          }
        }
      }
      nextIndex = maxIndex + 1;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StudentFormSheet(
        initialClass: currentClass,
        nextIndex: nextIndex,
        onSave: (newStudent) async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator()),
          );
          
          final result = await ApiService.createStudent(
            username: newStudent['username'] ?? newStudent['name'],
            email: (newStudent['email'] != null && newStudent['email'].toString().isNotEmpty) 
                ? newStudent['email'] 
                : '${newStudent['username']}@school.edu.vn',
            password: newStudent['password'] ?? '123456',
            fullName: newStudent['name'],
            phone: newStudent['phone'],
            classes: newStudent['classes'] != null ? List<String>.from(newStudent['classes']) : [],
          );
          
          Navigator.pop(context); // Close loading
          Navigator.pop(ctx); // Close form
          
          if (result['error'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${result['error']}'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
            );
          } else {
            setState(() {
              newStudent['id'] = result['student']?['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
              _students.add(newStudent);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã tạo tài khoản HS: ${newStudent['username']}'), backgroundColor: const Color(0xFF4CAF50), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
            );
          }
        },
      ),
    );
  }

  List<String> _allClasses() {
    return ['10A1', '10A2', '10A3', '10A4', '10A5', '10A6', '10A7', '10A8'];
  }
}


class _StudentDetailSheet extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentDetailSheet({required this.student, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3);
    List<String> classes = student['classes'] != null ? List<String>.from(student['classes']) : [];
    String className = classes.isNotEmpty ? classes.first : 'Chưa xếp lớp';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Center(child: Text(_getInitials(student['name'] ?? 'HS'), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 20),
                  Text(student['name'] ?? 'Chưa có tên', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
                    child: Text('Lớp: $className', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoSection('Thông tin liên hệ', [
                    _buildInfoRow(Icons.email_rounded, 'Email', student['email'] ?? 'Chưa có'),
                    _buildInfoRow(Icons.phone_rounded, 'Điện thoại', student['phone'] ?? 'Chưa có'),
                  ]),
                  const SizedBox(height: 30),
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

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'HS';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'HS';
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
            ],
          ),
        ],
      ),
    );
  }
}


class _StudentFormSheet extends StatefulWidget {
  final Map<String, dynamic>? student; // null for add, non-null for edit
  final Function(Map<String, dynamic>) onSave;
  final String? initialClass;
  final int? nextIndex;

  const _StudentFormSheet({this.student, required this.onSave, this.initialClass, this.nextIndex});

  @override
  State<_StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<_StudentFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  String? _selectedClass;
  
  final List<String> _allClasses = ['10A1', '10A2', '10A3', '10A4', '10A5', '10A6', '10A7', '10A8'];

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?['name'] ?? '');
    _usernameController = TextEditingController(text: widget.student?['username'] ?? '');
    _phoneController = TextEditingController(text: widget.student?['phone'] ?? '');
    _passwordController = TextEditingController();
    
    if (widget.student != null && widget.student!['classes'] != null && (widget.student!['classes'] as List).isNotEmpty) {
      _selectedClass = widget.student!['classes'][0];
    } else if (widget.initialClass != null) {
      _selectedClass = widget.initialClass;
      // Auto generate username if not editing
      if (!isEditing && widget.nextIndex != null) {
        // Format: 10A101 (no underscore)
        String newUsername = '${widget.initialClass}${widget.nextIndex.toString().padLeft(2, '0')}';
        _usernameController.text = newUsername;
        _passwordController.text = newUsername; // Password same as username
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)),
                  child: Icon(isEditing ? Icons.edit_rounded : Icons.person_add_rounded, color: primaryBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEditing ? 'Chỉnh sửa Học sinh' : 'Thêm Học sinh mới', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text(isEditing ? 'Cập nhật thông tin' : 'Tạo tài khoản học sinh', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
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
                   if (isEditing && widget.student?['username'] != null && widget.student?['username'].toString().isNotEmpty == true) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [Icon(Icons.account_circle_rounded, color: Color(0xFF2196F3), size: 20), SizedBox(width: 8), Text('Thông tin tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3)))]),
                          const SizedBox(height: 12),
                          Row(children: [const Text('Tên đăng nhập: ', style: TextStyle(color: Color(0xFF64748B))), Text(widget.student?['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildTextField(_nameController, 'Họ và tên *', 'Nhập họ và tên', Icons.person_rounded),
                  const SizedBox(height: 16),
                  
                  // Only show Username/Password fields if ADDING new user
                  if (!isEditing) ...[
                    _buildTextField(_usernameController, 'Tên đăng nhập *', 'Auto-generated', Icons.account_circle_rounded),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Mật khẩu *', 'Mặc định: 123456', Icons.lock_rounded),
                    const SizedBox(height: 16),
                  ],

                  _buildTextField(_phoneController, 'Số điện thoại', '0912 345 678', Icons.phone_rounded, TextInputType.phone),
                  const SizedBox(height: 16),
                  
                  // Class Selector or Fixed Text
                  if (widget.initialClass != null && !isEditing)
                     Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text('Lớp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                           const SizedBox(height: 8),
                           Row(children: [const Icon(Icons.class_rounded, size: 20, color: Color(0xFF2196F3)), const SizedBox(width: 8), Text(widget.initialClass!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                         ],
                       ),
                     )
                  else
                    _buildClassSelector(),
                    
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Vui lòng nhập họ tên!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
      );
      return;
    }
    
    bool needsAuthInfo = !isEditing || (widget.student?['username'] == null || widget.student?['username'].toString().isEmpty == true);
    
    if (needsAuthInfo && (_usernameController.text.isEmpty || _passwordController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Vui lòng nhập tên đăng nhập và mật khẩu!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
      );
      return;
    }
    
    final student = {
      'id': widget.student?['id'] ?? '',
      'name': _nameController.text,
      'username': (!isEditing || (widget.student?['username'] == null || widget.student?['username'].toString().isEmpty == true)) 
          ? _usernameController.text 
          : (widget.student?['username'] ?? ''),
      'password': (!isEditing || (widget.student?['password'] == null || widget.student?['password'].toString().isEmpty == true))
          ? _passwordController.text 
          : (isEditing ? (widget.student?['password'] ?? '') : _passwordController.text),
      'email': widget.student?['email'] ?? '',
      'phone': _phoneController.text,
      'classes': _selectedClass != null ? [_selectedClass!] : [],
      'status': widget.student?['status'] ?? 'active',
    };
    widget.onSave(student);
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, [TextInputType type = TextInputType.text]) {
    bool isPassword = label.contains('Mật khẩu');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE3F2FD))),
          child: TextField(
            controller: controller,
            keyboardType: type,
            obscureText: isPassword,
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94A3B8)), prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildClassSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lớp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _allClasses.map((c) {
            bool isSelected = _selectedClass == c;
            return GestureDetector(
              onTap: () => setState(() => _selectedClass = c), // Single select
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE3F2FD)),
                ),
                child: Text(c, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF64748B))),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
