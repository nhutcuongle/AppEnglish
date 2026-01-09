import 'package:flutter/material.dart';
import 'package:apptienganh10/db/mongodb.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/screens/teacher/add_announcement_screen.dart';
import 'package:intl/intl.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Thông báo lớp học', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, color: Colors.blue),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()),
              );
              if (result == true) setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Announcement>>(
        future: MongoDatabase.getAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return _buildError(snapshot.error.toString());

          final data = snapshot.data ?? [];
          if (data.isEmpty) return _buildEmpty();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.campaign_rounded, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.content,
                      style: const TextStyle(color: Color(0xFF636E72), fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text('Chưa có thông báo nào.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildError(String err) {
    return Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red)));
  }
}
