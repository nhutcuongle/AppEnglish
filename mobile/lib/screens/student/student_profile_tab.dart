import 'package:flutter/material.dart';
import 'package:apptienganh10/screens/login_screen.dart';

class StudentProfileTab extends StatelessWidget {
  final VoidCallback? onBack;
  const StudentProfileTab({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thông tin tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: onBack,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.person, size: 60, color: Colors.blueAccent)),
            const SizedBox(height: 16),
            const Text('Học sinh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Học sinh lớp 10', style: TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 40),
            _buildOption(Icons.lock_reset_rounded, 'Đổi mật khẩu', Colors.blue),
            _buildOption(Icons.help_outline_rounded, 'Trung tâm trợ giúp', Colors.orange),
            _buildOption(Icons.info_outline_rounded, 'Về ứng dụng', Colors.teal),
            const SizedBox(height: 10),
            _buildOption(Icons.logout_rounded, 'Đăng xuất', Colors.red, isLogout: true, context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, Color color, {bool isLogout = false, BuildContext? context}) {
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
        onTap: () {
          if (isLogout && context != null) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
          }
        },
      ),
    );
  }
}
