import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/widgets/audio_player_widget.dart';
import 'package:apptienganh10/widgets/media_preview_dialog.dart';

class SubmissionDetailViewScreen extends StatefulWidget {
  final String submissionId;
  final String studentName;
  final String lessonTitle;

  const SubmissionDetailViewScreen({
    super.key,
    required this.submissionId,
    required this.studentName,
    required this.lessonTitle,
  });

  @override
  State<SubmissionDetailViewScreen> createState() => _SubmissionDetailViewScreenState();
}

class _SubmissionDetailViewScreenState extends State<SubmissionDetailViewScreen> {
  Map<String, dynamic>? _detail;
  bool _isLoading = true;
  final _scoreController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final detail = await ApiService.getSubmissionDetailForTeacher(widget.submissionId);
    setState(() {
      _detail = detail;
      _scoreController.text = (detail['totalScore'] ?? '').toString();
      _commentController.text = detail['comment'] ?? '';
      _isLoading = false;
    });
  }

  Future<void> _updateGrade() async {
    final score = double.tryParse(_scoreController.text);
    if (score == null || score < 0 || score > 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập điểm hợp lệ (0-10)')));
      return;
    }

    final result = await ApiService.gradeSubmission(
      widget.submissionId, 
      score,
      comment: _commentController.text,
    );

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${result['error']}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật điểm thành công!')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chi tiết bài làm'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentHeader(),
                  const SizedBox(height: 16),
                  _buildSkillScores(),
                  const Divider(height: 32),
                  const Text('Câu hỏi & Trả lời', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildAnswersList(),
                  const Divider(height: 32),
                  _buildGradingSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildStudentHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 25, child: Icon(Icons.person)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.studentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.lessonTitle, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillScores() {
    final scores = _detail?['scores'] as Map<String, dynamic>?;
    if (scores == null) return const SizedBox.shrink();

    final skillLabels = {
      'vocabulary': 'Từ vựng',
      'grammar': 'Ngữ pháp',
      'reading': 'Đọc hiểu',
      'listening': 'Nghe',
      'speaking': 'Nói',
      'writing': 'Viết',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Điểm theo kỹ năng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skillLabels.entries.map((e) {
            final val = (scores[e.key] ?? 0.0).toDouble();
            if (val == 0 && scores[e.key] == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${e.value}: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text('$val', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnswersList() {
    final answers = _detail?['answers'] as List? ?? [];
    if (answers.isEmpty) return const Text('Không tìm thấy dữ liệu câu hỏi trong bài nộp.');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: answers.length,
      itemBuilder: (ctx, i) {
        final ans = answers[i];
        final question = ans['question'];
        final isCorrect = ans['isCorrect'] == true;

        if (question == null) return const SizedBox();

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('Câu ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
                    ),
                    const Spacer(),
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(question['content'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 12),
                
                // Question Media
                if ((question['images'] as List?)?.isNotEmpty == true)
                  GestureDetector(
                    onTap: () => MediaPreviewDialog.show(context, (question['images'] as List).first is Map 
                        ? (question['images'] as List).first['url'] 
                        : (question['images'] as List).first.toString()),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            (question['images'] as List).first is Map 
                                ? (question['images'] as List).first['url'] 
                                : (question['images'] as List).first.toString(),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(right: 8, bottom: 8, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle), child: const Icon(Icons.zoom_in, color: Colors.white, size: 20))),
                      ],
                    ),
                  ),
                
                if ((question['audios'] as List?)?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AudioPlayerWidget(
                      url: (question['audios'] as List).first is Map 
                          ? (question['audios'] as List).first['url']
                          : (question['audios'] as List).first.toString(),
                    ),
                  ),

                const SizedBox(height: 16),
                _buildAnswerDetail(ans, question, isCorrect),
                if (!isCorrect) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.1))),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Đáp án đúng: ${question['correctAnswer']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerDetail(dynamic ans, dynamic question, bool isCorrect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Học sinh trả lời:', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.withOpacity(0.02) : Colors.red.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
          ),
          child: Text(
            ans['userAnswer']?.toString() ?? 'Không có câu trả lời', 
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.bold, 
              color: isCorrect ? Colors.green[700] : Colors.red[700]
            )
          ),
        ),
      ],
    );
  }

  Widget _buildGradingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chấm điểm & Nhận xét', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _scoreController,
                  decoration: InputDecoration(
                    labelText: 'Điểm số (0-10)',
                    hintText: '8.5',
                    prefixIcon: const Icon(Icons.grade),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _updateGrade,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Lưu kết quả'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Lời nhắn cho học sinh',
              hintText: 'Làm bài tốt, cần chú ý phần nghe hơn...',
              prefixIcon: const Icon(Icons.comment_outlined),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

}
