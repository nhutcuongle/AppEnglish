import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/screens/teacher/submission_detail_view_screen.dart';
import 'package:apptienganh10/widgets/audio_player_widget.dart';
import 'package:apptienganh10/widgets/media_preview_dialog.dart';
import 'package:intl/intl.dart';

class SchoolGradebookScreen extends StatefulWidget {
  const SchoolGradebookScreen({super.key});

  @override
  State<SchoolGradebookScreen> createState() => _SchoolGradebookScreenState();
}

class _SchoolGradebookScreenState extends State<SchoolGradebookScreen> {
  int _currentStep = 0; // 0: Unit, 1: Lesson, 2: Class, 3: Scores
  
  String? _selectedUnitId;
  String? _selectedUnitTitle;
  
  String? _selectedLessonId;
  String? _selectedLessonTitle;
  
  String? _selectedClassId;
  String? _selectedClassName;

  List<dynamic> _units = [];
  List<dynamic> _lessons = [];
  List<dynamic> _classes = [];
  List<dynamic> _scores = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() => _isLoading = true);
    final units = await ApiService.getTeacherUnits();
    setState(() {
      _units = units;
      _isLoading = false;
    });
  }

  Future<void> _loadLessons(String unitId) async {
    setState(() => _isLoading = true);
    final lessons = await ApiService.getLessonsByUnit(unitId);
    setState(() {
      _lessons = lessons;
      _isLoading = false;
    });
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    final classes = await ApiService.getTeacherClasses();
    setState(() {
      _classes = classes;
      _isLoading = false;
    });
  }

  Future<void> _loadScores(String lessonId, String classId) async {
    setState(() => _isLoading = true);
    // Note: Filtering by class via API
    final allScores = await ApiService.getScoresByLesson(lessonId, classId: classId);
    
    // Get students in this class to ensure we show everyone
    final studentsInClass = await ApiService.getStudentsByClassForTeacher(classId);
    
    List<Map<String, dynamic>> combinedData = [];
    for (var student in studentsInClass) {
      final submission = (allScores as List).cast<Map<String, dynamic>>().firstWhere(
        (s) => s['user'] != null && (s['user']['_id'] ?? s['user']) == student['_id'],
        orElse: () => {},
      );
      
      combinedData.add({
        'student': student,
        'submission': submission.isEmpty ? null : submission,
      });
    }

    setState(() {
      _scores = combinedData;
      _isLoading = false;
    });
  }

  Future<void> _showAssignmentSettings() async {
    if (_selectedLessonId == null || _selectedClassId == null) return;

    setState(() => _isLoading = true);
    final settings = await ApiService.getAssignmentSettings(_selectedLessonId!, classId: _selectedClassId);
    setState(() => _isLoading = false);

    DateTime? deadline = settings != null && settings['deadline'] != null 
        ? DateTime.parse(settings['deadline']) 
        : null;
    final descController = TextEditingController(text: settings?['description'] ?? '');
    bool isPublished = settings?['isPublished'] ?? true;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cài đặt Giao bài', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              const Text('Hạn nộp bài', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: deadline ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(deadline ?? DateTime.now()),
                    );
                    if (pickedTime != null) {
                      setModalState(() {
                        deadline = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(deadline == null ? 'Chưa đặt hạn nộp' : DateFormat('dd/MM/yyyy HH:mm').format(deadline!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Hướng dẫn/Mô tả', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: 'Nhập hướng dẫn cho học sinh...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Công khai bài tập', style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: isPublished,
                    onChanged: (val) => setModalState(() => isPublished = val),
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    final res = await ApiService.createOrUpdateAssignment({
                      'lessonId': _selectedLessonId,
                      'classId': _selectedClassId,
                      'deadline': deadline?.toIso8601String(),
                      'description': descController.text,
                      'isPublished': isPublished,
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật giao bài thành công!')));
                    }
                  },
                  child: const Text('LƯU CÀI ĐẶT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _onUnitSelected(dynamic unit) {
    setState(() {
      _selectedUnitId = unit['_id'];
      _selectedUnitTitle = unit['title'];
      _currentStep = 1;
    });
    _loadLessons(unit['_id']);
  }

  void _onLessonSelected(dynamic lesson) {
    setState(() {
      _selectedLessonId = lesson['_id'];
      _selectedLessonTitle = lesson['title'];
      _currentStep = 2;
    });
    _loadClasses();
  }

  void _onClassSelected(dynamic cls) {
    setState(() {
      _selectedClassId = cls['_id'];
      _selectedClassName = cls['name'];
      _currentStep = 3;
    });
    _loadScores(_selectedLessonId!, cls['_id']);
  }

  void _goBack() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        leading: _currentStep > 0 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack) : null,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildCurrentStep(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Unit', 'Bài học', 'Lớp', 'Điểm'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.blue : (isActive ? Colors.blue.withOpacity(0.2) : Colors.grey[200]),
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(color: Colors.blue.shade100, width: 4) : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : (isActive ? Colors.blue : Colors.grey[500]),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: index < _currentStep ? Colors.blue : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 0: return 'Chọn Unit';
      case 1: return 'Chọn Bài học';
      case 2: return 'Chọn Lớp học';
      case 3: return 'Điểm: $_selectedLessonTitle';
      default: return 'Quản lý bài nộp';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildUnitList();
      case 1: return _buildLessonList();
      case 2: return _buildClassList();
      case 3: return _buildScoresList();
      default: return const SizedBox();
    }
  }

  Widget _buildUnitList() {
    if (_units.isEmpty) return _buildEmptyState('Không có Unit nào.');
    return ListView.builder(
      itemCount: _units.length,
      itemBuilder: (ctx, i) {
        final unit = _units[i];
        final imageUrl = unit['image'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Hero(
              tag: imageUrl ?? unit['_id'],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.blue.withOpacity(0.1),
                  child: imageUrl != null && imageUrl.toString().isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.folder, color: Colors.blue),
                        )
                      : const Icon(Icons.folder, color: Colors.blue),
                ),
              ),
            ),
            title: Text(unit['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155))),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(unit['description'] ?? 'Không có mô tả', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), shape: BoxShape.circle),
              child: const Icon(Icons.chevron_right, color: Colors.blue, size: 20),
            ),
            onTap: () => _onUnitSelected(unit),
          ),
        );
      },
    );
  }

  Widget _buildLessonList() {
    if (_lessons.isEmpty) return _buildEmptyState('Không có bài học nào trong Unit này.');
    return ListView.builder(
      itemCount: _lessons.length,
      itemBuilder: (ctx, i) {
        final lesson = _lessons[i];
        final images = lesson['images'] as List? ?? [];
        String? imageUrl;
        if (images.isNotEmpty) {
          final first = images.first;
          imageUrl = first is Map ? first['url'] : first.toString();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _onLessonSelected(lesson),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  GestureDetector(
                    onTap: () => MediaPreviewDialog.show(context, imageUrl!),
                    child: Stack(
                      children: [
                        Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                          top: 12, right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getLessonColor(lesson['lessonType']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getLessonIcon(lesson['lessonType']), color: _getLessonColor(lesson['lessonType']), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lesson['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
                            const SizedBox(height: 4),
                            Text(_getLessonLabel(lesson['lessonType']), style: TextStyle(color: _getLessonColor(lesson['lessonType']), fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                if ((lesson['audios'] as List?)?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GestureDetector(
                      onTap: () {}, // Prevent card tap
                      child: AudioPlayerWidget(
                        url: (lesson['audios'] as List).first is Map 
                            ? (lesson['audios'] as List).first['url']
                            : (lesson['audios'] as List).first.toString(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }


  Color _getLessonColor(String? type) {
    switch (type) {
      case 'vocabulary': return Colors.green;
      case 'grammar': return Colors.blue;
      case 'reading': return Colors.purple;
      case 'listening': return Colors.orange;
      case 'speaking': return Colors.pink;
      case 'writing': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  IconData _getLessonIcon(String? type) {
    switch (type) {
      case 'vocabulary': return Icons.abc;
      case 'grammar': return Icons.menu_book;
      case 'reading': return Icons.chrome_reader_mode;
      case 'listening': return Icons.headphones;
      case 'speaking': return Icons.mic;
      case 'writing': return Icons.edit_note;
      default: return Icons.school;
    }
  }

  String _getLessonLabel(String? type) {
    switch (type) {
      case 'vocabulary': return 'Từ vựng';
      case 'grammar': return 'Ngữ pháp';
      case 'reading': return 'Đọc hiểu';
      case 'listening': return 'Nghe';
      case 'speaking': return 'Nói';
      case 'writing': return 'Viết';
      default: return type ?? 'Bình thường';
    }
  }

  Widget _buildClassList() {
    if (_classes.isEmpty) return _buildEmptyState('Không tìm thấy lớp học nào của bạn.');
    return ListView.builder(
      itemCount: _classes.length,
      itemBuilder: (ctx, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: const Icon(Icons.group, color: Colors.blue),
          ),
          title: Text(_classes[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          subtitle: Text('Khối: ${_classes[i]['grade']}', style: TextStyle(color: Colors.grey[600])),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          onTap: () => _onClassSelected(_classes[i]),
        ),
      ),
    );
  }

  Widget _buildScoresList() {
    if (_scores.isEmpty) return _buildEmptyState('Chưa có học sinh nào trong lớp này.');
    
    return ListView.builder(
      itemCount: _scores.length,
      itemBuilder: (ctx, i) {
        final data = _scores[i];
        final student = data['student'];
        final submission = data['submission'];
        
        if (i == 0) {
           return Column(
             children: [
               _buildAssignmentInfoCard(),
               const SizedBox(height: 16),
               _buildStudentTile(student, submission),
             ],
           );
        }
        
        return _buildStudentTile(student, submission);
      },
    );
  }

  Widget _buildAssignmentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trạng thái giao bài', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Quản lý thời hạn và hướng dẫn', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAssignmentSettings,
                icon: const Icon(Icons.settings_suggest_rounded, color: Colors.blue),
                tooltip: 'Cài đặt giao bài',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(dynamic student, dynamic submission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Text((student['fullName'] ?? '?')[0].toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
        title: Text(student['fullName'] ?? student['username'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        subtitle: Text(submission == null ? 'Chưa làm bài' : 'Đã nộp bài', style: TextStyle(color: submission == null ? Colors.orange : Colors.green, fontSize: 13, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (submission != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (submission['totalScore'] >= 5 ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${submission['totalScore']}',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                    color: submission['totalScore'] >= 5 ? Colors.green[700] : Colors.red[700]
                  ),
                ),
              )
            else
              const Text('-', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: submission != null ? () => _viewDetail(submission, student['fullName'] ?? student['username']) : null,
      ),
    );
  }

  void _viewDetail(dynamic submission, String studentName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmissionDetailViewScreen(
          submissionId: submission['_id'],
          studentName: studentName,
          lessonTitle: _selectedLessonTitle!,
        ),
      ),
    );
  }
}
