import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';

class VocabularyManagementScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const VocabularyManagementScreen({super.key, required this.lessonId, required this.lessonTitle});

  @override
  State<VocabularyManagementScreen> createState() => _VocabularyManagementScreenState();
}

class _VocabularyManagementScreenState extends State<VocabularyManagementScreen> {
  List<Map<String, dynamic>> _vocabList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getVocabularyByLesson(widget.lessonId);
      setState(() {
        _vocabList = data.map((v) => {
          'id': v['_id']?.toString() ?? '',
          'word': v['word'] ?? '',
          'phonetic': v['phonetic'] ?? '',
          'meaning': v['meaning'] ?? '',
          'example': v['example'] ?? '',
          'isPublished': v['isPublished'] ?? true,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Lỗi tải dữ liệu: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredVocab {
    if (_searchQuery.isEmpty) return _vocabList;
    return _vocabList.where((v) => v['word'].toLowerCase().contains(_searchQuery.toLowerCase()) || v['meaning'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  void _showSuccess(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));

  Future<void> _showAddEditDialog({Map<String, dynamic>? vocab}) async {
    final wordController = TextEditingController(text: vocab?['word'] ?? '');
    final phoneticController = TextEditingController(text: vocab?['phonetic'] ?? '');
    final meaningController = TextEditingController(text: vocab?['meaning'] ?? '');
    final exampleController = TextEditingController(text: vocab?['example'] ?? '');
    bool isPublished = vocab?['isPublished'] ?? true;
    
    List<String> imagePaths = [], audioPaths = [], videoPaths = [];
    List<String> imageUrls = [], audioUrls = [], videoUrls = [];
    
    // Load existing media
    if (vocab != null) {
      if (vocab['images'] != null) imageUrls = List<String>.from(vocab['images']);
      if (vocab['audios'] != null) audioUrls = List<String>.from(vocab['audios']);
      if (vocab['videos'] != null) videoUrls = List<String>.from(vocab['videos']);
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
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.abc, color: Color(0xFF4CAF50))),
                    const SizedBox(width: 12),
                    Text(vocab == null ? 'Thêm Từ vựng' : 'Sửa Từ vựng', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx, false), icon: const Icon(Icons.close)),
                  ]),
                  const SizedBox(height: 20),
                  TextField(controller: wordController, decoration: InputDecoration(labelText: 'Từ vựng *', hintText: 'VD: family', prefixIcon: const Icon(Icons.abc), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                  const SizedBox(height: 16),
                  TextField(controller: phoneticController, decoration: InputDecoration(labelText: 'Phiên âm', hintText: '/ˈfæm.ə.li/', prefixIcon: const Icon(Icons.record_voice_over), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                  const SizedBox(height: 16),
                  TextField(controller: meaningController, decoration: InputDecoration(labelText: 'Nghĩa *', hintText: 'Gia đình', prefixIcon: const Icon(Icons.translate), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
                  const SizedBox(height: 16),
                  TextField(controller: exampleController, maxLines: 2, decoration: InputDecoration(labelText: 'Ví dụ', hintText: 'My family is very happy.', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
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
                  SwitchListTile(title: const Text('Đã xuất bản'), value: isPublished, onChanged: (v) => setModalState(() => isPublished = v), activeColor: const Color(0xFF4CAF50), contentPadding: EdgeInsets.zero),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (wordController.text.isEmpty || meaningController.text.isEmpty) { _showError('Vui lòng nhập từ và nghĩa!'); return; }
                        Navigator.pop(ctx, true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(vocab == null ? 'Thêm Từ vựng' : 'Lưu thay đổi'),
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
      
      try {
        Map<String, dynamic> result;
        if (vocab == null) {
          if (imagePaths.isNotEmpty || audioPaths.isNotEmpty || videoPaths.isNotEmpty) {
             result = await ApiService.createVocabularyWithMedia(lessonId: widget.lessonId, word: wordController.text.trim(), phonetic: phoneticController.text.trim(), meaning: meaningController.text.trim(), example: exampleController.text.trim(), isPublished: isPublished, imagePaths: imagePaths.isNotEmpty ? imagePaths : null, audioPaths: audioPaths.isNotEmpty ? audioPaths : null, videoPaths: videoPaths.isNotEmpty ? videoPaths : null);
          } else {
             result = await ApiService.createVocabulary(lessonId: widget.lessonId, word: wordController.text.trim(), phonetic: phoneticController.text.trim(), meaning: meaningController.text.trim(), example: exampleController.text.trim(), isPublished: isPublished);
          }
        } else {
          result = await ApiService.updateVocabulary(vocab['id'], {'word': wordController.text.trim(), 'phonetic': phoneticController.text.trim(), 'meaning': meaningController.text.trim(), 'example': exampleController.text.trim(), 'isPublished': isPublished});
        }
        
        if (mounted) Navigator.pop(parentContext); // Close loading

        if (result['error'] != null) {
          _showError(result['error']);
        } else {
          _showSuccess(vocab == null ? 'Tạo thành công!' : 'Cập nhật thành công!');
          await _loadVocabulary();
        }
      } catch (e) {
        if (mounted) Navigator.pop(parentContext);
        _showError('Lỗi kết nối: $e');
      }
    }
  }

  Future<void> _deleteVocabulary(Map<String, dynamic> vocab) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Xác nhận xóa'), content: Text('Xóa từ "${vocab['word']}"?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red)))]));
    if (confirmed == true) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      final result = await ApiService.deleteVocabulary(vocab['id']);
      Navigator.pop(context);
      if (result['error'] != null) _showError(result['error']); else { _showSuccess('Đã xóa!'); _loadVocabulary(); }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Từ vựng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(widget.lessonTitle, style: const TextStyle(fontSize: 12))]), elevation: 0, actions: [IconButton(onPressed: _loadVocabulary, icon: const Icon(Icons.refresh))]),
      body: Column(children: [
        Container(padding: const EdgeInsets.all(16), color: Colors.white, child: TextField(onChanged: (v) => setState(() => _searchQuery = v), decoration: InputDecoration(hintText: 'Tìm kiếm từ vựng...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), filled: true, fillColor: const Color(0xFFF1F5F9)))),
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF388E3C)]), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStat('${_vocabList.length}', 'Tổng từ'), _buildStat('${_vocabList.where((v) => v['isPublished'] == true).length}', 'Đã xuất bản')])),
        Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : _filteredVocab.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.abc, size: 64, color: Colors.grey[400]), const SizedBox(height: 16), Text(_searchQuery.isEmpty ? 'Chưa có từ vựng nào' : 'Không tìm thấy từ', style: TextStyle(color: Colors.grey[600]))])) : RefreshIndicator(onRefresh: _loadVocabulary, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _filteredVocab.length, itemBuilder: (ctx, i) => _buildVocabCard(_filteredVocab[i])))),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showAddEditDialog(), backgroundColor: const Color(0xFF4CAF50), icon: const Icon(Icons.add, color: Colors.white), label: const Text('Thêm Từ vựng', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildStat(String value, String label) => Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)), Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11))]);

  Widget _buildVocabCard(Map<String, dynamic> vocab) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(vocab['word'].substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(vocab['word'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), if (vocab['phonetic'].isNotEmpty) Text(' ${vocab['phonetic']}', style: TextStyle(color: Colors.grey[600], fontSize: 12))]),
            const SizedBox(height: 4),
            Text(vocab['meaning'], style: TextStyle(color: Colors.grey[700])),
            if (vocab['example'].isNotEmpty) Text(vocab['example'], style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[500], fontSize: 12)),
          ])),
          PopupMenuButton<String>(onSelected: (v) { if (v == 'edit') _showAddEditDialog(vocab: vocab); if (v == 'delete') _deleteVocabulary(vocab); }, itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Sửa')])), const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))]))]),
        ]),
      ),
    );
  }
}
