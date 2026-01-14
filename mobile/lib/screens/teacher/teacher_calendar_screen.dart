import 'package:flutter/material.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/services/teacher_service.dart';
import 'package:intl/intl.dart';

class TeacherCalendarScreen extends StatefulWidget {
  const TeacherCalendarScreen({super.key});

  @override
  State<TeacherCalendarScreen> createState() => _TeacherCalendarScreenState();
}

class _TeacherCalendarScreenState extends State<TeacherCalendarScreen> {
  List<Assignment> _allEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Sử dụng TeacherService để lấy danh sách bài kiểm tra (Exams) 
      // vì ApiService.getAssignments đã bị xóa theo yêu cầu của bạn.
      final data = await TeacherService.getFilteredAssignments(null);
      if (!mounted) return;
      setState(() {
        _allEvents = data;
        // Sắp xếp theo ngày deadline (endTime)
        _allEvents.sort((a, b) => a.deadline.compareTo(b.deadline));
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Lịch Giảng Dạy', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSimpleCalendarHeader(),
                Expanded(
                  child: _allEvents.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _allEvents.length,
                          itemBuilder: (context, index) {
                            final event = _allEvents[index];
                            return _buildEventTile(event);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSimpleCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM, yyyy').format(DateTime.now()),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.calendar_month_rounded, color: Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Lịch nhắc nhở các mốc thời gian bài kiểm tra',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(Assignment event) {
    final bool isPast = event.deadline.isBefore(DateTime.now());
    const Color color = Colors.purple; // Luôn là màu tím vì chỉ còn bài kiểm tra

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(event.deadline),
                  style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('MMM').format(event.deadline),
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bài kiểm tra ${event.unit}', // Hiển thị 15 Phút hoặc 45 Phút
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isPast)
            const Badge(label: Text('ĐÃ QUA'), backgroundColor: Color(0xFF64748B))
          else
            const Icon(Icons.notifications_active_rounded, color: color, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 15),
          const Text('Hiện không có bài kiểm tra nào sắp tới', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
