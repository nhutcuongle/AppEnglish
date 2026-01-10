import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  final String? className; // Optional: if provided, only show schedule for this class
  
  const TimetableScreen({super.key, this.className});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late String _selectedClass;
  
  final List<String> _classes = ['10A1', '10A2', '10A3', '10A4', '10A5', '10A6', '10A7', '10A8'];
  final List<String> _days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
  
  // Thời khóa biểu Tiếng Anh cho từng lớp
  final Map<String, List<Map<String, dynamic>>> _englishSchedule = {
    '10A1': [
      {'day': 1, 'periods': '1-2', 'time': '07:00 - 08:35', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 101'},
      {'day': 2, 'periods': '3', 'time': '08:50 - 09:35', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 101'},
      {'day': 3, 'periods': '3-4', 'time': '08:50 - 10:25', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 101'},
      {'day': 4, 'periods': '3', 'time': '08:50 - 09:35', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 101'},
      {'day': 5, 'periods': '1', 'time': '07:00 - 07:45', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 101'},
      {'day': 6, 'periods': '2', 'time': '07:50 - 08:35', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 101'},
    ],
    '10A2': [
      {'day': 1, 'periods': '3-4', 'time': '08:50 - 10:25', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 102'},
      {'day': 2, 'periods': '1-2', 'time': '07:00 - 08:35', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 102'},
      {'day': 4, 'periods': '1', 'time': '07:00 - 07:45', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 102'},
      {'day': 5, 'periods': '3-4', 'time': '08:50 - 10:25', 'teacher': 'Trần Thị Bình', 'room': 'Phòng 102'},
    ],
    '10A3': [
      {'day': 1, 'periods': '1', 'time': '07:00 - 07:45', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 103'},
      {'day': 2, 'periods': '4-5', 'time': '09:40 - 11:15', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 103'},
      {'day': 3, 'periods': '2', 'time': '07:50 - 08:35', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 103'},
      {'day': 5, 'periods': '2-3', 'time': '07:50 - 09:35', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 103'},
      {'day': 6, 'periods': '1-2', 'time': '07:00 - 08:35', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 103'},
    ],
    '10A4': [
      {'day': 1, 'periods': '4-5', 'time': '09:40 - 11:15', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 104'},
      {'day': 3, 'periods': '1-2', 'time': '07:00 - 08:35', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 104'},
      {'day': 4, 'periods': '3', 'time': '08:50 - 09:35', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 104'},
      {'day': 6, 'periods': '3-4', 'time': '08:50 - 10:25', 'teacher': 'Nguyễn Văn An', 'room': 'Phòng 104'},
    ],
    '10A5': [
      {'day': 2, 'periods': '1-2', 'time': '07:00 - 08:35', 'teacher': 'Lê Thị Hương', 'room': 'Phòng 105'},
      {'day': 3, 'periods': '4-5', 'time': '09:40 - 11:15', 'teacher': 'Lê Thị Hương', 'room': 'Phòng 105'},
      {'day': 5, 'periods': '1', 'time': '07:00 - 07:45', 'teacher': 'Lê Thị Hương', 'room': 'Phòng 105'},
      {'day': 6, 'periods': '2-3', 'time': '07:50 - 09:35', 'teacher': 'Lê Thị Hương', 'room': 'Phòng 105'},
    ],
    '10A6': [
      {'day': 1, 'periods': '2-3', 'time': '07:50 - 09:35', 'teacher': 'Lê Thị Hương', 'room': 'Phòng 106'},
      {'day': 3, 'periods': '1', 'time': '07:00 - 07:45', 'teacher': 'Lê Thị Hương', 'room': 'Phòng 106'},
      {'day': 4, 'periods': '4-5', 'time': '09:40 - 11:15', 'teacher': 'Lê Thị Hương', 'room': 'Phòng 106'},
      {'day': 5, 'periods': '3-4', 'time': '08:50 - 10:25', 'teacher': 'Lê Thị Hương', 'room': 'Phòng 106'},
    ],
    '10A7': [
      {'day': 1, 'periods': '1-2', 'time': '07:00 - 08:35', 'teacher': 'Phạm Văn Đức', 'room': 'Phòng 107'},
      {'day': 2, 'periods': '3-4', 'time': '08:50 - 10:25', 'teacher': 'Phạm Văn Đức', 'room': 'Phòng 107'},
      {'day': 4, 'periods': '1-2', 'time': '07:00 - 08:35', 'teacher': 'Phạm Văn Đức', 'room': 'Phòng 107'},
      {'day': 6, 'periods': '4', 'time': '09:40 - 10:25', 'teacher': 'Phạm Văn Đức', 'room': 'Phòng 107'},
    ],
    '10A8': [
      {'day': 2, 'periods': '1', 'time': '07:00 - 07:45', 'teacher': 'Phạm Văn Đức', 'room': 'Phòng 108'},
      {'day': 3, 'periods': '3-4', 'time': '08:50 - 10:25', 'teacher': 'Phạm Văn Đức', 'room': 'Phòng 108'},
      {'day': 5, 'periods': '2-3', 'time': '07:50 - 09:35', 'teacher': 'Phạm Văn Đức', 'room': 'Phòng 108'},
      {'day': 6, 'periods': '1-2', 'time': '07:00 - 08:35', 'teacher': 'Phạm Văn Đức', 'room': 'Phòng 108'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.className ?? '10A1';
  }

  List<Map<String, dynamic>> get _currentSchedule {
    return _englishSchedule[_selectedClass] ?? [];
  }

  int get _totalPeriods {
    int count = 0;
    for (var item in _currentSchedule) {
      String periods = item['periods'];
      if (periods.contains('-')) {
        var parts = periods.split('-');
        count += int.parse(parts[1]) - int.parse(parts[0]) + 1;
      } else {
        count += 1;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildClassSelector(),
            _buildStatsRow(),
            Expanded(child: _buildScheduleList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thời khóa biểu Tiếng Anh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Năm học 2025-2026 • ${widget.className ?? "Khối 10"}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    // Hide class selector if className was passed
    if (widget.className != null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chọn lớp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final classItem = _classes[index];
                final isSelected = _selectedClass == classItem;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedClass = classItem),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]) : null,
                        color: isSelected ? null : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(22),
                        border: isSelected ? null : Border.all(color: const Color(0xFFE3F2FD)),
                        boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                      ),
                      child: Center(child: Text(classItem, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.w600))),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, widget.className != null ? 20 : 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_stories, color: Color(0xFF2196F3), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lớp $_selectedClass', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Text('${_currentSchedule.length} buổi • $_totalPeriods tiết/tuần', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(20)),
              child: const Text('Tiếng Anh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    final schedule = _currentSchedule;
    
    if (schedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 80, color: const Color(0xFF94A3B8).withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Không có lịch học', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: schedule.length,
      itemBuilder: (context, index) => _buildPeriodCard(schedule[index]),
    );
  }

  Widget _buildPeriodCard(Map<String, dynamic> period) {
    String dayName = _days[period['day'] - 1];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3F2FD)),
        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayName.substring(4), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('T${period['periods']}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(dayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
                        child: Text('Tiết ${period['periods']}', style: const TextStyle(fontSize: 12, color: Color(0xFF2196F3), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(period['time'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(period['teacher'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(period['room'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
