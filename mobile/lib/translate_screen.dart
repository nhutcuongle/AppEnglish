import 'package:flutter/material.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  String _sourceLanguage = 'Vietnamese';
  String _targetLanguage = 'English';
  final TextEditingController _textController = TextEditingController();
  
  // Biến trạng thái giả lập quá trình dịch
  bool _isTranslating = false;
  String _translationResult = "...";

  // Hàm giả lập dịch (Fake API Call)
  void _simulateTranslation() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập văn bản để dịch")));
      return;
    }

    // Tắt bàn phím
    FocusScope.of(context).unfocus();

    setState(() {
      _isTranslating = true;
      _translationResult = "Đang dịch...";
    });

    // Giả lập độ trễ mạng 1.5 giây
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isTranslating = false;
        // Logic giả: Luôn trả về kết quả mẫu để demo, hoặc đảo ngược chuỗi nếu muốn vui
        if (_targetLanguage == 'English') {
          _translationResult = "This is a simulated translation result for demonstration purposes.";
        } else {
          _translationResult = "Đây là kết quả dịch mô phỏng cho mục đích demo.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dịch Thuật & Camera'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language Selectors
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDropdown(_sourceLanguage, (val) => setState(() => _sourceLanguage = val!)),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        final temp = _sourceLanguage;
                        _sourceLanguage = _targetLanguage;
                        _targetLanguage = temp;
                      });
                    },
                    icon: Icon(Icons.swap_horiz, color: theme.primaryColor),
                  ),
                  _buildDropdown(_targetLanguage, (val) => setState(() => _targetLanguage = val!)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Input Area
            Stack(
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Nhập văn bản cần dịch...',
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.mic, color: theme.primaryColor),
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng giọng nói đang phát triển")));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTranslating ? null : _simulateTranslation,
                    icon: _isTranslating 
                        ? Container(width: 20, height: 20, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.translate, size: 20, color: Colors.white),
                    label: Text(_isTranslating ? "Đang xử lý..." : "Dịch ngay", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildIconButton(Icons.camera_alt, theme.primaryColor.withOpacity(0.1), theme.primaryColor),
                const SizedBox(width: 12),
                _buildIconButton(Icons.image, theme.primaryColor.withOpacity(0.1), theme.primaryColor),
              ],
            ),
            const SizedBox(height: 32),

            // Result Area
            Text("Kết quả dịch", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _translationResult, 
                    style: TextStyle(
                      color: _translationResult == "..." ? Colors.grey[600] : Colors.black87, 
                      fontStyle: _translationResult == "..." ? FontStyle.italic : FontStyle.normal, 
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_translationResult != "..." && _translationResult != "Đang dịch...")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy, size: 20, color: Colors.grey[400]),
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép")));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up, size: 20, color: Colors.grey[400]),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, void Function(String?) onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        items: ['Vietnamese', 'English', 'French', 'Japanese'].map((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
      ),
    );
  }
  
  Widget _buildIconButton(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng Camera đang phát triển")));
        },
        icon: Icon(icon, color: iconColor),
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
