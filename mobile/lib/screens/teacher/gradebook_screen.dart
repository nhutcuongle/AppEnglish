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
  List<Student> _students = [];
  List<Assignment> _exams = [];
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
      final studentsData = await ApiService.getMyStudents();
      // Chuyển sang lấy danh sách Bài kiểm tra (Exams)
      final examsData = await ApiService.getTeacherExams();
      final submissionsData = await ApiService.getSubmissions();

      final List<Student> students = studentsData.map((e) => Student.fromJson(e)).toList();
      final List<Assignment> exams = examsData.map((e) => Assignment.fromJson(e)).toList();
      final List<Submission> submissions = submissionsData.map((e) => Submission.fromJson(e)).toList();

      Map<String, Map<String, double?>> matrix = {};
      for (var student in students) {
        matrix[student.id] = {};
        for (var exam in exams) {
          try {
            // Tìm bài nộp của học sinh này cho bài thi này
            final sub = submissions.firstWhere(
              (s) => s.studentId == student.id && s.examId == exam.id,
            );
            matrix[student.id]![exam.id] = sub.score;
          } catch (e) {
             matrix[student.id]![exam.id] = null;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _students = students;
        _exams = exams;
        _gradeMatrix = matrix;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sổ Điểm Điện Tử', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _isLoading
          ? ShimmerWidgets.tableShimmer()
          : _students.isEmpty || _exams.isEmpty
              ? _buildEmptyState()
              : _buildGradeTable(),
    );
  }

  Widget _buildGradeTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          columnSpacing: 30,
          horizontalMargin: 20,
          columns: [
            const DataColumn(label: Text('Họ và Tên', style: TextStyle(fontWeight: FontWeight.bold))),
            ..._exams.map((e) => DataColumn(
              label: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  e.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )),
          ],
          rows: _students.map((student) {
            return DataRow(cells: [
              DataCell(
                Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                onTap: () => _viewStudentDetails(student),
              ),
              ..._exams.map((exam) {
                final score = _gradeMatrix[student.id]?[exam.id];
                return DataCell(
                  Center(
                    child: Text(
                      score != null ? score.toString() : '-',
                      style: TextStyle(
                        color: score == null ? Colors.grey : (score >= 5 ? Colors.green : Colors.red),
                        fontWeight: FontWeight.bold,
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
    );
  }

  void _viewStudentDetails(Student student) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hồ sơ học sinh: ${student.name}')));
  }

  void _quickGrade(Student student, Assignment exam) {
    final scoreController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chấm điểm: ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(exam.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Điểm số (0-10)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final score = double.tryParse(scoreController.text);
              if (score != null && score >= 0 && score <= 10) {
                try {
                  // Lấy bài nộp theo examId và studentId
                  final subs = await ApiService.getSubmissions(examId: exam.id, studentId: student.id);
                  if (subs.isNotEmpty) {
                    final subId = subs.first['_id'];
                    await ApiService.gradeSubmission(subId, score);
                    if (!mounted) return;
                    Navigator.pop(context);
                    _loadData(); // Tải lại bảng điểm
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Học sinh chưa làm bài kiểm tra này!')));
                     Navigator.pop(context);
                  }
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            child: const Text('Lưu'),
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
          const Text('Chưa có đủ dữ liệu học sinh hoặc bài kiểm tra', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
