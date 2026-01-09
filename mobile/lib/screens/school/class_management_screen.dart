import 'package:flutter/material.dart';
import 'package:apptienganh10/screens/school/student_management_screen.dart';
import 'package:apptienganh10/screens/school/timetable_screen.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Dữ liệu mẫu cho lớp học khối 10
  final List<Map<String, dynamic>> _classes = [
    {'id': '1', 'name': '10A1', 'homeroomTeacher': 'Trần Thị Bình', 'studentCount': 42, 'maleCount': 20, 'femaleCount': 22, 'room': 'Phòng 101', 'schedule': 'Sáng', 'status': 'active'},
    {'id': '2', 'name': '10A2', 'homeroomTeacher': 'Nguyễn Văn An', 'studentCount': 40, 'maleCount': 18, 'femaleCount': 22, 'room': 'Phòng 102', 'schedule': 'Sáng', 'status': 'active'},
    {'id': '3', 'name': '10A3', 'homeroomTeacher': 'Lê Thị Hương', 'studentCount': 38, 'maleCount': 16, 'femaleCount': 22, 'room': 'Phòng 103', 'schedule': 'Sáng', 'status': 'active'},
    {'id': '4', 'name': '10A4', 'homeroomTeacher': 'Phạm Minh Tuấn', 'studentCount': 41, 'maleCount': 19, 'femaleCount': 22, 'room': 'Phòng 104', 'schedule': 'Sáng', 'status': 'active'},
    {'id': '5', 'name': '10A5', 'homeroomTeacher': 'Hoàng Thị Mai', 'studentCount': 39, 'maleCount': 17, 'femaleCount': 22, 'room': 'Phòng 105', 'schedule': 'Chiều', 'status': 'active'},
    {'id': '6', 'name': '10A6', 'homeroomTeacher': 'Vũ Đức Anh', 'studentCount': 40, 'maleCount': 18, 'femaleCount': 22, 'room': 'Phòng 106', 'schedule': 'Chiều', 'status': 'active'},
    {'id': '7', 'name': '10A7', 'homeroomTeacher': 'Đỗ Thị Lan', 'studentCount': 42, 'maleCount': 20, 'femaleCount': 22, 'room': 'Phòng 107', 'schedule': 'Chiều', 'status': 'active'},
    {'id': '8', 'name': '10A8', 'homeroomTeacher': 'Bùi Văn Hùng', 'studentCount': 38, 'maleCount': 16, 'femaleCount': 22, 'room': 'Phòng 108', 'schedule': 'Chiều', 'status': 'active'},
  ];

  List<Map<String, dynamic>> get _filteredClasses {
    if (_searchController.text.isEmpty) return _classes;
    final query = _searchController.text.toLowerCase();
    return _classes.where((c) => c['name'].toLowerCase().contains(query) || c['homeroomTeacher'].toLowerCase().contains(query) || c['room'].toLowerCase().contains(query)).toList();
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
            _buildSearchBar(),
            _buildStatsRow(),
            Expanded(child: _buildClassList()),
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
                const Text('Lớp học Tiếng Anh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
    int morningCount = _classes.where((c) => c['schedule'] == 'Sáng').length;
    int afternoonCount = _classes.where((c) => c['schedule'] == 'Chiều').length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMiniStat('Tổng lớp', '${_classes.length}', const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          _buildMiniStat('Học sinh', '$totalStudents', const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          _buildMiniStat('Ca sáng', '$morningCount', const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          _buildMiniStat('Ca chiều', '$afternoonCount', const Color(0xFFFF9800)),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
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
            Icon(Icons.class_outlined, size: 80, color: const Color(0xFF94A3B8).withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy lớp học',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
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
        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
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
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
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
                                decoration: BoxDecoration(color: isActive ? const Color(0xFF4CAF50).withOpacity(0.1) : const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(isActive ? 'Hoạt động' : 'Tạm đóng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                                child: const Text('Khối 10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(classData['room'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 18, color: Color(0xFF2196F3)),
                          const SizedBox(width: 10),
                          const Text('GVCN: ', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                          Expanded(child: Text(classData['homeroomTeacher'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Tiếng Anh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStudentStat(Icons.groups_rounded, '${classData['studentCount']}', 'HS', const Color(0xFF2196F3)),
                          const SizedBox(width: 12),
                          _buildStudentStat(Icons.male_rounded, '${classData['maleCount']}', 'Nam', const Color(0xFF1976D2)),
                          const SizedBox(width: 12),
                          _buildStudentStat(Icons.female_rounded, '${classData['femaleCount']}', 'Nữ', const Color(0xFFE91E63)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: classData['schedule'] == 'Sáng' ? const Color(0xFF4CAF50).withOpacity(0.1) : const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded, size: 14, color: classData['schedule'] == 'Sáng' ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)),
                                const SizedBox(width: 4),
                                Text(classData['schedule'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: classData['schedule'] == 'Sáng' ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))),
                              ],
                            ),
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

  Widget _buildStudentStat(IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'Khối 10':
        return const Color(0xFF10B981);
      case 'Khối 11':
        return const Color(0xFF8B5CF6);
      case 'Khối 12':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFFF59E0B);
    }
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
      case 'Lịch sử':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6366F1);
    }
  }

  void _showClassDetail(BuildContext context, Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClassDetailSheet(classData: classData),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddClassSheet(),
    );
  }
}

class _ClassDetailSheet extends StatelessWidget {
  final Map<String, dynamic> classData;

  const _ClassDetailSheet({required this.classData});

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
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.class_rounded, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text('Lớp ${classData['name']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('Khối 10 • ${classData['room']}', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildHeaderStat('${classData['studentCount']}', 'Học sinh'),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
                            _buildHeaderStat('${classData['maleCount']}', 'Nam'),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
                            _buildHeaderStat('${classData['femaleCount']}', 'Nữ'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection('Giáo viên chủ nhiệm', [_buildTeacherCard(classData)]),
                  const SizedBox(height: 24),
                  _buildInfoSection('Thông tin lớp học', [
                    _buildInfoRow(Icons.location_on_rounded, 'Phòng học', classData['room']),
                    _buildInfoRow(Icons.schedule_rounded, 'Ca học', classData['schedule']),
                    _buildInfoRow(Icons.calendar_today_rounded, 'Năm học', '2025-2026'),
                  ]),
                  const SizedBox(height: 24),
                  // Quick actions
                  _buildInfoSection('Thao tác nhanh', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(context, Icons.list_alt_rounded, 'Danh sách HS', const Color(0xFF2196F3), () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => StudentManagementScreen(className: classData['name'])));
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(context, Icons.bar_chart_rounded, 'Thống kê', const Color(0xFF10B981), () {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(context, Icons.calendar_month_rounded, 'Thời khóa biểu', const Color(0xFFF59E0B), () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TimetableScreen(className: classData['name'])));
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(context, Icons.assignment_rounded, 'Điểm số', const Color(0xFF8B5CF6), () {}),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 30),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Chỉnh sửa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF59E0B),
                            side: const BorderSide(color: Color(0xFFF59E0B)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.delete_rounded),
                          label: const Text('Xóa lớp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
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

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> classData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3F2FD)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(classData['homeroomTeacher'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                const Text('Giáo viên Tiếng Anh', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2196F3), size: 20),
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

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'Khối 10':
        return const Color(0xFF10B981);
      case 'Khối 11':
        return const Color(0xFF8B5CF6);
      case 'Khối 12':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

class _AddClassSheet extends StatefulWidget {
  const _AddClassSheet();

  @override
  State<_AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<_AddClassSheet> {
  String _selectedGrade = 'Khối 10';
  String _selectedSchedule = 'Sáng';
  final List<String> _grades = ['Khối 10', 'Khối 11', 'Khối 12'];
  final List<String> _schedules = ['Sáng', 'Chiều'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_rounded, color: Color(0xFFF59E0B), size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thêm Lớp học mới',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Điền thông tin lớp học',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Tên lớp',
                    hint: 'VD: 10A4, 11B2...',
                    icon: Icons.class_rounded,
                  ),
                  const SizedBox(height: 20),
                  // Grade dropdown
                  _buildDropdown('Khối', _selectedGrade, _grades, (value) {
                    setState(() => _selectedGrade = value!);
                  }),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Phòng học',
                    hint: 'VD: Phòng 101',
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 20),
                  // Schedule dropdown
                  _buildDropdown('Ca học', _selectedSchedule, _schedules, (value) {
                    setState(() => _selectedSchedule = value!);
                  }),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Giáo viên chủ nhiệm',
                    hint: 'Chọn giáo viên',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 30),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Đã thêm lớp học thành công!'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Thêm Lớp học',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
