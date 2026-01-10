import 'package:flutter/material.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final List<Map<String, dynamic>> _units = [
    {
      'id': '1',
      'name': 'Unit 1: Family Life',
      'description': 'Vocabulary and grammar about family',
      'videos': [
        {'id': 'v1', 'title': 'Family Members Vocabulary', 'duration': '10:25'},
        {'id': 'v2', 'title': 'Present Simple Tense', 'duration': '15:30'},
      ],
      'exercises': [
        {'id': 'e1', 'title': 'Vocabulary Quiz', 'questions': 10},
        {'id': 'e2', 'title': 'Grammar Practice', 'questions': 15},
      ],
    },
    {
      'id': '2',
      'name': 'Unit 2: Your Body and You',
      'description': 'Health and body parts vocabulary',
      'videos': [
        {'id': 'v3', 'title': 'Body Parts', 'duration': '12:00'},
        {'id': 'v4', 'title': 'Health Problems', 'duration': '14:15'},
      ],
      'exercises': [
        {'id': 'e3', 'title': 'Body Parts Matching', 'questions': 12},
      ],
    },
    {
      'id': '3',
      'name': 'Unit 3: Music',
      'description': 'Musical instruments and genres',
      'videos': [
        {'id': 'v5', 'title': 'Music Vocabulary', 'duration': '11:45'},
      ],
      'exercises': [
        {'id': 'e4', 'title': 'Listening Practice', 'questions': 8},
        {'id': 'e5', 'title': 'Music Genres Quiz', 'questions': 10},
      ],
    },
    {
      'id': '4',
      'name': 'Unit 4: For a Better Community',
      'description': 'Community service and volunteering',
      'videos': [],
      'exercises': [],
    },
    {
      'id': '5',
      'name': 'Unit 5: Inventions',
      'description': 'Famous inventions and inventors',
      'videos': [],
      'exercises': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildUnitList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUnitDialog(context),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm Unit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bài học Tiếng Anh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Khối 10 • 5 Units', style: TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _units.length,
      itemBuilder: (context, index) => _buildUnitCard(_units[index], index),
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit, int index) {
    int videoCount = (unit['videos'] as List).length;
    int exerciseCount = (unit['exercises'] as List).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3F2FD)),
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showUnitDetail(context, unit),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(unit['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Text(unit['description'], style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatChip(Icons.play_circle_rounded, '$videoCount Video', const Color(0xFF2196F3)),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.quiz_rounded, '$exerciseCount Bài tập', const Color(0xFF4CAF50)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  void _showUnitDetail(BuildContext context, Map<String, dynamic> unit) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => _UnitDetailScreen(
      unit: unit,
      onUpdate: (updatedUnit) {
        setState(() {
          int index = _units.indexWhere((u) => u['id'] == unit['id']);
          if (index != -1) _units[index] = updatedUnit;
        });
      },
      onDelete: () {
        setState(() => _units.removeWhere((u) => u['id'] == unit['id']));
        Navigator.pop(context);
      },
    )));
  }

  void _showAddUnitDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.add_rounded, color: Color(0xFF2196F3), size: 24)),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('Thêm Unit mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(controller: nameController, decoration: InputDecoration(labelText: 'Tên Unit', hintText: 'Unit 6: ...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 16),
                    TextField(controller: descController, decoration: InputDecoration(labelText: 'Mô tả', hintText: 'Nội dung chính...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            setState(() {
                              _units.add({
                                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                                'name': nameController.text,
                                'description': descController.text,
                                'videos': [],
                                'exercises': [],
                              });
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Đã thêm Unit mới!'), backgroundColor: const Color(0xFF4CAF50), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: const Text('Thêm Unit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitDetailScreen extends StatefulWidget {
  final Map<String, dynamic> unit;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onDelete;

  const _UnitDetailScreen({required this.unit, required this.onUpdate, required this.onDelete});

  @override
  State<_UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<_UnitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _videos;
  late List<Map<String, dynamic>> _exercises;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _videos = List<Map<String, dynamic>>.from(widget.unit['videos'] ?? []);
    _exercises = List<Map<String, dynamic>>.from(widget.unit['exercises'] ?? []);
  }

  void _updateParent() {
    widget.onUpdate({
      ...widget.unit,
      'videos': _videos,
      'exercises': _exercises,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVideoList(),
                  _buildExerciseList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tabController.index == 0 ? _showAddVideoDialog() : _showAddExerciseDialog(),
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.unit['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(widget.unit['description'], style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.white),
              onPressed: () => _showDeleteConfirm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(12)),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.play_circle_rounded, size: 20), SizedBox(width: 8), Text('Video (${_videos.length})')])),
          Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.quiz_rounded, size: 20), SizedBox(width: 8), Text('Bài tập (${_exercises.length})')])),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    if (_videos.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.videocam_off_rounded, size: 80, color: const Color(0xFF94A3B8).withOpacity(0.5)), const SizedBox(height: 16), const Text('Chưa có video bài giảng', style: TextStyle(fontSize: 16, color: Color(0xFF64748B)))]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: _videos.length,
      itemBuilder: (context, index) => _buildVideoCard(_videos[index], index),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3F2FD)), boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28)),
        title: Text(video['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        subtitle: Text(video['duration'], style: const TextStyle(color: Color(0xFF64748B))),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 20), SizedBox(width: 8), Text('Sửa')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
          ],
          onSelected: (value) {
            if (value == 'edit') _showEditVideoDialog(video, index);
            if (value == 'delete') { setState(() => _videos.removeAt(index)); _updateParent(); }
          },
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_exercises.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.assignment_late_rounded, size: 80, color: const Color(0xFF94A3B8).withOpacity(0.5)), const SizedBox(height: 16), const Text('Chưa có bài tập', style: TextStyle(fontSize: 16, color: Color(0xFF64748B)))]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: _exercises.length,
      itemBuilder: (context, index) => _buildExerciseCard(_exercises[index], index),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3F2FD)), boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF388E3C)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 28)),
        title: Text(exercise['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        subtitle: Text('${exercise['questions']} câu hỏi', style: const TextStyle(color: Color(0xFF64748B))),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 20), SizedBox(width: 8), Text('Sửa')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
          ],
          onSelected: (value) {
            if (value == 'edit') _showEditExerciseDialog(exercise, index);
            if (value == 'delete') { setState(() => _exercises.removeAt(index)); _updateParent(); }
          },
        ),
      ),
    );
  }

  void _showAddVideoDialog() {
    final titleController = TextEditingController();
    final durationController = TextEditingController();
    _showFormDialog('Thêm Video', titleController, durationController, 'Tiêu đề video', 'Thời lượng (vd: 10:25)', () {
      if (titleController.text.isNotEmpty) {
        setState(() => _videos.add({'id': DateTime.now().millisecondsSinceEpoch.toString(), 'title': titleController.text, 'duration': durationController.text.isEmpty ? '00:00' : durationController.text}));
        _updateParent();
        Navigator.pop(context);
      }
    });
  }

  void _showEditVideoDialog(Map<String, dynamic> video, int index) {
    final titleController = TextEditingController(text: video['title']);
    final durationController = TextEditingController(text: video['duration']);
    _showFormDialog('Sửa Video', titleController, durationController, 'Tiêu đề video', 'Thời lượng', () {
      if (titleController.text.isNotEmpty) {
        setState(() { _videos[index] = {...video, 'title': titleController.text, 'duration': durationController.text}; });
        _updateParent();
        Navigator.pop(context);
      }
    });
  }

  void _showAddExerciseDialog() {
    final titleController = TextEditingController();
    final questionsController = TextEditingController();
    _showFormDialog('Thêm Bài tập', titleController, questionsController, 'Tiêu đề bài tập', 'Số câu hỏi', () {
      if (titleController.text.isNotEmpty) {
        setState(() => _exercises.add({'id': DateTime.now().millisecondsSinceEpoch.toString(), 'title': titleController.text, 'questions': int.tryParse(questionsController.text) ?? 10}));
        _updateParent();
        Navigator.pop(context);
      }
    });
  }

  void _showEditExerciseDialog(Map<String, dynamic> exercise, int index) {
    final titleController = TextEditingController(text: exercise['title']);
    final questionsController = TextEditingController(text: '${exercise['questions']}');
    _showFormDialog('Sửa Bài tập', titleController, questionsController, 'Tiêu đề bài tập', 'Số câu hỏi', () {
      if (titleController.text.isNotEmpty) {
        setState(() { _exercises[index] = {...exercise, 'title': titleController.text, 'questions': int.tryParse(questionsController.text) ?? 10}; });
        _updateParent();
        Navigator.pop(context);
      }
    });
  }

  void _showFormDialog(String title, TextEditingController ctrl1, TextEditingController ctrl2, String label1, String label2, VoidCallback onSave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          height: 320,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            children: [
              Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              Padding(padding: const EdgeInsets.all(20), child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(controller: ctrl1, decoration: InputDecoration(labelText: label1, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 16),
                    TextField(controller: ctrl2, decoration: InputDecoration(labelText: label2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onSave, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.warning_rounded, color: Color(0xFFEF4444)), SizedBox(width: 12), Text('Xóa Unit')]),
        content: Text('Bạn có chắc muốn xóa "${widget.unit['name']}"?\n\nTất cả video và bài tập sẽ bị xóa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(onPressed: () { Navigator.pop(ctx); widget.onDelete(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)), child: const Text('Xóa', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
