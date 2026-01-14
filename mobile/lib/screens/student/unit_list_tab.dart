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
    try {
      final response = await ApiService.getPublicUnits();
      if (mounted) {
        setState(() {
          units = response is List ? response : (response['data'] ?? []);
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kho báu kiến thức 📚', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUnits,
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: units.length,
                itemBuilder: (context, index) {
                  final unit = units[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      title: Text(unit['title'] ?? 'Unit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(unit['description'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnitDetailScreen(unitId: unit['_id'], unitName: unit['title'], unitTitle: unit['description'] ?? ''))),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
