import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'question_management_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final Function(Map<String, dynamic>)? onEdit; // Callback khi sửa xong

  const LessonDetailScreen({super.key, required this.lesson, this.onEdit});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late Map<String, dynamic> _lesson;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _lesson = widget.lesson;
  }

  @override
  Widget build(BuildContext context) {
    final typeMap = {
      'reading': {'label': 'Đọc hiểu', 'color': Colors.purple, 'icon': Icons.chrome_reader_mode},
      'listening': {'label': 'Nghe', 'color': Colors.orange, 'icon': Icons.headphones},
      'speaking': {'label': 'Nói', 'color': Colors.pink, 'icon': Icons.mic},
      'writing': {'label': 'Viết', 'color': Colors.teal, 'icon': Icons.edit_note},
    };
    final type = typeMap[_lesson['lessonType']] ?? {'label': 'Bài học', 'color': Colors.blue, 'icon': Icons.book};
    final color = type['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: Text(_lesson['title']),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(type['icon'] as IconData, size: 16, color: color),
                const SizedBox(width: 8),
                Text(type['label'] as String, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 20),
            
            // Content
            const Text('Nội dung:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Text(
                _lesson['content'] != null && _lesson['content'].toString().isNotEmpty 
                    ? _lesson['content'] 
                    : 'Chưa có nội dung.',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Media Sections
            if ((_lesson['images'] as List?)?.isNotEmpty == true || (_lesson['audios'] as List?)?.isNotEmpty == true || (_lesson['videos'] as List?)?.isNotEmpty == true)
              const Text('Media đính kèm:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
            if ((_lesson['images'] as List?)?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildMediaSection('Hình ảnh', Icons.image, Colors.blue, _lesson['images']),
            ],
            
            if ((_lesson['audios'] as List?)?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildMediaSection('Audio', Icons.audiotrack, Colors.orange, _lesson['audios']),
            ],
            
            if ((_lesson['videos'] as List?)?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildMediaSection('Video', Icons.videocam, Colors.red, _lesson['videos']),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => QuestionManagementScreen(
              lessonId: _lesson['id'],
              lessonTitle: _lesson['title'],
            ),
          ));
        },
        backgroundColor: color,
        icon: const Icon(Icons.quiz, color: Colors.white),
        label: const Text('Câu hỏi', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMediaSection(String title, IconData icon, Color color, List<dynamic> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();

    // Check if handling images to render them
    bool isImage = title == 'Hình ảnh';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color))]),
        const SizedBox(height: 8),
        if (isImage)
          Column(
            children: urls.map((urlItem) {
              String url = '';
              if (urlItem is String) url = urlItem;
              else if (urlItem is Map && urlItem['url'] != null) url = urlItem['url'];

              if (url.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                    loadingBuilder: (ctx, child, process) => process == null ? child : Container(height: 200, color: Colors.grey[100], child: const Center(child: CircularProgressIndicator())),
                  ),
                ),
              );
            }).toList(),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: urls.map((urlItem) {
               String url = '';
               if (urlItem is String) url = urlItem;
               else if (urlItem is Map && urlItem['url'] != null) url = urlItem['url'];
               
               if (url.isEmpty) return const SizedBox.shrink();

               return Chip(
                avatar: Icon(Icons.link, size: 16, color: color),
                label: Text(url.split('/').last.length > 20 ? '${url.split('/').last.substring(0, 20)}...' : url.split('/').last, style: TextStyle(fontSize: 12, color: color)),
                backgroundColor: color.withOpacity(0.05),
                side: BorderSide(color: color.withOpacity(0.2)),
              );
            }).toList(),
          ),
      ],
    );
  }
}
