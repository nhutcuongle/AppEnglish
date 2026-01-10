import 'package:flutter/material.dart';

import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/screens/teacher/add_announcement_screen.dart';
import 'package:apptienganh10/widgets/loading_widgets.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

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
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerWidgets.listShimmer();
          }
          if (snapshot.hasError) return _buildError(snapshot.error.toString());

          final rawData = snapshot.data ?? [];
          final data = rawData.map((e) => Announcement.fromJson(e)).toList();
          
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddAnnouncementScreen(announcementToEdit: item)),
                              );
                              if (result == true) setState(() {});
                            } else if (value == 'delete') {
                              _deleteAnnouncement(item.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, color: Colors.blue), title: Text('Sửa'))),
                            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Xóa'))),
                          ],
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

  Future<void> _deleteAnnouncement(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa thông báo này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteAnnouncement(id);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thông báo')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
