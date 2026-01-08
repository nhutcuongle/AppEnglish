import 'package:flutter/material.dart';
import 'package:apptienganh10/db/mongodb.dart';
import 'package:apptienganh10/models/teacher_models.dart';
import 'package:intl/intl.dart';

class LessonPlanListScreen extends StatefulWidget {
  const LessonPlanListScreen({super.key});

  @override
  State<LessonPlanListScreen> createState() => _LessonPlanListScreenState();
}

class _LessonPlanListScreenState extends State<LessonPlanListScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _viewPlanDetails(LessonPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 25),
              Text(plan.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildBadge(plan.unit, Colors.teal),
                  const SizedBox(width: 8),
                  _buildBadge(plan.topic, Colors.orange),
                ],
              ),
              const Divider(height: 40),
              _buildSectionTitle('Mục tiêu bài học'),
              Text(plan.objectives, style: const TextStyle(fontSize: 15, color: Color(0xFF475569), height: 1.5)),
              const SizedBox(height: 25),
              _buildSectionTitle('Nội dung chi tiết'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15)),
                child: Text(plan.content, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), height: 1.6)),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle('Học liệu đính kèm'),
              if (plan.resources.isEmpty) 
                const Text('Không có tài liệu đính kèm', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
              else
                ...plan.resources.map((link) => _buildResourceLink(link)).toList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildResourceLink(String link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () {}, // Trong thực tế sẽ mở URL
        icon: const Icon(Icons.link_rounded, size: 18),
        label: Text(link, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.teal,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thư Viện Giáo Án', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: FutureBuilder<List<LessonPlan>>(
        future: MongoDatabase.getLessonPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allPlans = snapshot.data ?? [];
          final filteredPlans = allPlans.where((p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
          
          if (filteredPlans.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filteredPlans.length,
            itemBuilder: (context, index) {
              final plan = filteredPlans[index];
              return _buildPlanCard(plan);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm giáo án chuẩn...',
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPlanCard(LessonPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () => _viewPlanDetails(plan),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBadge(plan.unit, Colors.blueGrey),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Text(plan.topic, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600, fontSize: 12)),
              const Divider(height: 30),
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, size: 14, color: Colors.blueAccent),
                  const SizedBox(width: 5),
                  const Text('Giáo án chuẩn của Nhà trường', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                  const Spacer(),
                  Text(DateFormat('dd/MM/yyyy').format(plan.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 15),
          const Text('Hiện chưa có giáo án chuẩn nào từ Nhà trường.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
