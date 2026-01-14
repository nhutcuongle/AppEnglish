import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/student/lesson_detail_screen.dart';

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

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  List<dynamic> lessons = []; // Danh sách bài học từ API
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
      ),
      body: Column(
        children: [
          // Danh sách Lesson thực tế từ API
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Bài học trong bài",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
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
                        final images = lesson['images'] as List<dynamic>? ?? [];
                        final hasImage = images.isNotEmpty && images[0]['url'] != null;
                        final lessonType = lesson['lessonType'] ?? '';
                        
                        // Icon theo loại bài học
                        IconData typeIcon = Icons.book;
                        Color typeColor = Colors.blue;
                        if (lessonType == 'listening') {
                          typeIcon = Icons.headphones;
                          typeColor = Colors.orange;
                        } else if (lessonType == 'reading') {
                          typeIcon = Icons.menu_book;
                          typeColor = Colors.purple;
                        } else if (lessonType == 'vocabulary') {
                          typeIcon = Icons.abc;
                          typeColor = Colors.green;
                        } else if (lessonType == 'grammar') {
                          typeIcon = Icons.rule;
                          typeColor = Colors.red;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonDetailScreen(
                                    lessonId: lesson['_id'],
                                    title: lesson['title'] ?? 'Bài học',
                                    lessonType: lessonType,
                                    content: lesson['content'] ?? '',
                                    images: lesson['images'] as List<dynamic>?,
                                    audios: lesson['audios'] as List<dynamic>?,
                                    videos: lesson['videos'] as List<dynamic>?,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ảnh bìa nếu có - nhỏ hơn
                                if (hasImage)
                                  SizedBox(
                                    height: 100,
                                    width: double.infinity,
                                    child: Image.network(
                                      images[0]['url'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image_not_supported, size: 40),
                                      ),
                                    ),
                                  ),
                                // Thông tin bài học
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: typeColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(typeIcon, color: typeColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(lesson['title'] ?? 'Bài học', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: typeColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                lessonType.isNotEmpty ? lessonType[0].toUpperCase() + lessonType.substring(1) : 'Bài học',
                                                style: TextStyle(fontSize: 12, color: typeColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Thay icon 3 chấm thành mũi tên hoặc xóa
                                      const Icon(Icons.chevron_right, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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