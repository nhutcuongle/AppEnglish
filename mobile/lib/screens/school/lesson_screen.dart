import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài học')),
      body: const Center(child: Text('Tính năng quản lý bài học đang phát triển')),
    );
  }
}
