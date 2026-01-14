import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/widgets/loading_widgets.dart';

class GradebookScreen extends StatefulWidget {
  const GradebookScreen({super.key});

  @override
  State<GradebookScreen> createState() => _GradebookScreenState();
}

class _GradebookScreenState extends State<GradebookScreen> {
  List<ClassInfo> _classes = [];
  List<Student> _allStudents = [];
  List<Assignment> _allExams = [];
  Map<String, Map<String, double?>> _gradeMatrix = {}; // studentId -> {examId -> score}
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getTeacherClasses(),
        ApiService.getMyStudents(),
        ApiService.getTeacherExams(),
        ApiService.getSubmissions(),
      ]);

      final List<ClassInfo> classes = (results[0] as List).map((e) => ClassInfo.fromJson(e)).toList();
      final List<Student> students = (results[1] as List).map((e) => Student.fromJson(e)).toList();
      final List<Assignment> exams = (results[2] as List).map((e) => Assignment.fromJson(e)).toList();
      final List<Submission> submissions = (results[3] as List).map((e) => Submission.fromJson(e)).toList();

      Map<String, Map<String, double?>> matrix = {};
      for (var student in students) {
        matrix[student.id] = {};
        for (var exam in exams) {
          try {
            final sub = submissions.firstWhere(
              (s) => s.studentId == student.id && s.examId == exam.id,
              orElse: () => throw Exception('Not found'),
            );
            matrix[student.id]![exam.id] = sub.score;
          } catch (e) {
             matrix[student.id]![exam.id] = null;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _classes = classes;
        _allStudents = students;
        _allExams = exams;
        _gradeMatrix = matrix;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gradebook error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Sổ Điểm Điện Tử', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.sync_rounded, color: Colors.blueAccent)),
        ],
      ),
      body: _isLoading
          ? ShimmerWidgets.tableShimmer()
          : _classes.isEmpty
              ? _buildEmptyState()
              : _buildGroupedGradebook(),
    );
  }

  Widget _buildGroupedGradebook() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final cls = _classes[index];
        final classStudents = _allStudents.where((s) => s.classId == cls.id).toList();
        final classExams = _allExams.where((e) => e.classId == cls.id).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: index == 0,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.grid_view_rounded, color: Colors.teal, size: 22),
              ),
              title: Text(
                'Lớp: ${cls.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B)),
              ),
              subtitle: Text(
                '${classStudents.length} học sinh • ${classExams.length} bài kiểm tra',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              childrenPadding: const EdgeInsets.all(0),
              children: [
                if (classStudents.isEmpty || classExams.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Chưa có dữ liệu cho lớp này', style: TextStyle(color: Colors.grey))),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      columnSpacing: 25,
                      horizontalMargin: 16,
                      columns: [
                        const DataColumn(label: Text('Học sinh', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                        ...classExams.map((e) => DataColumn(
                          label: Tooltip(
                            message: e.title,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 80),
                              child: Text(
                                e.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        )),
                      ],
                      rows: classStudents.map((student) {
                        return DataRow(cells: [
                          DataCell(
                            Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                          ),
                          ...classExams.map((exam) {
                            final score = _gradeMatrix[student.id]?[exam.id];
                            return DataCell(
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: score == null ? Colors.transparent : (score >= 5 ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    score != null ? score.toString() : '-',
                                    style: TextStyle(
                                      color: score == null ? Colors.grey : (score >= 5 ? Colors.green : Colors.red),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () => _quickGrade(student, exam),
                            );
                          }).toList(),
                        ]);
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _quickGrade(Student student, Assignment exam) {
    final scoreController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chấm điểm nhanh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${student.name} - ${exam.title}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        content: TextField(
          controller: scoreController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nhập điểm (0-10)',
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final score = double.tryParse(scoreController.text);
              if (score != null && score >= 0 && score <= 10) {
                try {
                  final subs = await ApiService.getSubmissions(examId: exam.id, studentId: student.id);
                  if (subs.isNotEmpty) {
                    final subId = subs.first['_id'];
                    await ApiService.gradeSubmission(subId, score);
                    if (!mounted) return;
                    Navigator.pop(context);
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Học sinh chưa nộp bài!')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Lưu điểm'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 15),
          const Text('Bạn chưa có lớp học hoặc bài kiểm tra nào.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
