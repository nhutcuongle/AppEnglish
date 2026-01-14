import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/student/my_submissions_screen.dart';
import 'package:apptienganh10/screens/student/unit_list_tab.dart';
import 'package:apptienganh10/screens/student/exam_list_screen.dart';

class StudentDashboardTab extends StatefulWidget {
  final Function(int)? onTabSelected;
  const StudentDashboardTab({super.key, this.onTabSelected});

  @override
  State<StudentDashboardTab> createState() => _StudentDashboardTabState();
}

class _StudentDashboardTabState extends State<StudentDashboardTab> {
  String studentName = "Học sinh";
  String className = "Đang tải...";
  bool isLoading = true;

  // Stats variables
  int totalLessons = 0;
  int totalVocab = 0;
  String averageGrade = "-";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchStats();
  }


  Future<void> _fetchStats() async {
    try {
      // 1. Fetch Units/Lessons (Stats: Lessons)
      final unitsResult = await ApiService.getPublicUnits();
      List<dynamic> units = [];
      if (unitsResult is List) {
        units = unitsResult;
      }
      
      int lessonsCount = units.length;
      
      // 2. Count Vocab (Client-side scraping)
      // Loop through first few units to estimate or count
      int vocabCount = 0;
      int limit = lessonsCount > 5 ? 5 : lessonsCount; // Limit to 5 units to save requests
      
      List<Future<void>> futures = [];
      for (int i = 0; i < limit; i++) {
        var u = units[i];
        if (u['_id'] != null) {
          futures.add(() async {
            try {
              final lessons = await ApiService.getLessonsByUnit(u['_id']);
              for (var l in lessons) {
                if (l['_id'] != null) {
                  final vocabs = await ApiService.getVocabularyByLesson(l['_id']);
                  vocabCount += vocabs.length;
                }
              }
            } catch (e) {
              debugPrint('Error fetching vocab for unit ${u['_id']}: $e');
            }
          }());
        }
      }
      
      await Future.wait(futures);
      
      // If we limited the loop, extrapolate
      if (lessonsCount > limit && limit > 0) {
        vocabCount = (vocabCount / limit * lessonsCount).round();
      }

      // 3. Fetch Submissions for Score
      final submissions = await ApiService.getMySubmissions();
      double totalScore = 0;
      int count = 0;
      for (var sub in submissions) {
         if (sub['totalScore'] != null) {
           totalScore += (sub['totalScore'] as num).toDouble();
           count++;
         }
      }
      
      String grade = "-";
      if (count > 0) {
        double avg = totalScore / count; 
        if (avg >= 9) grade = "A+";
        else if (avg >= 8) grade = "A";
        else if (avg >= 7) grade = "B";
        else if (avg >= 5) grade = "C";
        else grade = "D";
      }

      if (mounted) {
        setState(() {
          totalLessons = lessonsCount;
          totalVocab = vocabCount;
          averageGrade = grade;
        });
      }
    } catch (e) {
      debugPrint("Stats error: $e");
    }
  }

  Future<void> _fetchProfile() async {
    // ========== MOCK DATA ĐỂ TEST ==========
    // Bỏ comment phần này để test với dữ liệu giả
    /*
    if (mounted) {
      setState(() {
        studentName = "Nguyễn Văn A";
        className = "Lớp 10A1";
        isLoading = false;
      });
    }
    return;
    */
    // ========================================

    try {
      final response = await ApiService.getProfile();
      debugPrint('=== PROFILE RESPONSE ===');
      debugPrint(response.toString());
      
      if (mounted) {
        setState(() {
          var data = response['data'] ?? response;
          studentName = data['fullName']?.toString().isNotEmpty == true 
              ? data['fullName'] 
              : (data['username'] ?? "Học sinh");
          
          // Lấy thông tin lớp
          if (data['class'] != null) {
            debugPrint('=== CLASS DATA: ${data['class']} (${data['class'].runtimeType}) ===');
            if (data['class'] is Map) {
              className = data['class']['name'] ?? "Chưa có lớp";
            } else if (data['class'] is String) {
              final classId = data['class'].toString();
              if (classId.length == 24) {
                _fetchClassName(classId);
                className = "Đang tải...";
              } else {
                className = classId;
              }
            } else {
              className = data['class'].toString();
            }
          } else {
            className = "Chưa có lớp";
          }
          
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('=== PROFILE ERROR: $e ===');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchClassName(String classId) async {
    try {
      // Gọi API lấy danh sách lớp và tìm lớp có ID phù hợp
      final classes = await ApiService.getClasses();
      for (var c in classes) {
        if (c['_id'] == classId) {
          if (mounted) {
            setState(() {
              className = c['name'] ?? 'Chưa có tên';
            });
          }
          return;
        }
      }
      // Nếu không tìm thấy, hiển thị thông báo
      if (mounted) setState(() => className = "Chưa có lớp");
    } catch (e) {
      if (mounted) setState(() => className = "Lỗi tải");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildStatsCard(),
              const SizedBox(height: 35),
              _buildSectionHeader('Công cụ học tập', 'Khám phá ngay 🚀'),
              const SizedBox(height: 20),
              _buildTaskGrid(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chào buổi sáng,', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            Text('$studentName 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text('Lớp: $className', style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w500)),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 2),
          ),
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.blueAccent, size: 30),
          ),
        ),
      ],
    );
  }



  // ... (existing _fetchProfile logic) ...

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Bài học', '$totalLessons', Icons.auto_stories_rounded),
              _buildStatItem('Từ vựng', '$totalVocab', Icons.translate_rounded),
              _buildStatItem('Thành tích', averageGrade, Icons.stars_rounded),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 15),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white70, size: 14),
              SizedBox(width: 8),
              Text('Hãy cố gắng học mỗi ngày nhé!', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }


  Widget _buildTaskGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.15,
      children: [
        _buildQuickTool('Unit', Icons.auto_stories_rounded, Colors.purple, onTap: () {
          widget.onTabSelected?.call(1); // Chuyển sang tab Unit (index 1)
        }),
        _buildQuickTool('Hồ sơ', Icons.person_rounded, Colors.teal, onTap: () {
          widget.onTabSelected?.call(3); // Chuyển sang tab tài khoản (index 3)
        }),
        _buildQuickTool('Bài kiểm tra', Icons.quiz_rounded, Colors.orange, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamListScreen()));
        }),
        _buildQuickTool('Bài tập', Icons.assignment_rounded, Colors.green, onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const MySubmissionsScreen()));
        }),
      ],
    );
  }

  Widget _buildQuickTool(String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }
}
