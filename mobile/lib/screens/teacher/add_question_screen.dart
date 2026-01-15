import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/widgets/audio_player_widget.dart';
import 'package:apptienganh10/widgets/media_preview_dialog.dart';

class AddQuestionScreen extends StatefulWidget {
  final String examId;
  final Map<String, dynamic>? questionData;

  const AddQuestionScreen({
    super.key, 
    required this.examId, 
    this.questionData,
  });

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _explanationController = TextEditingController();
  final _pointsController = TextEditingController(text: "1.0");

  String _selectedSkill = "reading";
  String _selectedType = "mcq"; 

  // Multiple Choice (mcq)
  final List<TextEditingController> _mcqOptions = List.generate(4, (_) => TextEditingController());
  int _mcqCorrectIndex = 0;

  // Ordering
  final List<TextEditingController> _orderItems = [TextEditingController(), TextEditingController()];

  // True/False
  bool _tfCorrect = true;

  // Short Answer / Fill Blank
  final _correctAnswerController = TextEditingController();

  // Media
  File? _selectedImage;
  File? _selectedAudio;
  String? _existingImageUrl;
  String? _existingAudioUrl;

  final ImagePicker _picker = ImagePicker();

  bool get _isEditMode => widget.questionData != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _initializeData();
    }
  }

  void _initializeData() {
    final q = widget.questionData!;
    _contentController.text = q['content'] ?? '';
    _explanationController.text = q['explanation'] ?? '';
    _pointsController.text = (q['points'] ?? 1.0).toString();
    _selectedSkill = q['skill'] ?? 'reading';
    _selectedType = q['type'] ?? 'mcq';

    if (_selectedType == 'mcq') {
      final options = q['options'] as List?;
      if (options != null) {
        for (int i = 0; i < options.length && i < _mcqOptions.length; i++) {
          _mcqOptions[i].text = options[i].toString();
        }
      }
      _mcqCorrectIndex = int.tryParse(q['correctAnswer']?.toString() ?? '0') ?? 0;
    } else if (_selectedType == 'true_false') {
      _tfCorrect = q['correctAnswer'] == true || q['correctAnswer']?.toString() == 'true';
    } else if (_selectedType == 'ordering') {
      final items = q['correctAnswer']?.toString().split('|') ?? [];
      _orderItems.clear();
      for (var item in items) {
        _orderItems.add(TextEditingController(text: item));
      }
      if (_orderItems.isEmpty) {
        _orderItems.addAll([TextEditingController(), TextEditingController()]);
      }
    } else {
      _correctAnswerController.text = q['correctAnswer']?.toString() ?? '';
    }

    // Load existing media URLs
    final images = q['images'] as List?;
    if (images != null && images.isNotEmpty) {
      final img = images.first;
      _existingImageUrl = img is Map ? img['url'] : img.toString();
    }

    final audios = q['audios'] as List?;
    if (audios != null && audios.isNotEmpty) {
      final aud = audios.first;
      _existingAudioUrl = aud is Map ? aud['url'] : aud.toString();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) setState(() => _selectedAudio = File(result.files.single.path!));
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));

    try {
      dynamic finalCorrectAnswer;
      List<String>? options;

      if (_selectedType == 'mcq') {
        options = _mcqOptions.map((e) => e.text).toList();
        finalCorrectAnswer = _mcqCorrectIndex;
      } else if (_selectedType == 'true_false') {
        finalCorrectAnswer = _tfCorrect;
      } else if (_selectedType == 'ordering') {
        finalCorrectAnswer = _orderItems.map((e) => e.text).join('|');
      } else {
        finalCorrectAnswer = _correctAnswerController.text;
      }

      if (_isEditMode) {
        await ApiService.updateQuestionForTeacher(
          id: widget.questionData!['_id'],
          skill: _selectedSkill,
          type: _selectedType,
          content: _contentController.text,
          options: options,
          correctAnswer: finalCorrectAnswer,
          explanation: _explanationController.text,
          points: double.tryParse(_pointsController.text) ?? 1.0,
          images: _selectedImage != null ? [_selectedImage!] : null,
          audios: _selectedAudio != null ? [_selectedAudio!] : null,
        );
      } else {
        await ApiService.createQuestionForTeacher(
          examId: widget.examId,
          skill: _selectedSkill,
          type: _selectedType,
          content: _contentController.text,
          options: options,
          correctAnswer: finalCorrectAnswer,
          explanation: _explanationController.text,
          points: double.tryParse(_pointsController.text) ?? 1.0,
          images: _selectedImage != null ? [_selectedImage!] : null,
          audios: _selectedAudio != null ? [_selectedAudio!] : null,
        );
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading
      Navigator.pop(context, true); // Return to list
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditMode ? 'Cập nhật câu hỏi thành công!' : 'Tạo câu hỏi thành công!')));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Chỉnh Sửa Câu Hỏi' : 'Thêm Câu Hỏi', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown('Kỹ năng', _selectedSkill, ['listening', 'speaking', 'reading', 'writing'], (v) => setState(() => _selectedSkill = v!)),
              const SizedBox(height: 20),
              _buildDropdown('Loại câu hỏi', _selectedType, ['mcq', 'fill_blank', 'ordering', 'true_false', 'short_answer'], (v) => setState(() => _selectedType = v!)),
              const SizedBox(height: 25),
              _buildLabel('Nội dung câu hỏi'),
              TextFormField(controller: _contentController, maxLines: 2, decoration: _inputDeco('Nhập câu hỏi...'), validator: (v) => v!.isEmpty ? 'Vui lòng nhập nội dung' : null),
              const SizedBox(height: 25),
              _buildDynamicEditor(),
              const SizedBox(height: 25),
              _buildMediaSection(),
              const SizedBox(height: 25),
              _buildLabel('Giải thích đáp án (Nếu có)'),
              TextFormField(controller: _explanationController, decoration: _inputDeco('Tại sao đáp án này đúng?')),
              const SizedBox(height: 25),
              _buildLabel('Điểm số'),
              TextFormField(controller: _pointsController, keyboardType: TextInputType.number, decoration: _inputDeco('Ví dụ: 1.0')),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _saveQuestion, style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(_isEditMode ? 'CẬP NHẬT CÂU HỎI' : 'LƯU CÂU HỎI', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(label),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(), onChanged: onChanged)),
      ),
    ]);
  }

  Widget _buildDynamicEditor() {
    switch (_selectedType) {
      case 'mcq': return _buildMcqEditor();
      case 'true_false': return _buildTFEditor();
      case 'ordering': return _buildOrderingEditor();
      case 'fill_blank':
      case 'short_answer': return _buildTextAnswerEditor();
      default: return const SizedBox();
    }
  }

  Widget _buildMcqEditor() {
    return Column(children: List.generate(4, (i) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Radio<int>(value: i, groupValue: _mcqCorrectIndex, onChanged: (v) => setState(() => _mcqCorrectIndex = v!)),
        Expanded(child: TextFormField(controller: _mcqOptions[i], decoration: _inputDeco('Đáp án ${String.fromCharCode(65 + i)}'))),
      ]),
    )));
  }

  Widget _buildTFEditor() {
    return Column(children: [
      _buildLabel('Đáp án đúng'),
      Row(children: [
        Expanded(child: ChoiceChip(label: const Center(child: Text('ĐÚNG')), selected: _tfCorrect, onSelected: (v) => setState(() => _tfCorrect = true))),
        const SizedBox(width: 15),
        Expanded(child: ChoiceChip(label: const Center(child: Text('SAI')), selected: !_tfCorrect, onSelected: (v) => setState(() => _tfCorrect = false))),
      ]),
    ]);
  }

  Widget _buildOrderingEditor() {
    return Column(children: [
      _buildLabel('Nhập các phần theo thứ tự ĐÚNG'),
      ..._orderItems.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          CircleAvatar(radius: 12, child: Text('${e.key + 1}', style: const TextStyle(fontSize: 10))),
          const SizedBox(width: 10),
          Expanded(child: TextFormField(controller: e.value, decoration: _inputDeco('Phần nội dung...'))),
          IconButton(onPressed: () => setState(() => _orderItems.removeAt(e.key)), icon: const Icon(Icons.remove_circle, color: Colors.red))
        ]),
      )),
      TextButton.icon(onPressed: () => setState(() => _orderItems.add(TextEditingController())), icon: const Icon(Icons.add), label: const Text('Thêm phần mới'))
    ]);
  }

  Widget _buildTextAnswerEditor() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(_selectedType == 'fill_blank' ? 'Từ/Cụm từ cần điền' : 'Đáp án chấp nhận được'),
      TextFormField(controller: _correctAnswerController, decoration: _inputDeco('Nhập đáp án chính xác...')),
    ]);
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: _pickImage, 
            icon: const Icon(Icons.image), 
            label: Text(_selectedImage == null && _existingImageUrl == null ? 'Thêm Ảnh' : 'Đổi Ảnh'), 
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12))
          )),
          const SizedBox(width: 15),
          Expanded(child: OutlinedButton.icon(
            onPressed: _pickAudio, 
            icon: const Icon(Icons.audiotrack), 
            label: Text(_selectedAudio == null && _existingAudioUrl == null ? 'Thêm Audio' : 'Đổi Audio'), 
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12))
          )),
        ]),
        
        // Image Preview
        if (_selectedImage != null || _existingImageUrl != null) ...[
          const SizedBox(height: 15),
          _buildLabel('Xem trước ảnh'),
          GestureDetector(
            onTap: () => MediaPreviewDialog.show(context, _selectedImage != null ? 'file://${_selectedImage!.path}' : _existingImageUrl!),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImage != null 
                    ? Image.file(_selectedImage!, height: 180, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(_existingImageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedImage = null;
                      _existingImageUrl = null;
                    }),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Xem lớn', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Audio Preview
        if (_selectedAudio != null || _existingAudioUrl != null) ...[
          const SizedBox(height: 15),
          _buildLabel('Nghe thử Audio'),
          Stack(
            children: [
              AudioPlayerWidget(
                file: _selectedAudio,
                url: _selectedAudio == null ? _existingAudioUrl : null,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => setState(() {
                    _selectedAudio = null;
                    _existingAudioUrl = null;
                  }),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))));
  InputDecoration _inputDeco(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF8FAFC), contentPadding: const EdgeInsets.all(15), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))));
}
