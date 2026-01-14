import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  String _sourceLanguage = 'vi';
  String _targetLanguage = 'en';
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  bool _isTranslating = false;

  // OCR & Voice
  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  final Map<String, String> _languages = {
    'vi': 'Tiếng Việt',
    'en': 'Tiếng Anh',
    'fr': 'Tiếng Pháp',
    'ja': 'Tiếng Nhật',
    'ko': 'Tiếng Hàn',
    'zh': 'Tiếng Trung',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  // --- HÀM DỊCH THUẬT ---
  Future<void> _translateText(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _isTranslating = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=$_sourceLanguage|$_targetLanguage'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _translatedText = data['responseData']['translatedText'];
          _isTranslating = false;
        });
      }
    } catch (e) {
      setState(() => _isTranslating = false);
    }
  }

  // --- TÍNH NĂNG CAMERA & OCR ---
  Future<void> _processImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    _showLoadingDialog("Đang quét văn bản...");

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      if (mounted) Navigator.pop(context); // Đóng loading

      if (recognizedText.text.isNotEmpty) {
        _textController.text = recognizedText.text;
        _translateText(recognizedText.text);
      } else {
        _showSnackBar("Không tìm thấy văn bản trong ảnh.");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar("Lỗi nhận diện ảnh.");
    } finally {
      textRecognizer.close();
    }
  }

  // --- TÍNH NĂNG GIỌNG NÓI ---
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textController.text = val.recognizedWords;
            if (val.finalResult) {
              _isListening = false;
              _translateText(val.recognizedWords);
            }
          }),
          localeId: _sourceLanguage == 'vi' ? 'vi_VN' : 'en_US',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showLoadingDialog(String msg) {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      content: Row(children: [const CircularProgressIndicator(), const SizedBox(width: 20), Text(msg)]),
    ));
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Dịch thuật thông minh'), centerTitle: true, elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Chọn ngôn ngữ
            _buildLanguageSelector(),
            const SizedBox(height: 20),
            // Ô nhập liệu
            _buildInputArea(),
            const SizedBox(height: 20),
            // Nút Dịch
            _buildTranslateButton(),
            const SizedBox(height: 20),
            // Kết quả
            _buildResultArea(),
            const SizedBox(height: 24),
            // Nút chức năng phần cứng
            _buildHardwareActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          Expanded(child: _buildDropdown(_sourceLanguage, (v) => setState(() => _sourceLanguage = v!))),
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.blueAccent),
            onPressed: _swapLanguages,
          ),
          Expanded(child: _buildDropdown(_targetLanguage, (v) => setState(() => _targetLanguage = v!))),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Nhập văn bản...', border: InputBorder.none),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(icon: Icon(_isListening ? Icons.stop_circle : Icons.mic, color: _isListening ? Colors.red : Colors.blueAccent), onPressed: _listen),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTranslateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => _translateText(_textController.text),
        child: const Text('Dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildResultArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: _isTranslating ? const Center(child: CircularProgressIndicator()) : Text(_translatedText.isEmpty ? "Kết quả dịch sẽ hiện ở đây" : _translatedText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildHardwareActions() {
    return Row(
      children: [
        _actionBtn(Icons.camera_alt, "Camera", Colors.orange, () => _processImage(ImageSource.camera)),
        const SizedBox(width: 12),
        _actionBtn(Icons.image, "Thư viện", Colors.teal, () => _processImage(ImageSource.gallery)),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.2))),
          child: Column(children: [Icon(icon, color: color), const SizedBox(height: 5), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
        ),
      ),
    );
  }

  Widget _buildDropdown(String val, void Function(String?) onChanged) {
    return DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: val, isExpanded: true,
      items: _languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
      onChanged: onChanged,
    ));
  }
}
