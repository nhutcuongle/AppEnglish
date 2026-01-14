import 'package:flutter/material.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:intl/intl.dart';

class TeacherCalendarScreen extends StatefulWidget {
  const TeacherCalendarScreen({super.key});

  @override
  State<TeacherCalendarScreen> createState() => _TeacherCalendarScreenState();
}

class _TeacherCalendarScreenState extends State<TeacherCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Assignment> _allExams = [];
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
      final data = await ApiService.getTeacherExams();
      if (!mounted) return;
      setState(() {
        _allExams = data.map((e) => Assignment.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter exams for selected date
    final dailyEvents = _allExams.where((exam) {
      return exam.startTime.year == _selectedDate.year &&
             exam.startTime.month == _selectedDate.month &&
             exam.startTime.day == _selectedDate.day;
    }).toList();
    
    // Sort chronologically
    dailyEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Lịch Giảng Dạy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadEvents, icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent)),
        ],
      ),
      body: Column(
        children: [
          _buildWeekCalendar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : dailyEvents.isEmpty
                    ? _buildEmptySchedule()
                    : _buildEventList(dailyEvents),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    // Generate dates for the current week centered around selected date or today
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM, yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const Icon(Icons.calendar_today_rounded, color: Colors.blueAccent, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 14, // Show 2 weeks
              itemBuilder: (context, index) {
                final date = firstDayOfWeek.add(Duration(days: index));
                final isSelected = date.year == _selectedDate.year &&
                                 date.month == _selectedDate.month &&
                                 date.day == _selectedDate.day;
                final isToday = date.year == now.year &&
                              date.month == now.month &&
                              date.day == now.day;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 55,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : (isToday ? Colors.blue.withOpacity(0.05) : Colors.transparent),
                      borderRadius: BorderRadius.circular(16),
                      border: isToday && !isSelected ? Border.all(color: Colors.blueAccent.withOpacity(0.3)) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF1E293B),
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
    );
  }

  Widget _buildEventList(List<Assignment> events) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final bool isPast = event.startTime.isBefore(DateTime.now());

        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    DateFormat('HH:mm').format(event.startTime),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.blueAccent.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border(left: BorderSide(color: isPast ? Colors.grey : Colors.blueAccent, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (event.type == '15m' ? Colors.orange : Colors.purple).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.type == '15m' ? 'Kiểm tra 15p' : 'Kiểm tra 45p',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: event.type == '15m' ? Colors.orange : Colors.purple,
                              ),
                            ),
                          ),
                          if (isPast)
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description, // Often contains class info in this app
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySchedule() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.event_busy_rounded, size: 60, color: Colors.blueAccent.withOpacity(0.2)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có lịch giảng dạy',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const Text(
            'Hãy tận hưởng ngày nghỉ của bạn!',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
