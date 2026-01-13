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
          'images': List<Map<String, dynamic>>.from(v['images'] ?? []),
          'audios': List<Map<String, dynamic>>.from(v['audios'] ?? []),
          'videos': List<Map<String, dynamic>>.from(v['videos'] ?? []),
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Lỗi tải dữ liệu: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredList {
    if (_searchQuery.isEmpty) return _vocabList;
    return _vocabList.where((v) =>
      v['word'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
      v['meaning'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? vocab}) async {
    final wordController = TextEditingController(text: vocab?['word'] ?? '');
    final phoneticController = TextEditingController(text: vocab?['phonetic'] ?? '');
    final meaningController = TextEditingController(text: vocab?['meaning'] ?? '');
    final exampleController = TextEditingController(text: vocab?['example'] ?? '');
    bool isPublished = vocab?['isPublished'] ?? true;
    
    // Media - support both local files and URLs
    List<String> imagePaths = [];
    List<String> audioPaths = [];
    List<String> videoPaths = [];
    List<String> imageUrls = [];
    List<String> audioUrls = [];
    List<String> videoUrls = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.abc, color: Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        vocab == null ? 'Thêm Từ vựng' : 'Sửa Từ vựng',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: wordController,
                    decoration: InputDecoration(
                      labelText: 'Từ vựng *',
                      hintText: 'VD: beautiful',
                      prefixIcon: const Icon(Icons.text_fields),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneticController,
                    decoration: InputDecoration(
                      labelText: 'Phiên âm',
                      hintText: 'VD: /ˈbjuːtɪfl/',
                      prefixIcon: const Icon(Icons.record_voice_over),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: meaningController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Nghĩa *',
                      hintText: 'VD: đẹp, xinh đẹp',
                      prefixIcon: const Icon(Icons.translate),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: exampleController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ví dụ',
                      hintText: 'VD: She is a beautiful girl.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Media Section
                  const Text('📎 Đính kèm Media', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text('Chọn file từ thiết bị hoặc nhập URL trực tiếp', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  
                  // Image section
                  _buildMediaSection(
                    title: 'Hình ảnh',
                    icon: Icons.image,
                    color: Colors.blue,
                    localPaths: imagePaths,
                    urls: imageUrls,
                    onPickFile: () async {
                      try {
                        final picker = ImagePicker();
                        final images = await picker.pickMultiImage();
                        if (images.isNotEmpty) {
                          setModalState(() {
                            imagePaths.addAll(images.map((e) => e.path));
                          });
                        }
                      } catch (e) {
                        _showError('Không thể mở Gallery: $e');
                      }
                    },
                    onAddUrl: () => _showUrlInputDialog(
                      title: 'Thêm URL hình ảnh',
                      hint: 'https://example.com/image.jpg',
                      onAdd: (url) => setModalState(() => imageUrls.add(url)),
                    ),
                    onRemoveLocal: (i) => setModalState(() => imagePaths.removeAt(i)),
                    onRemoveUrl: (i) => setModalState(() => imageUrls.removeAt(i)),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Audio section
                  _buildMediaSection(
                    title: 'Audio',
                    icon: Icons.audiotrack,
                    color: Colors.orange,
                    localPaths: audioPaths,
                    urls: audioUrls,
                    onPickFile: () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: true);
                        if (result != null) {
                          setModalState(() {
                            audioPaths.addAll(result.paths.whereType<String>());
                          });
                        }
                      } catch (e) {
                        _showError('Không thể mở file picker: $e');
                      }
                    },
                    onAddUrl: () => _showUrlInputDialog(
                      title: 'Thêm URL audio',
                      hint: 'https://example.com/audio.mp3',
                      onAdd: (url) => setModalState(() => audioUrls.add(url)),
                    ),
                    onRemoveLocal: (i) => setModalState(() => audioPaths.removeAt(i)),
                    onRemoveUrl: (i) => setModalState(() => audioUrls.removeAt(i)),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Video section
                  _buildMediaSection(
                    title: 'Video',
                    icon: Icons.videocam,
                    color: Colors.purple,
                    localPaths: videoPaths,
                    urls: videoUrls,
                    onPickFile: () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true);
                        if (result != null) {
                          setModalState(() {
                            videoPaths.addAll(result.paths.whereType<String>());
                          });
                        }
                      } catch (e) {
                        _showError('Không thể mở file picker: $e');
                      }
                    },
                    onAddUrl: () => _showUrlInputDialog(
                      title: 'Thêm URL video',
                      hint: 'https://example.com/video.mp4',
                      onAdd: (url) => setModalState(() => videoUrls.add(url)),
                    ),
                    onRemoveLocal: (i) => setModalState(() => videoPaths.removeAt(i)),
                    onRemoveUrl: (i) => setModalState(() => videoUrls.removeAt(i)),
                  ),
                  
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Đã xuất bản'),
                    value: isPublished,
                    onChanged: (v) => setModalState(() => isPublished = v),
                    activeColor: const Color(0xFF4CAF50),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (wordController.text.isEmpty || meaningController.text.isEmpty) {
                          _showError('Vui lòng nhập từ vựng và nghĩa!');
                          return;
                        }
                        Navigator.pop(ctx);

                        showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

                        Map<String, dynamic> result;
                        if (vocab == null) {
                          // Check if using local files or URLs
                          bool hasLocalFiles = imagePaths.isNotEmpty || audioPaths.isNotEmpty || videoPaths.isNotEmpty;
                          
                          if (hasLocalFiles) {
                            // Upload local files
                            result = await ApiService.createVocabularyWithMedia(
                              lessonId: widget.lessonId,
                              word: wordController.text.trim(),
                              meaning: meaningController.text.trim(),
                              phonetic: phoneticController.text.trim(),
                              example: exampleController.text.trim(),
                              isPublished: isPublished,
                              imagePaths: imagePaths.isNotEmpty ? imagePaths : null,
                              audioPaths: audioPaths.isNotEmpty ? audioPaths : null,
                              videoPaths: videoPaths.isNotEmpty ? videoPaths : null,
                            );
                          } else {
                            // Create without local files (URLs will be handled by backend later or manually)
                            result = await ApiService.createVocabulary(
                              lessonId: widget.lessonId,
                              word: wordController.text.trim(),
                              meaning: meaningController.text.trim(),
                              phonetic: phoneticController.text.trim(),
                              example: exampleController.text.trim(),
                              isPublished: isPublished,
                            );
                          }
                        } else {
                          result = await ApiService.updateVocabulary(vocab['id'], {
                            'word': wordController.text.trim(),
                            'meaning': meaningController.text.trim(),
                            'phonetic': phoneticController.text.trim(),
                            'example': exampleController.text.trim(),
                            'isPublished': isPublished,
                          });
                        }

                        Navigator.pop(context);

                        if (result['error'] != null) {
                          _showError(result['error']);
                        } else {
                          _showSuccess(vocab == null ? 'Tạo thành công!' : 'Cập nhật thành công!');
                          _loadVocabulary();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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
  }

  Widget _buildMediaSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> localPaths,
    required List<String> urls,
    required VoidCallback onPickFile,
    required VoidCallback onAddUrl,
    required Function(int) onRemoveLocal,
    required Function(int) onRemoveUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
              const Spacer(),
              // Pick file button
              TextButton.icon(
                onPressed: onPickFile,
                icon: Icon(Icons.folder_open, size: 16, color: color),
                label: Text('File', style: TextStyle(color: color, fontSize: 12)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
              // Add URL button
              TextButton.icon(
                onPressed: onAddUrl,
                icon: Icon(Icons.link, size: 16, color: color),
                label: Text('URL', style: TextStyle(color: color, fontSize: 12)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
            ],
          ),
          // Show local files
          if (localPaths.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: localPaths.asMap().entries.map((entry) {
                final fileName = entry.value.split('/').last;
                return _buildMediaChip(
                  label: fileName.length > 12 ? '${fileName.substring(0, 12)}...' : fileName,
                  icon: icon,
                  color: color,
                  isUrl: false,
                  onRemove: () => onRemoveLocal(entry.key),
                );
              }).toList(),
            ),
          ],
          // Show URLs
          if (urls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: urls.asMap().entries.map((entry) {
                final url = entry.value;
                final shortUrl = url.length > 20 ? '${url.substring(0, 20)}...' : url;
                return _buildMediaChip(
                  label: shortUrl,
                  icon: Icons.link,
                  color: color,
                  isUrl: true,
                  onRemove: () => onRemoveUrl(entry.key),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isUrl,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUrl ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isUrl ? Border.all(color: color, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _showUrlInputDialog({
    required String title,
    required String hint,
    required Function(String) onAdd,
  }) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            Text('Hỗ trợ: URL (https://...) hoặc đường dẫn (D:/...)', 
                 style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final path = controller.text.trim();
              // Accept: URLs (http/https), local paths (D:/, /path, file://)
              if (path.isNotEmpty) {
                onAdd(path);
                Navigator.pop(ctx);
              } else {
                _showError('Vui lòng nhập đường dẫn!');
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVocabulary(Map<String, dynamic> vocab) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa từ "${vocab['word']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      final result = await ApiService.deleteVocabulary(vocab['id']);
      Navigator.pop(context);

      if (result['error'] != null) {
        _showError(result['error']);
      } else {
        _showSuccess('Đã xóa!');
        _loadVocabulary();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Từ vựng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.lessonTitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
        elevation: 0,
        actions: [IconButton(onPressed: _loadVocabulary, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm từ vựng...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.abc, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text('${_vocabList.length} từ vựng', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.abc, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(_searchQuery.isNotEmpty ? 'Không tìm thấy' : 'Chưa có từ vựng nào', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadVocabulary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredList.length,
                          itemBuilder: (ctx, index) => _buildVocabCard(_filteredList[index], index + 1),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm Từ vựng', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildVocabCard(Map<String, dynamic> vocab, int index) {
    final hasMedia = (vocab['images'] as List).isNotEmpty || (vocab['audios'] as List).isNotEmpty || (vocab['videos'] as List).isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 45, height: 45,
              decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text('$index', style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(vocab['word'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (vocab['phonetic']?.isNotEmpty == true) ...[
                        const SizedBox(width: 8),
                        Text(vocab['phonetic'], style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                      if (hasMedia) ...[const SizedBox(width: 8), Icon(Icons.attach_file, size: 14, color: Colors.grey[500])],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(vocab['meaning'], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  if (vocab['example']?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(vocab['example'], style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  if (hasMedia) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      if ((vocab['images'] as List).isNotEmpty) _buildMediaBadge(Icons.image, Colors.blue, (vocab['images'] as List).length),
                      if ((vocab['audios'] as List).isNotEmpty) _buildMediaBadge(Icons.audiotrack, Colors.orange, (vocab['audios'] as List).length),
                      if ((vocab['videos'] as List).isNotEmpty) _buildMediaBadge(Icons.videocam, Colors.purple, (vocab['videos'] as List).length),
                    ]),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _showAddEditDialog(vocab: vocab);
                if (value == 'delete') _deleteVocabulary(vocab);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Sửa')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaBadge(IconData icon, Color color, int count) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text('$count', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
