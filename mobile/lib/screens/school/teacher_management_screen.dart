import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() => _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _teachers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getTeachers();
      setState(() {
        _teachers = data.map<Map<String, dynamic>>((t) {
          return {
            'id': t['_id']?.toString() ?? '',
            'name': (t['fullName'] != null && t['fullName'].toString().isNotEmpty) ? t['fullName'] : (t['username']?.toString() ?? 'Chưa có tên'),
            'username': t['username']?.toString() ?? '',
            'email': t['email']?.toString() ?? '',
            'phone': t['phone']?.toString() ?? '',
            'classes': t['classes'] ?? [],
            'status': t['isDisabled'] == true ? 'inactive' : 'active',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading teachers: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTeachers {
    if (_searchController.text.isEmpty) return _teachers;
    final query = _searchController.text.toLowerCase();
    return _teachers.where((t) => 
      (t['name'] ?? '').toLowerCase().contains(query) || 
      (t['email'] ?? '').toLowerCase().contains(query)
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
              : _buildTeacherList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTeacherDialog(context),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Thêm GV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                const Text('Giáo viên Tiếng Anh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
            hintText: 'Tìm kiếm giáo viên...',
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
    int activeCount = _teachers.where((t) => t['status'] == 'active').length;
    int inactiveCount = _teachers.where((t) => t['status'] == 'inactive').length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMiniStat('Tổng cộng', '${_teachers.length}', const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          _buildMiniStat('Đang dạy', '$activeCount', const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          _buildMiniStat('Tạm nghỉ', '$inactiveCount', const Color(0xFFFF9800)),
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

  Widget _buildTeacherList() {
    final teachers = _filteredTeachers;
    
    if (teachers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: const Color(0xFF94A3B8).withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy giáo viên',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: teachers.length,
      itemBuilder: (context, index) => _buildTeacherCard(teachers[index]),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    bool isActive = teacher['status'] == 'active';
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
          onTap: () => _showTeacherDetail(context, teacher),
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
                          _getInitials(teacher['name'] ?? 'GV'),
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
                                child: Text(teacher['name'] ?? 'Chưa có tên', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
                                    Text(isActive ? 'Đang dạy' : 'Tạm nghỉ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_stories, size: 12, color: Color(0xFF2196F3)),
                                    SizedBox(width: 4),
                                    Text('Tiếng Anh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.class_rounded, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text('${(teacher['classes'] as List? ?? []).length} lớp', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                                teacher['email'] ?? 'Chưa có email',
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
                            teacher['phone'] ?? 'Chưa có SĐT',
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

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Toán học':
        return const Color(0xFF3B82F6);
      case 'Tiếng Anh':
        return const Color(0xFF8B5CF6);
      case 'Vật lý':
        return const Color(0xFFEC4899);
      case 'Hóa học':
        return const Color(0xFF10B981);
      case 'Sinh học':
        return const Color(0xFF14B8A6);
      case 'Ngữ văn':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'GV';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'GV';
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  void _showTeacherDetail(BuildContext context, Map<String, dynamic> teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TeacherDetailSheet(
        teacher: teacher,
        onEdit: () {
          Navigator.pop(ctx);
          _showEditTeacherDialog(context, teacher);
        },
        onDelete: () {
          Navigator.pop(ctx);
          _showDeleteConfirmDialog(context, teacher);
        },
      ),
    );
  }

  void _showEditTeacherDialog(BuildContext context, Map<String, dynamic> teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TeacherFormSheet(
        teacher: teacher,
        onSave: (updatedTeacher) async {
          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator()),
          );
          
          final Map<String, dynamic> updateData = {
            'username': updatedTeacher['username'],
            'fullName': updatedTeacher['name'],
            'email': updatedTeacher['email'],
            'phone': updatedTeacher['phone'],
            'classes': updatedTeacher['classes'],
            'isDisabled': updatedTeacher['status'] == 'active' ? false : true,
          };
          if (updatedTeacher['password'] != null && updatedTeacher['password'].toString().isNotEmpty) {
            updateData['password'] = updatedTeacher['password'];
          }

          final result = await ApiService.updateTeacher(updatedTeacher['id'], updateData);
          
          Navigator.pop(context); // Close loading
          Navigator.pop(ctx); // Close form
          
          if (result['error'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi cập nhật: ${result['error']}'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
            );
          } else {
             setState(() {
              int index = _teachers.indexWhere((t) => t['id'] == teacher['id']);
              if (index != -1) _teachers[index] = updatedTeacher;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Đã cập nhật thông tin giáo viên!'), backgroundColor: const Color(0xFF2196F3), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Map<String, dynamic> teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.warning_rounded, color: Color(0xFFEF4444)), SizedBox(width: 12), Text('Xác nhận xóa')]),
        content: Text('Bạn có chắc muốn xóa giáo viên "${teacher['name']}"?\n\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog first to show loading if needed, or just handle async
              
               // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator()),
              );

              final result = await ApiService.deleteTeacher(teacher['id']);
              
              Navigator.pop(context); // Close loading

              if (result['error'] != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi xóa: ${result['error']}'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
                );
              } else {
                setState(() => _teachers.removeWhere((t) => t['id'] == teacher['id']));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Đã xóa giáo viên!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
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

  void _showAddTeacherDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TeacherFormSheet(
        onSave: (newTeacher) async {
          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator()),
          );
          
          // Call API to create teacher
          final result = await ApiService.createTeacher(
            username: newTeacher['username'] ?? newTeacher['name'],
            email: (newTeacher['email'] != null && newTeacher['email'].toString().isNotEmpty) 
                ? newTeacher['email'] 
                : '${newTeacher['username']}@school.edu.vn',
            password: newTeacher['password'] ?? '123456',
            fullName: newTeacher['name'],
            phone: newTeacher['phone'],
            classes: newTeacher['classes'] != null ? List<String>.from(newTeacher['classes']) : [],
          );
          
          Navigator.pop(context); // Close loading
          Navigator.pop(ctx); // Close form
          
          if (result['error'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${result['error']}'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
            );
          } else {
            // Reload from API to get correct data
            await _loadTeachers();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã tạo tài khoản GV: ${newTeacher['username']}'), backgroundColor: const Color(0xFF4CAF50), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
            );
          }

        },
      ),
    );
  }
}

class _TeacherDetailSheet extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeacherDetailSheet({required this.teacher, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3);
    List<String> classes = teacher['classes'] != null ? List<String>.from(teacher['classes']) : [];
    
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
                    child: Center(child: Text(_getInitials(teacher['name'] ?? 'GV'), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 20),
                  Text(teacher['name'] ?? 'Chưa có tên', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Giáo viên Tiếng Anh', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoSection('Thông tin liên hệ', [
                    _buildInfoRow(Icons.email_rounded, 'Email', teacher['email'] ?? 'Chưa có'),
                    _buildInfoRow(Icons.phone_rounded, 'Điện thoại', teacher['phone'] ?? 'Chưa có'),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection('Lớp phụ trách (${classes.length})', [
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: classes.map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBDEFB))),
                        child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                      )).toList(),
                    ),
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
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Toán học':
        return const Color(0xFF3B82F6);
      case 'Tiếng Anh':
        return const Color(0xFF8B5CF6);
      case 'Vật lý':
        return const Color(0xFFEC4899);
      case 'Hóa học':
        return const Color(0xFF10B981);
      case 'Sinh học':
        return const Color(0xFF14B8A6);
      case 'Ngữ văn':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'GV';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'GV';
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

class _TeacherFormSheet extends StatefulWidget {
  final Map<String, dynamic>? teacher; // null for add, non-null for edit
  final Function(Map<String, dynamic>) onSave;

  const _TeacherFormSheet({this.teacher, required this.onSave});

  @override
  State<_TeacherFormSheet> createState() => _TeacherFormSheetState();
}

class _TeacherFormSheetState extends State<_TeacherFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  List<String> _selectedClasses = [];
  List<String> _allClasses = [];
  bool _isLoadingClasses = true;

  bool get isEditing => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher?['name'] ?? '');
    _usernameController = TextEditingController(text: widget.teacher?['username'] ?? '');
    _phoneController = TextEditingController(text: widget.teacher?['phone'] ?? '');
    _passwordController = TextEditingController();
    if (widget.teacher != null) {
      _selectedClasses = List<String>.from(widget.teacher!['classes'] ?? []);
    }
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final classesData = await ApiService.getClasses();
      if (mounted) {
        setState(() {
          _allClasses = classesData.map<String>((e) => e['name'].toString()).toList();
          _allClasses.sort(); // Sort classes alphabetically
          _isLoadingClasses = false;
        });
      }
    } catch (e) {
      print('Error loading classes: $e');
      if (mounted) setState(() => _isLoadingClasses = false);
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
                      Text(isEditing ? 'Chỉnh sửa Giáo viên' : 'Thêm Giáo viên mới', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text(isEditing ? 'Cập nhật thông tin' : 'Tạo tài khoản giáo viên', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
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
                  // Account info section for editing
                  // Only show readonly info if username exists
                  if (isEditing && widget.teacher?['username'] != null && widget.teacher?['username'].toString().isNotEmpty == true) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [Icon(Icons.account_circle_rounded, color: Color(0xFF2196F3), size: 20), SizedBox(width: 8), Text('Thông tin tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3)))]),
                          const SizedBox(height: 12),
                          Row(children: [const Text('Tên đăng nhập: ', style: TextStyle(color: Color(0xFF64748B))), Text(widget.teacher?['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                          const SizedBox(height: 4),
                          Row(children: [const Text('Mật khẩu: ', style: TextStyle(color: Color(0xFF64748B))), Text(widget.teacher?['password'] ?? '******', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildTextField(_nameController, 'Họ và tên *', 'Nhập họ và tên', Icons.person_rounded),
                  const SizedBox(height: 16),
                  // Allow editing username if creating NEW or if existing username is MISSING (recovery)
                  if (!isEditing || (widget.teacher?['username'] == null || widget.teacher?['username'].toString().isEmpty == true)) ...[
                    _buildTextField(_usernameController, 'Tên đăng nhập *', 'gv_nguyenvana', Icons.account_circle_rounded),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Mật khẩu *', 'Nhập mật khẩu', Icons.lock_rounded),
                    const SizedBox(height: 16),
                  ],
                  _buildTextField(_phoneController, 'Số điện thoại', '0912 345 678', Icons.phone_rounded, TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildClassSelector(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveTeacher,
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

  void _saveTeacher() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Vui lòng nhập họ tên!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
      );
      return;
    }
    // Check validation:
    // 1. Creating new: Need username & password
    // 2. Editing check: If username is missing, need username & password to restore it
    bool needsAuthInfo = !isEditing || (widget.teacher?['username'] == null || widget.teacher?['username'].toString().isEmpty == true);
    
    if (needsAuthInfo && (_usernameController.text.isEmpty || _passwordController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Vui lòng nhập tên đăng nhập và mật khẩu!'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)),
      );
      return;
    }
    
    final teacher = {
      'id': widget.teacher?['id'] ?? '',
      'name': _nameController.text,
      'username': (!isEditing || (widget.teacher?['username'] == null || widget.teacher?['username'].toString().isEmpty == true)) 
          ? _usernameController.text 
          : (widget.teacher?['username'] ?? ''),
      'password': (!isEditing || (widget.teacher?['password'] == null || widget.teacher?['password'].toString().isEmpty == true))
          ? _passwordController.text // Use input if creating or restoring
          : (isEditing ? (widget.teacher?['password'] ?? '') : _passwordController.text), // Logic for password will be handled in onSave conditionally anyway
      'email': widget.teacher?['email'] ?? '',
      'phone': _phoneController.text,
      'classes': _selectedClasses.isEmpty ? ['10A1'] : _selectedClasses,
      'status': widget.teacher?['status'] ?? 'active',
    };
    widget.onSave(teacher);
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
        const Text('Lớp phụ trách', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        _isLoadingClasses
            ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
            : Wrap(
                spacing: 8, runSpacing: 8,
                children: _allClasses.map((c) {
            bool isSelected = _selectedClasses.contains(c);
            return GestureDetector(
              onTap: () => setState(() => isSelected ? _selectedClasses.remove(c) : _selectedClasses.add(c)),
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

