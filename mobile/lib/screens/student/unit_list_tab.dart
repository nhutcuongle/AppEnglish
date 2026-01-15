import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/student/unit_detail_screen.dart';

class UnitListTab extends StatefulWidget {
  const UnitListTab({super.key});

  @override
  State<UnitListTab> createState() => _UnitListTabState();
}

class _UnitListTabState extends State<UnitListTab> {
  List<dynamic> units = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    // ========== MOCK DATA ĐỂ TEST ==========
    // Bỏ comment phần này để test với dữ liệu giả
    /*
    if (mounted) {
      setState(() {
        units = [
          {'_id': '1', 'title': 'Unit 1: Introduction', 'description': 'Basic English greetings'},
          {'_id': '2', 'title': 'Unit 2: Family', 'description': 'Family members and relationships'},
          {'_id': '3', 'title': 'Unit 3: School', 'description': 'School life and subjects'},
        ];
        isLoading = false;
      });
    }
    return;
    */
    // ========================================

    try {
      final response = await ApiService.getPublicUnits();
      debugPrint('=== UNITS RESPONSE ===');
      debugPrint(response.toString());
      debugPrint('=== RESPONSE TYPE: ${response.runtimeType} ===');
      
      if (mounted) {
        setState(() {
          if (response is List) {
            units = response;
          } else if (response is Map) {
            if (response.containsKey('error')) {
              // Show error
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải bài học: ${response['error']}')));
              units = [];
            } else if (response['data'] != null) {
              units = response['data'] as List? ?? [];
            } else {
              units = [];
            }
          } else {
            units = [];
          }
          debugPrint('=== PARSED UNITS COUNT: ${units.length} ===');
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('=== UNITS ERROR: $e ===');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF), // Light blue background
      appBar: AppBar(
        title: const Text('Danh sách bài học', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUnits,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: units.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final unit = units[index];
                  final image = unit['image'];
                  final hasImage = image != null && image.toString().isNotEmpty;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnitDetailScreen(unitId: unit['_id'], unitName: unit['title'], unitTitle: unit['description'] ?? ''))),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Unit Image/Icon
                              Hero(
                                tag: 'unit_hero_${unit['_id']}',
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.blue.shade50,
                                    image: hasImage ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover) : null,
                                  ),
                                  child: !hasImage
                                      ? Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.blue.shade300,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      unit['title'] ?? 'Unit ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      unit['description'] ?? 'Không có mô tả',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
