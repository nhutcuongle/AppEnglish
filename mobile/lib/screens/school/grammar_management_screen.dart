import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';

class GrammarManagementScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const GrammarManagementScreen({super.key, required this.lessonId, required this.lessonTitle});

  @override
  State<GrammarManagementScreen> createState() => _GrammarManagementScreenState();
}

class _GrammarManagementScreenState extends State<GrammarManagementScreen> {
  List<Map<String, dynamic>> _grammarList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrammar();
  }

  Future<void> _loadGrammar() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getGrammarByLesson(widget.lessonId);
      setState(() {
        _grammarList = data.map((g) => {
          'id': g['_id']?.toString() ?? '',
          'title': g['title'] ?? '',
          'theory': g['theory'] ?? '',
          'examples': List<String>.from(g['examples'] ?? []),
          'isPublished': g['isPublished'] ?? true,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Lỗi tải dữ liệu: $e');
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  void _showSuccess(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));

  Future<void> _showAddEditDialog({Map<String, dynamic>? grammar}) async {
    final titleController = TextEditingController(text: grammar?['title'] ?? '');
    final theoryController = TextEditingController(text: grammar?['theory'] ?? '');
    final examplesController = TextEditingController(text: (grammar?['examples'] as List<String>?)?.join('\n') ?? '');
    bool isPublished = grammar?['isPublished'] ?? true;
    
    List<String> imagePaths = [], audioPaths = [], videoPaths = [];
    List<String> imageUrls = [], audioUrls = [], videoUrls = [];
    
    // Load existing media
    if (grammar != null) {
      if (grammar['images'] != null) imageUrls = List<String>.from(grammar['images']);
      if (grammar['audios'] != null) audioUrls = List<String>.from(grammar['audios']);
      if (grammar['videos'] != null) videoUrls = List<String>.from(grammar['videos']);
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
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.menu_book, color: Color(0xFF2196F3))),
                    const SizedBox(width: 12),
                    Text(grammar == null ? 'Thêm Ngữ pháp' : 'Sửa Ngữ pháp', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx, false), icon: const Icon(Icons.close)),
                  ]),
                  const SizedBox(height: 20),
                  TextField(controller: titleController, decoration: InputDecoration(labelText: 'Tiêu đề *', hintText: 'VD: Present Simple Tense', prefixIcon: const Icon(Icons.title), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                  const SizedBox(height: 16),
                  TextField(controller: theoryController, maxLines: 5, decoration: InputDecoration(labelText: 'Lý thuyết *', hintText: 'Nội dung lý thuyết ngữ pháp...', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                  const SizedBox(height: 16),
                  TextField(controller: examplesController, maxLines: 3, decoration: InputDecoration(labelText: 'Ví dụ (mỗi dòng 1 ví dụ)', hintText: 'I go to school every day.', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                  const SizedBox(height: 20),
                  const Text('📎 Đính kèm Media', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text('Chọn file (URL chưa hỗ trợ lưu)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildMediaSection(title: 'Hình ảnh', icon: Icons.image, color: Colors.blue, localPaths: imagePaths, urls: imageUrls,
                    onPickFile: () async { try { final images = await ImagePicker().pickMultiImage(); if (images.isNotEmpty) setModalState(() => imagePaths.addAll(images.map((e) => e.path))); } catch (e) { _showError('Lỗi: $e'); } },
                    onAddUrl: () => _showUrlInputDialog(title: 'URL hình ảnh', hint: 'https://...', onAdd: (u) => setModalState(() => imageUrls.add(u))),
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
                  const SizedBox(height: 12),
                  SwitchListTile(title: const Text('Đã xuất bản'), value: isPublished, onChanged: (v) => setModalState(() => isPublished = v), activeColor: const Color(0xFF2196F3), contentPadding: EdgeInsets.zero),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isEmpty || theoryController.text.isEmpty) { _showError('Vui lòng nhập đủ thông tin!'); return; }
                        Navigator.pop(ctx, true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(grammar == null ? 'Thêm Ngữ pháp' : 'Lưu thay đổi'),
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
      final examples = examplesController.text.split('\n').where((e) => e.trim().isNotEmpty).toList();
      
      try {
        Map<String, dynamic> result;
        if (grammar == null) {
          if (imagePaths.isNotEmpty || audioPaths.isNotEmpty || videoPaths.isNotEmpty) {
             result = await ApiService.createGrammarWithMedia(lessonId: widget.lessonId, title: titleController.text.trim(), theory: theoryController.text.trim(), examples: examples, isPublished: isPublished, imagePaths: imagePaths.isNotEmpty ? imagePaths : null, audioPaths: audioPaths.isNotEmpty ? audioPaths : null, videoPaths: videoPaths.isNotEmpty ? videoPaths : null);
          } else {
             result = await ApiService.createGrammar(lessonId: widget.lessonId, title: titleController.text.trim(), theory: theoryController.text.trim(), examples: examples, isPublished: isPublished);
          }
        } else {
          result = await ApiService.updateGrammar(grammar['id'], {'title': titleController.text.trim(), 'theory': theoryController.text.trim(), 'examples': examples, 'isPublished': isPublished});
        }
        
        if (mounted) Navigator.pop(parentContext); // Close loading

        if (result['error'] != null) {
          _showError(result['error']);
        } else {
          _showSuccess(grammar == null ? 'Tạo thành công!' : 'Cập nhật thành công!');
          await _loadGrammar();
        }
      } catch (e) {
        if (mounted) Navigator.pop(parentContext);
        _showError('Lỗi kết nối: $e');
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
    await showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(title), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: c, decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.url), const SizedBox(height: 8), Text('Hỗ trợ: URL hoặc đường dẫn local', style: TextStyle(fontSize: 11, color: Colors.grey[600]))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')), ElevatedButton(onPressed: () { final path = c.text.trim(); if (path.isNotEmpty) { onAdd(path); Navigator.pop(ctx); } else _showError('Vui lòng nhập đường dẫn!'); }, child: const Text('Thêm'))]));
  }

  Future<void> _deleteGrammar(Map<String, dynamic> grammar) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Xác nhận xóa'), content: Text('Xóa "${grammar['title']}"?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red)))]));
    if (confirmed == true) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      final result = await ApiService.deleteGrammar(grammar['id']);
      Navigator.pop(context);
      if (result['error'] != null) _showError(result['error']); else { _showSuccess('Đã xóa!'); _loadGrammar(); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Ngữ pháp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(widget.lessonTitle, style: const TextStyle(fontSize: 12))]), elevation: 0, actions: [IconButton(onPressed: _loadGrammar, icon: const Icon(Icons.refresh))]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grammarList.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey[400]), const SizedBox(height: 16), Text('Chưa có ngữ pháp nào', style: TextStyle(color: Colors.grey[600]))]))
              : RefreshIndicator(onRefresh: _loadGrammar, child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _grammarList.length, itemBuilder: (ctx, i) => _buildGrammarCard(_grammarList[i]))),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showAddEditDialog(), backgroundColor: const Color(0xFF2196F3), icon: const Icon(Icons.add, color: Colors.white), label: const Text('Thêm Ngữ pháp', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildGrammarCard(Map<String, dynamic> grammar) {
    final examples = grammar['examples'] as List<String>;
    return Card(
      margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.menu_book, color: Color(0xFF2196F3))),
        title: Text(grammar['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(grammar['theory'].length > 50 ? '${grammar['theory'].substring(0, 50)}...' : grammar['theory'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: PopupMenuButton<String>(onSelected: (v) { if (v == 'edit') _showAddEditDialog(grammar: grammar); if (v == 'delete') _deleteGrammar(grammar); }, itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Sửa')])), const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))]))]),
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Divider(), const Text('Lý thuyết:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(grammar['theory'], style: const TextStyle(fontSize: 14)),
            if (examples.isNotEmpty) ...[const SizedBox(height: 16), const Text('Ví dụ:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...examples.map((ex) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(color: Color(0xFF2196F3))), Expanded(child: Text(ex, style: const TextStyle(fontStyle: FontStyle.italic)))])))],
          ])),
        ],
      ),
    );
  }
}
