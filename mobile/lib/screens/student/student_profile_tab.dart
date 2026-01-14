import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/login_screen.dart';
import 'package:intl/intl.dart';

class StudentProfileTab extends StatefulWidget {
  final VoidCallback? onBack;
  const StudentProfileTab({super.key, this.onBack});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String studentName = "Học sinh";
  String className = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await ApiService.getProfile();
      if (mounted) {
        setState(() {
          // Check if response has 'data' key wrapper or is direct object
          if (response.containsKey('data')) {
            userData = response['data'];
          } else {
            userData = response;
          }
           // Use helper to parse class name safely (copied logic from Dashboard)
           _parseUserData();
           isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _parseUserData() {
    if (userData == null) return;
    
    studentName = userData!['fullName']?.toString().isNotEmpty == true 
        ? userData!['fullName'] 
        : (userData!['username'] ?? "Học sinh");

    if (userData!['class'] != null) {
      if (userData!['class'] is Map) {
        className = userData!['class']['name'] ?? "Chưa có lớp";
      } else if (userData!['class'] is String) {
        className = "Lớp (ID: ${userData!['class']})"; // Simplification
      }
    } else {
      className = "Chưa có lớp";
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const LoginScreen()), 
                (route) => false
              );
            },
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordFeature() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Đổi mật khẩu"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu cũ", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu mới", border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")));
                  return;
                }

                setState(() => isSubmitting = true);
                
                // Call API
                final result = await ApiService.changePassword(
                  oldPassController.text, 
                  newPassController.text
                );

                if (context.mounted) {
                   setState(() => isSubmitting = false);
                   if (result.containsKey('error') || (result.containsKey('message') && result['message'].toString().toLowerCase().contains('sai'))) {
                     Navigator.pop(context); // Close dialog first to show snackbar on screen
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(result['error'] ?? result['message'] ?? "Lỗi đổi mật khẩu"), backgroundColor: Colors.red)
                     );
                   } else {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Đổi mật khẩu thành công!"), backgroundColor: Colors.green)
                     );
                   }
                }
              },
              child: isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text("Đổi mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thông tin tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: widget.onBack,
              )
            : null,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50, 
                  backgroundColor: Colors.white, 
                  child: Icon(Icons.person, size: 60, color: Colors.blueAccent)
                ),
                const SizedBox(height: 16),
                Text(studentName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(className, style: const TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 30),
                
                // Detailed Info Section
                if (userData != null) ...[
                   _buildInfoCard(),
                   const SizedBox(height: 30),
                ],

                _buildOption(Icons.lock_reset_rounded, 'Đổi mật khẩu', Colors.blue, onTap: _showChangePasswordFeature),
                _buildOption(Icons.help_outline_rounded, 'Trung tâm trợ giúp', Colors.orange, onTap: () {}),
                // "Về ứng dụng" removed per request
                const SizedBox(height: 10),
                _buildOption(Icons.logout_rounded, 'Đăng xuất', Colors.red, isLogout: true, onTap: _confirmLogout),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          _buildInfoItem("Tên đăng nhập", userData!['username'] ?? "N/A", Icons.badge_outlined),
          const Divider(height: 1, indent: 20, endIndent: 20),
          // Email removed per user request
          _buildInfoItem("Số điện thoại", userData!['phone'] ?? "Chưa cập nhật", Icons.phone_outlined),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildInfoItem(
            "Ngày sinh", 
            userData!['dateOfBirth'] != null 
                ? DateFormat('dd/MM/yyyy').format(DateTime.parse(userData!['dateOfBirth'])) 
                : "Chưa cập nhật", 
            Icons.calendar_today_outlined
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, Color color, {bool isLogout = false, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isLogout ? Colors.red : const Color(0xFF1E293B))),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }
}
