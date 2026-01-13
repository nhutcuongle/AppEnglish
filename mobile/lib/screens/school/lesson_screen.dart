import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import 'grammar_management_screen.dart';
import 'vocabulary_management_screen.dart';
import 'lesson_detail_screen.dart';

class LessonScreen extends StatefulWidget {
  final String unitId;
  final String unitTitle;

  const LessonScreen({super.key, required this.unitId, required this.unitTitle});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = true;
  String _filterType = 'all';

  final List<Map<String, dynamic>> _lessonTypes = [
    {'value': 'vocabulary', 'label': 'Từ vựng', 'icon': Icons.abc, 'color': Color(0xFF4CAF50)},
    {'value': 'grammar', 'label': 'Ngữ pháp', 'icon': Icons.menu_book, 'color': Color(0xFF2196F3)},
    {'value': 'reading', 'label': 'Đọc hiểu', 'icon': Icons.chrome_reader_mode, 'color': Color(0xFF9C27B0)},
    {'value': 'listening', 'label': 'Nghe', 'icon': Icons.headphones, 'color': Color(0xFFFF9800)},
    {'value': 'speaking', 'label': 'Nói', 'icon': Icons.mic, 'color': Color(0xFFE91E63)},
    {'value': 'writing', 'label': 'Viết', 'icon': Icons.edit_note, 'color': Color(0xFF607D8B)},
  ];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      final lessons = await ApiService.getLessonsByUnit(widget.unitId);
      setState(() {
        _lessons = lessons.map((l) => {
          'id': l['_id']?.toString() ?? '',
          'title': l['title'] ?? '',
          'lessonType': l['lessonType'] ?? 'vocabulary',
          'content': l['content'] ?? '',
          'isPublished': l['isPublished'] ?? true,
          'order': l['order'] ?? 0,
          'images': l['images'] ?? [],
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Lỗi tải dữ liệu: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredLessons {
    if (_filterType == 'all') return _lessons;
    return _lessons.where((l) => l['lessonType'] == _filterType).toList();
  }

  Map<String, dynamic> _getTypeInfo(String type) => _lessonTypes.firstWhere((t) => t['value'] == type, orElse: () => _lessonTypes.first);

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  void _showSuccess(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));

  Future<void> _showAddEditDialog({Map<String, dynamic>? lesson}) async {
    final titleController = TextEditingController(text: lesson?['title'] ?? '');
    final contentController = TextEditingController(text: lesson?['content'] ?? '');
    String selectedType = lesson?['lessonType'] ?? 'vocabulary';
    bool isPublished = lesson?['isPublished'] ?? true;
    
    List<String> imagePaths = [], audioPaths = [], videoPaths = [];
    List<String> imageUrls = [], audioUrls = [], videoUrls = [];
    
    // Load existing media
    if (lesson != null) {
      if (lesson['images'] != null) imageUrls = List<String>.from(lesson['images']);
      if (lesson['audios'] != null) audioUrls = List<String>.from(lesson['audios']);
      if (lesson['videos'] != null) videoUrls = List<String>.from(lesson['videos']);
    }

    final parentContext = context;

    final shouldSubmit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          height: MediaQuery.of(modalContext).size.height * 0.95,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(modalContext).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(lesson == null ? Icons.add_circle : Icons.edit, color: const Color(0xFF2196F3))),
                    const SizedBox(width: 12),
                    Text(lesson == null ? 'Thêm Bài học' : 'Sửa Bài học', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx, false), icon: const Icon(Icons.close)),
                  ]),
                  const SizedBox(height: 20),
                  TextField(controller: titleController, decoration: InputDecoration(labelText: 'Tiêu đề *', hintText: 'VD: Vocabulary - Family Life', prefixIcon: const Icon(Icons.title), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                  const SizedBox(height: 16),
                  const Text('Loại bài học *', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: _lessonTypes.map((type) {
                    final isSelected = selectedType == type['value'];
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedType = type['value']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: isSelected ? (type['color'] as Color).withOpacity(0.2) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? type['color'] as Color : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(type['icon'] as IconData, size: 16, color: type['color'] as Color), const SizedBox(width: 4), Text(type['label'] as String, style: TextStyle(color: isSelected ? type['color'] as Color : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))]),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 16),
                  TextField(controller: contentController, maxLines: 4, decoration: InputDecoration(labelText: 'Nội dung', hintText: 'Nội dung bài học...', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                  const SizedBox(height: 20),
                  const Text('📎 Đính kèm Media', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text('Chọn file (URL chưa hỗ trợ lưu)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildMediaSection(title: 'Hình ảnh', icon: Icons.image, color: Colors.blue, localPaths: imagePaths, urls: imageUrls,
                    onPickFile: () async { try { final images = await ImagePicker().pickMultiImage(); if (images.isNotEmpty) setModalState(() => imagePaths.addAll(images.map((e) => e.path))); } catch (e) { _showError('Lỗi: $e'); } },
                    onAddUrl: () => _showUrlInputDialog(title: 'URL hình ảnh', hint: 'https://...', onAdd: (u) => setModalState(() => imageUrls.add(u))), // URL just for internal list, won't save to backend without changes
                    onRemoveLocal: (i) => setModalState(() => imagePaths.removeAt(i)), onRemoveUrl: (i) => setModalState(() => imageUrls.removeAt(i)),
                  ),
                  const SizedBox(height: 12),
                  _buildMediaSection(title: 'Audio', icon: Icons.audiotrack, color: Colors.orange, localPaths: audioPaths, urls: audioUrls,
                    onPickFile: () async { try { final r = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: true); if (r != null) setModalState(() => audioPaths.addAll(r.paths.whereType<String>())); } catch (e) { _showError('Lỗi: $e'); } },
                    onAddUrl: () => _showUrlInputDialog(title: 'URL audio', hint: 'https://...', onAdd: (u) => setModalState(() => audioUrls.add(u))),
                    onRemoveLocal: (i) => setModalState(() => audioPaths.removeAt(i)), onRemoveUrl: (i) => setModalState(() => audioUrls.removeAt(i)),
                  ),
                  const SizedBox(height: 12),
                  _buildMediaSection(title: 'Video', icon: Icons.videocam, color: Colors.purple, localPaths: videoPaths, urls: videoUrls,
                    onPickFile: () async { try { final r = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true); if (r != null) setModalState(() => videoPaths.addAll(r.paths.whereType<String>())); } catch (e) { _showError('Lỗi: $e'); } },
                    onAddUrl: () => _showUrlInputDialog(title: 'URL video', hint: 'https://...', onAdd: (u) => setModalState(() => videoUrls.add(u))),
                    onRemoveLocal: (i) => setModalState(() => videoPaths.removeAt(i)), onRemoveUrl: (i) => setModalState(() => videoUrls.removeAt(i)),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(title: const Text('Đã xuất bản'), value: isPublished, onChanged: (v) => setModalState(() => isPublished = v), activeColor: const Color(0xFF2196F3), contentPadding: EdgeInsets.zero),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isEmpty) { _showError('Vui lòng nhập tiêu đề!'); return; }
                        Navigator.pop(ctx, true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(lesson == null ? 'Thêm Bài học' : 'Lưu thay đổi'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (shouldSubmit == true && mounted) {
      showDialog(context: parentContext, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      
      Map<String, dynamic> result;
      if (lesson == null) {
        if (imagePaths.isNotEmpty || audioPaths.isNotEmpty || videoPaths.isNotEmpty) {
           result = await ApiService.createLessonWithMedia(unitId: widget.unitId, lessonType: selectedType, title: titleController.text.trim(), content: contentController.text.trim(), isPublished: isPublished, imagePaths: imagePaths.isNotEmpty ? imagePaths : null, audioPaths: audioPaths.isNotEmpty ? audioPaths : null, videoPaths: videoPaths.isNotEmpty ? videoPaths : null);
        } else {
           result = await ApiService.createLesson(unitId: widget.unitId, lessonType: selectedType, title: titleController.text.trim(), content: contentController.text.trim(), isPublished: isPublished);
        }
      } else {
        result = await ApiService.updateLesson(lesson['id'], {'lessonType': selectedType, 'title': titleController.text.trim(), 'content': contentController.text.trim(), 'isPublished': isPublished});
      }
      
      if (mounted) Navigator.of(parentContext).pop();
      
      if (result['error'] != null) {
        _showError(result['error']);
      } else {
        _showSuccess(lesson == null ? 'Tạo thành công!' : 'Cập nhật thành công!');
        _loadLessons();
      }
    }
  }

  Widget _buildMediaSection({required String title, required IconData icon, required Color color, required List<String> localPaths, required List<String> urls, required VoidCallback onPickFile, required VoidCallback onAddUrl, required Function(int) onRemoveLocal, required Function(int) onRemoveUrl}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)), const Spacer(), TextButton.icon(onPressed: onPickFile, icon: Icon(Icons.folder_open, size: 16, color: color), label: Text('File', style: TextStyle(color: color, fontSize: 12)), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8))), TextButton.icon(onPressed: onAddUrl, icon: Icon(Icons.link, size: 16, color: color), label: Text('URL', style: TextStyle(color: color, fontSize: 12)), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)))]),
        if (localPaths.isNotEmpty || urls.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: [...localPaths.asMap().entries.map((e) => _buildChip(e.value.split('/').last, icon, color, false, () => onRemoveLocal(e.key))), ...urls.asMap().entries.map((e) => _buildChip(e.value.length > 20 ? '${e.value.substring(0, 20)}...' : e.value, Icons.link, color, true, () => onRemoveUrl(e.key)))])],
      ]),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color, bool isUrl, VoidCallback onRemove) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isUrl ? color.withOpacity(0.2) : color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: isUrl ? Border.all(color: color) : null), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(label.length > 12 ? '${label.substring(0, 12)}...' : label, style: TextStyle(fontSize: 11, color: color)), const SizedBox(width: 4), GestureDetector(onTap: onRemove, child: Icon(Icons.close, size: 14, color: color))]));

  Future<void> _showUrlInputDialog({required String title, required String hint, required Function(String) onAdd}) async {
    final c = TextEditingController();
    await showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(title), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: c, decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.url), const SizedBox(height: 8), Text('URL dùng để tham khảo, chưa hỗ trợ lưu trực tiếp', style: TextStyle(fontSize: 11, color: Colors.grey[600]))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')), ElevatedButton(onPressed: () { final path = c.text.trim(); if (path.isNotEmpty) { onAdd(path); Navigator.pop(ctx); } else _showError('Vui lòng nhập đường dẫn!'); }, child: const Text('Thêm'))]));
  }

  Future<void> _deleteLesson(Map<String, dynamic> lesson) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Xác nhận xóa'), content: Text('Xóa "${lesson['title']}"?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red)))]));
    if (confirmed == true) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      final result = await ApiService.deleteLesson(lesson['id']);
      Navigator.pop(context);
      if (result['error'] != null) _showError(result['error']); else { _showSuccess('Đã xóa!'); _loadLessons(); }
    }
  }

  void _navigateToContent(Map<String, dynamic> lesson) {
    final type = lesson['lessonType'];
    if (type == 'vocabulary') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => VocabularyManagementScreen(lessonId: lesson['id'], lessonTitle: lesson['title'])));
    } else if (type == 'grammar') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => GrammarManagementScreen(lessonId: lesson['id'], lessonTitle: lesson['title'])));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Bài học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(widget.unitTitle, style: const TextStyle(fontSize: 12))]), elevation: 0, actions: [IconButton(onPressed: _loadLessons, icon: const Icon(Icons.refresh))]),
      body: Column(children: [
        Container(padding: const EdgeInsets.all(16), color: Colors.white, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_buildFilterChip('all', 'Tất cả', Icons.apps), ..._lessonTypes.map((t) => _buildFilterChip(t['value'] as String, t['label'] as String, t['icon'] as IconData, color: t['color'] as Color))]))),
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStat('${_lessons.length}', 'Tổng'), ..._lessonTypes.take(3).map((t) => _buildStat('${_lessons.where((l) => l['lessonType'] == t['value']).length}', t['label'] as String))])),
        Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : _filteredLessons.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]), const SizedBox(height: 16), Text('Chưa có bài học nào', style: TextStyle(color: Colors.grey[600]))])) : RefreshIndicator(onRefresh: _loadLessons, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _filteredLessons.length, itemBuilder: (ctx, i) => _buildLessonCard(_filteredLessons[i])))),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showAddEditDialog(), backgroundColor: const Color(0xFF2196F3), icon: const Icon(Icons.add, color: Colors.white), label: const Text('Thêm Bài học', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon, {Color? color}) {
    final isSelected = _filterType == value;
    return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(selected: isSelected, label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: isSelected ? Colors.white : (color ?? Colors.grey)), const SizedBox(width: 4), Text(label)]), onSelected: (_) => setState(() => _filterType = value), selectedColor: color ?? const Color(0xFF2196F3), checkmarkColor: Colors.white, labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey[700])));
  }

  Widget _buildStat(String value, String label) => Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)), Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11))]);

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    final images = lesson['images'] as List<dynamic>? ?? [];
    String? imageUrl;
    if (images.isNotEmpty) {
       final first = images.first;
       if (first is Map && first['url'] != null) imageUrl = first['url'];
       else if (first is String) imageUrl = first;
    }
    
    final type = _lessonTypes.firstWhere((t) => t['value'] == lesson['lessonType'], orElse: () => _lessonTypes.first);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToContent(lesson),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
               ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: (type['color'] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(type['icon'] as IconData, color: type['color'] as Color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lesson['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: (type['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(type['label'] as String, style: TextStyle(fontSize: 11, color: type['color'] as Color, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _showAddEditDialog(lesson: lesson);
                      if (v == 'delete') _deleteLesson(lesson);
                    },
                    itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Text('Sửa')), const PopupMenuItem(value: 'delete', child: Text('Xóa'))],
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
