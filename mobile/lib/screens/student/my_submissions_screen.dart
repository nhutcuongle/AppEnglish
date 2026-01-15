import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:intl/intl.dart';

class MySubmissionsScreen extends StatefulWidget {
  const MySubmissionsScreen({super.key});

  @override
  State<MySubmissionsScreen> createState() => _MySubmissionsScreenState();
}

class _MySubmissionsScreenState extends State<MySubmissionsScreen> {
  List<dynamic> submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    try {
      final data = await ApiService.getMySubmissions();
      if (mounted) {
        setState(() {
          submissions = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử nộp bài"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("Bạn chưa nộp bài tập nào."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    final lessonTitle = sub['lesson']?['title'] ?? 'Bài tập không tên';
                    final score = sub['totalScore'] ?? 0;
                    final dateStr = sub['submittedAt'];
                    String dateDisplay = "";
                    if (dateStr != null) {
                      try {
                        final date = DateTime.parse(dateStr);
                        dateDisplay = DateFormat('dd/MM/yyyy HH:mm').format(date);
                      } catch (_) {}
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: score >= 5 ? Colors.green : Colors.orange,
                          child: Text(score.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(lessonTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Nộp lúc: $dateDisplay"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Xem chi tiết bài nộp (nếu cần)
                           _showDetailDialog(sub);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showDetailDialog(dynamic sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Chi tiết điểm"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tổng điểm: ${sub['totalScore']}"),
            const SizedBox(height: 10),
            if (sub['scores'] != null) ...[
              Text("Từ vựng: ${sub['scores']['vocabulary']}"),
              Text("Ngữ pháp: ${sub['scores']['grammar']}"),
              Text("Đọc: ${sub['scores']['reading']}"),
              Text("Nghe: ${sub['scores']['listening']}"),
            ]
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng"))],
      ),
    );
  }
}
