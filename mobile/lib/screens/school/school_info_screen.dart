import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/login_screen.dart';

class SchoolInfoScreen extends StatefulWidget {
  const SchoolInfoScreen({super.key});

  @override
  State<SchoolInfoScreen> createState() => _SchoolInfoScreenState();
}

class _SchoolInfoScreenState extends State<SchoolInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // Readonly
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        if (profile.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(profile['error'])));
        } else {
          _nameController.text = profile['fullName'] ?? '';
          _yearController.text = profile['academicYear'] ?? '';
          _usernameController.text = profile['username'] ?? '';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) return;
    
    setState(() => _isSaving = true);
    final result = await ApiService.updateProfile(_nameController.text, _yearController.text);
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
        Navigator.pop(context, true); // Return true to signal refresh
      }
    }
  }
  
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thông tin nhà trường', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_rounded, size: 40, color: primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Username (Readonly)
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Tên đăng nhập',
                    icon: Icons.account_circle_rounded,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  
                  // School Name
                  _buildTextField(
                    controller: _nameController,
                    label: 'Tên trường',
                    hint: 'Nhập tên trường',
                    icon: Icons.business_rounded,
                  ),
                  const SizedBox(height: 20),
                  
                  // Academic Year
                  _buildTextField(
                    controller: _yearController,
                    label: 'Năm học',
                    hint: 'VD: 2025-2026',
                    icon: Icons.calendar_today_rounded,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: const Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
