import 'package:flutter/material.dart';
import 'package:apptienganh10/db/mongodb.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/widgets/loading_widgets.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

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
      final studentsData = await MongoDatabase.getStudents();
      final assignmentsData = await MongoDatabase.getAssignments();
      final submissionsData = await MongoDatabase.getSubmissions();

      final List<Submission> submissions = submissionsData
          .map((s) => Submission.fromJson(s))
          .toList();

      Map<String, Map<String, double?>> matrix = {};
      for (var student in studentsData) {
        matrix[student.id.oid] = {};
        for (var assignment in assignmentsData) {
          // Tìm bài nộp của học sinh này cho bài tập này
          final sub = submissions.firstWhere(
            (s) => s.studentId.oid == student.id.oid && s.assignmentId.oid == assignment.id.oid,
            orElse: () => Submission(
              id: mongo.ObjectId(),
              assignmentId: assignment.id,
              studentId: student.id,
              content: '',
              submittedAt: DateTime.now(),
            ),
          );
          matrix[student.id.oid]![assignment.id.oid] = sub.score;
        }
      }

      setState(() {
        _students = studentsData;
        _assignments = assignmentsData;
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
                final score = _gradeMatrix[student.id.oid]?[assignment.id.oid];
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
    // Trong thực tế sẽ mở GradeSubmissionScreen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chấm điểm ${assignment.title} cho ${student.name}')));
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
