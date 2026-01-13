import 'package:flutter/material.dart';

import '../../services/api_service.dart';

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
  
  // Reuse code from lesson_screen for editing if needed, or just show content
  // Để đơn giản, ta chỉ hiển thị nội dung. Title, Content, Media.

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
    );
  }

  Widget _buildMediaSection(String title, IconData icon, Color color, List<dynamic> urls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color))]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: urls.map((url) => Chip(
            avatar: Icon(Icons.link, size: 16, color: color),
            label: Text(url.toString().split('/').last.length > 20 ? '${url.toString().split('/').last.substring(0, 20)}...' : url.toString().split('/').last, style: TextStyle(fontSize: 12, color: color)),
            backgroundColor: color.withOpacity(0.05),
            side: BorderSide(color: color.withOpacity(0.2)),
          )).toList(),
        ),
      ],
    );
  }
}
