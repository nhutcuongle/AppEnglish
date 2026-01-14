import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import 'lesson_screen.dart';

class UnitManagementScreen extends StatefulWidget {
  const UnitManagementScreen({super.key});

  @override
  State<UnitManagementScreen> createState() => _UnitManagementScreenState();
}

class _UnitManagementScreenState extends State<UnitManagementScreen> {
  List<Map<String, dynamic>> _units = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() => _isLoading = true);
    try {
      final units = await ApiService.getUnits();
      setState(() {
        _units = units.map((u) => <String, dynamic>{
          'id': u['_id']?.toString() ?? '',
          'title': u['title'] ?? '',
          'description': u['description'] ?? '',
          'image': u['image'],
          'isPublished': u['isPublished'] ?? true,
          'order': u['order'] ?? 0,
        }).toList();
        
        // Sort by order field
        _units.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Lỗi tải dữ liệu: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredUnits {
    if (_searchQuery.isEmpty) return _units;
    return _units.where((u) => 
      u['title'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? unit}) async {
    final titleController = TextEditingController(text: unit?['title'] ?? '');
    final descController = TextEditingController(text: unit?['description'] ?? '');
    final orderController = TextEditingController(text: unit?['order']?.toString() ?? '');
    bool isPublished = unit?['isPublished'] ?? true;
    String? currentImageUrl = unit?['image'];
    String? selectedImagePath;
    final parentContext = context;
    final ImagePicker picker = ImagePicker();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(unit == null ? Icons.add_circle : Icons.edit, color: const Color(0xFF2196F3)),
                    ),
                    const SizedBox(width: 12),
                    Text(unit == null ? 'Thêm Unit Mới' : 'Sửa Unit', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx, null), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image section
                        const Text('Ảnh đại diện', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            showModalBottomSheet(
                              context: context,
                              builder: (c) => SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library, color: Color(0xFF2196F3)),
                                      title: const Text('Chọn từ thư viện'),
                                      onTap: () async {
                                        Navigator.pop(c);
                                        final XFile? image = await picker.pickImage(
                                          source: ImageSource.gallery, 
                                          imageQuality: 50,
                                          maxWidth: 800,
                                          maxHeight: 800,
                                        );
                                        if (image != null) {
                                          setModalState(() => selectedImagePath = image.path);
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt, color: Color(0xFF2196F3)),
                                      title: const Text('Chụp ảnh'),
                                      onTap: () async {
                                        Navigator.pop(c);
                                        final XFile? image = await picker.pickImage(
                                          source: ImageSource.camera, 
                                          imageQuality: 50,
                                          maxWidth: 800,
                                          maxHeight: 800,
                                        );
                                        if (image != null) {
                                          setModalState(() => selectedImagePath = image.path);
                                        }
                                      },
                                    ),
                                    if (selectedImagePath != null || currentImageUrl != null)
                                      ListTile(
                                        leading: const Icon(Icons.delete, color: Colors.red),
                                        title: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                                        onTap: () {
                                          Navigator.pop(c);
                                          setModalState(() {
                                            selectedImagePath = null;
                                            currentImageUrl = null;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE3F2FD), width: 2),
                            ),
                            child: selectedImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(File(selectedImagePath!), fit: BoxFit.cover),
                                  )
                                : currentImageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(currentImageUrl!, fit: BoxFit.cover),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                                          const SizedBox(height: 8),
                                          Text('Nhấn để chọn ảnh', style: TextStyle(color: Colors.grey[500])),
                                        ],
                                      ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Tiêu đề Unit *',
                            hintText: 'VD: Unit 1 - Greetings',
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Mô tả',
                            hintText: 'Mô tả nội dung Unit...',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: orderController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Thứ tự hiển thị',
                            hintText: 'VD: 1, 2, 3...',
                            prefixIcon: const Icon(Icons.reorder),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Đã xuất bản'),
                          subtitle: const Text('Học sinh có thể xem Unit này'),
                          value: isPublished,
                          onChanged: (v) => setModalState(() => isPublished = v),
                          activeColor: const Color(0xFF2196F3),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty) { _showError('Vui lòng nhập tiêu đề!'); return; }
                      Navigator.pop(ctx, {
                        'title': titleController.text.trim(),
                        'description': descController.text.trim(),
                        'order': orderController.text.isNotEmpty ? int.tryParse(orderController.text) : null,
                        'isPublished': isPublished,
                        'imagePath': selectedImagePath,
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(unit == null ? 'Thêm Unit' : 'Lưu thay đổi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      showDialog(context: parentContext, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      
      try {
        Map<String, dynamic> apiResult;
        final String? imagePath = result['imagePath'];
        
        if (unit == null) {
          // Create new unit
          if (imagePath != null) {
            apiResult = await ApiService.createUnitWithImage(
              title: result['title'], 
              description: result['description'], 
              isPublished: result['isPublished'],
              order: result['order'],
              imagePath: imagePath,
            );
          } else {
            apiResult = await ApiService.createUnit(
              title: result['title'], 
              description: result['description'], 
              isPublished: result['isPublished'],
              order: result['order'],
            );
          }
        } else {
          // Update existing unit
          final updateData = <String, dynamic>{
            'title': result['title'], 
            'description': result['description'], 
            'isPublished': result['isPublished'],
          };
          if (result['order'] != null) updateData['order'] = result['order'];
          
          if (imagePath != null) {
            apiResult = await ApiService.updateUnitWithImage(unit['id'], updateData, imagePath: imagePath);
          } else {
            apiResult = await ApiService.updateUnit(unit['id'], updateData);
          }
        }
        
        if (mounted) Navigator.pop(parentContext); // Close loading

        if (apiResult['error'] != null) {
          _showError(apiResult['error']);
        } else {
          _showSuccess(unit == null ? 'Tạo Unit thành công!' : 'Cập nhật thành công!');
          _loadUnits();
        }
      } catch (e) {
        if (mounted) Navigator.pop(parentContext); // Ensure loading is closed
        _showError('Đã có lỗi xảy ra: $e');
      }
    }
  }

  Future<void> _deleteUnit(Map<String, dynamic> unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa Unit "${unit['title']}"?\nViệc này sẽ xóa tất cả Lessons trong Unit.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final result = await ApiService.deleteUnit(unit['id']);
      Navigator.pop(context);

      if (result['error'] != null) {
        _showError(result['error']);
      } else {
        _showSuccess('Đã xóa Unit!');
        _loadUnits();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text('Quản lý Unit', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadUnits,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header với search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm Unit...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('${_units.length}', 'Tổng Unit', Icons.folder),
                    _buildStat(
                      '${_units.where((u) => u['isPublished'] == true).length}',
                      'Đã xuất bản',
                      Icons.public,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUnits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty ? 'Không tìm thấy Unit' : 'Chưa có Unit nào',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUnits,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredUnits.length,
                          itemBuilder: (ctx, index) => _buildUnitCard(_filteredUnits[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm Unit', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit) {
    final order = unit['order'] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonScreen(unitId: unit['id'], unitTitle: unit['title']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: unit['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(unit['image'], fit: BoxFit.cover, width: 60, height: 60),
                          )
                        : const Icon(Icons.folder, color: Color(0xFF2196F3), size: 32),
                  ),
                  if (order > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2196F3),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$order',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            unit['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: unit['isPublished'] == true
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            unit['isPublished'] == true ? 'Công khai' : 'Ẩn',
                            style: TextStyle(
                              fontSize: 11,
                              color: unit['isPublished'] == true ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (unit['description']?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        unit['description'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _showAddEditDialog(unit: unit);
                  if (value == 'delete') _deleteUnit(unit);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Row(
                    children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Sửa')],
                  )),
                  const PopupMenuItem(value: 'delete', child: Row(
                    children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))],
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
