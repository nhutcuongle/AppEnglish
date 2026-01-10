import 'package:flutter/material.dart';
import 'package:apptienganh10/services/auth_service.dart';
import 'package:apptienganh10/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Section (Blue Background)
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=33"), // Placeholder
                      child: Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name & Class
                  const Text(
                    "Học sinh Lớp 10",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Trường THPT Chuyên Hutech",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("Ngày học", "12", Icons.local_fire_department),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                      _buildStatItem("Điểm số", "850", Icons.star),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                      _buildStatItem("Xếp hạng", "#5", Icons.emoji_events),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cài đặt chung",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(context, [
                    _buildMenuItem(Icons.person_outline, "Chỉnh sửa hồ sơ", () {}),
                    _buildMenuItem(Icons.notifications_outlined, "Cài đặt thông báo", () {}),
                    _buildMenuItem(Icons.translate, "Ngôn ngữ hiển thị", () {}),
                  ]),

                  const SizedBox(height: 20),
                  Text(
                    "Hỗ trợ & Khác",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(context, [
                    _buildMenuItem(Icons.help_outline, "Trung tâm trợ giúp", () {}),
                    _buildMenuItem(Icons.info_outline, "Về ứng dụng", () {}),
                    _buildMenuItem(Icons.logout, "Đăng xuất", () async {
                      await AuthService.logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false
                      );
                    }, isDestructive: true),
                  ]),
                  
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "Phiên bản 1.0.0",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // For splash effect
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.blueGrey.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? Colors.red : Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red : Colors.black87,
                  ),
                ),
              ),
              if (!isDestructive)
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
