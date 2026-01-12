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
  List<Assignment> _assignments = [];
  Map<String, Map<String, double?>> _gradeMatrix = {}; // studentId -> {assignmentId -> score}
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final studentsData = await ApiService.getStudents();
      final assignmentsData = await ApiService.getAssignments();
      final submissionsData = await ApiService.getSubmissions();

      final List<Student> students = studentsData.map((e) => Student.fromJson(e)).toList();
      final List<Assignment> assignments = assignmentsData.map((e) => Assignment.fromJson(e)).toList();
      final List<Submission> submissions = submissionsData.map((e) => Submission.fromJson(e)).toList();

      Map<String, Map<String, double?>> matrix = {};
      for (var student in students) {
        matrix[student.id] = {};
        for (var assignment in assignments) {
          try {
            final sub = submissions.firstWhere(
              (s) => s.studentId == student.id && s.assignmentId == assignment.id,
            );
            matrix[student.id]![assignment.id] = sub.score;
          } catch (e) {
             matrix[student.id]![assignment.id] = null;
          }
        }
      }

      setState(() {
        _students = students;
        _assignments = assignments;
        _gradeMatrix = matrix;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading gradebook: $e");
      setState(() => _isLoading = false);
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
          : _students.isEmpty || _assignments.isEmpty
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
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
          columnSpacing: 30,
          horizontalMargin: 20,
          columns: [
            const DataColumn(label: Text('Họ và Tên', style: TextStyle(fontWeight: FontWeight.bold))),
            ..._assignments.map((a) => DataColumn(
              label: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  a.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )).toList(),
          ],
          rows: _students.map((student) {
            return DataRow(cells: [
              DataCell(
                Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                onTap: () => _viewStudentDetails(student),
              ),
              ..._assignments.map((assignment) {
                final score = _gradeMatrix[student.id]?[assignment.id];
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
                  onTap: () => _quickGrade(student, assignment),
                );
              }).toList(),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _viewStudentDetails(Student student) {
    // Chuyển hướng hoặc mở popup xem hồ sơ học sinh
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hồ sơ học sinh: ${student.name}')));
  }

  void _quickGrade(Student student, Assignment assignment) {
    final scoreController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chấm điểm: ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                // Find submission ID if exists, OR create new submission (backend implementation dependant)
                // For now, assume teacher grades an existing submission or backend creates one.
                // Since ApiService.gradeSubmission requires ID, we must find the submission First.
                // Simplified flow: We need submission ID.
                try {
                  // Fetch specific submission to get ID
                  final subs = await ApiService.getSubmissions(assignmentId: assignment.id, studentId: student.id);
                  if (subs.isNotEmpty) {
                    final subId = subs.first['_id'];
                    await ApiService.gradeSubmission(subId, score);
                    Navigator.pop(context);
                    _loadData(); // Reload
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Học sinh chưa nộp bài này!')));
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
          const Text('Chưa có đủ dữ liệu học sinh hoặc bài tập', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
