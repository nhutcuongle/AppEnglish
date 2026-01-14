import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';

class UnitDetailScreen extends StatefulWidget {
  final String unitId; // Thêm biến nhận ID
  final String unitName;
  final String unitTitle;

  const UnitDetailScreen({
    super.key,
    required this.unitId, // Yêu cầu ID
    required this.unitName,
    required this.unitTitle,
  });

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> lessons = []; // Danh sách bài học từ API
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLessons(); // Gọi API ngay khi mở trang
  }

  Future<void> _loadLessons() async {
    final data = await ApiService.getLessonsByUnit(widget.unitId);
    if (mounted) {
      setState(() {
        lessons = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unitName),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: "Bài học"),
            Tab(icon: Icon(Icons.video_library), text: "Video"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Phần trên: Nội dung bài học (Sách/Video)
          Expanded(
            flex: 2,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSimpleContent("Nội dung sách giáo khoa cho ${widget.unitName}"),
                _buildSimpleContent("Video bài giảng sẽ hiển thị tại đây"),
              ],
            ),
          ),

          // Phần dưới: Danh sách Lesson thực tế từ API
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("Danh sách bài học (Lessons)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : lessons.isEmpty
                        ? const Center(child: Text("Chưa có dữ liệu bài học"))
                        : ListView.builder(
                      itemCount: lessons.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.play_circle_outline, color: Colors.blue),
                            title: Text(lesson['title'] ?? 'Bài học ${index + 1}'),
                            subtitle: Text("Loại: ${lesson['lessonType'] ?? 'Chưa rõ'}"),
                            onTap: () {
                              // Xử lý khi nhấn vào từng lesson
                            },
                          ),
                        );
                      },
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

  Widget _buildSimpleContent(String text) {
    return Center(child: Text(text, style: const TextStyle(fontSize: 16)));
  }
}