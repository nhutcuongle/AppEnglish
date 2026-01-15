import 'dart:async';
import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';

class ExamDetailScreen extends StatefulWidget {
  final String examId;
  final String title;
  final DateTime endTime;

  const ExamDetailScreen({
    super.key,
    required this.examId,
    required this.title,
    required this.endTime,
  });

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  bool isLoading = true;
  bool isSubmitting = false;
  bool isCheckingSubmission = true;
  Map<String, dynamic>? submittedResult; // Store previous result
  List<dynamic> questions = [];
  Map<String, dynamic> userAnswers = {};
  
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
  }

  Future<void> _checkSubmissionStatus() async {
    try {
      final submissions = await ApiService.getMySubmissions();
      print('CHECKING SUBMISSIONS: Found ${submissions.length} items');
      
      // Find submission for this exam
      final submission = submissions.firstWhere(
        (s) {
          final sExam = s['exam'];
          print('Item: ${s['_id']} - Exam: $sExam vs Widget: ${widget.examId}');
          
          if (sExam is Map) return sExam['_id'] == widget.examId;
          return sExam == widget.examId;
        },
        orElse: () => null,
      );

      if (submission != null) {
        if (mounted) {
          setState(() {
            submittedResult = submission;
            isLoading = false;
            isCheckingSubmission = false;
          });
        }
      } else {
        // Not submitted yet, load questions
        if (mounted) setState(() => isCheckingSubmission = false);
        _fetchQuestions();
        _startTimer();
      }
    } catch (e) {
      print("Error checking submission: $e");
      // Fallback to loading exam if check fails (or handle error)
       if (mounted) setState(() => isCheckingSubmission = false);
       _fetchQuestions();
       _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final now = DateTime.now();
    if (now.isAfter(widget.endTime)) {
      _timeLeft = Duration.zero;
      // Exam ended
    } else {
      _timeLeft = widget.endTime.difference(now);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            final currentNow = DateTime.now();
            if (currentNow.isAfter(widget.endTime)) {
              _timeLeft = Duration.zero;
              timer.cancel();
              _autoSubmit();
            } else {
              _timeLeft = widget.endTime.difference(currentNow);
            }
          });
        }
      });
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final data = await ApiService.getExamQuestions(widget.examId);
      if (mounted) {
        setState(() {
          questions = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      
      String errorMsg = e.toString();
      debugPrint("=== FETCH QUESTIONS ERROR: $errorMsg ==="); // Log trace
      
      // Improve error display
      if (errorMsg.contains("403")) {
         errorMsg = "Chưa đến giờ làm bài (Lỗi đồng bộ thời gian từ máy chủ). Vui lòng thử lại sau.";
      }
      _showError("Lỗi tải câu hỏi: $errorMsg");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _submit() async {
    // Confirm dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nộp bài"),
        content: const Text("Bạn có chắc chắn muốn nộp bài không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Nộp")),
        ],
      ),
    );

    if (confirm == true) {
      await _executeSubmit();
    }
  }

  Future<void> _autoSubmit() async {
    if (isSubmitting) return;
    _showError("Hết giờ làm bài! Hệ thống đang tự động nộp bài...");
    await _executeSubmit();
  }

  Future<void> _executeSubmit() async {
    setState(() => isSubmitting = true);

    final List<Map<String, dynamic>> submitData = [];
    userAnswers.forEach((key, value) {
      submitData.add({
        "question": key,
        "userAnswer": value,
      });
    });

    try {
      final result = await ApiService.submitExam(
        examId: widget.examId,
        answers: submitData,
      );

      if (mounted) {
        if (result.containsKey('error')) {
          _showError(result['error']);
          setState(() => isSubmitting = false);
        } else {
          // Success
          _showResultDialog(result['totalScore']);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError("Lỗi nộp bài: $e");
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showResultDialog(dynamic score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Hoàn thành"),
        content: Text("Nộp bài thành công!\nĐiểm số của bạn: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Back to list
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // Check if time is up initially
    // Check for existing submission
    if (submittedResult != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(16),
               boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text("Bạn đã hoàn thành bài kiểm tra này!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text("Điểm số: ${submittedResult!['totalScore']}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                  child: const Text("Quay lại"),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(_timeLeft),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? const Center(child: Text("Không có câu hỏi nào."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: questions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          return _buildQuestionItem(index, questions[index]);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                          child: isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("NỘP BÀI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildQuestionItem(int index, dynamic q) {
    final String type = q['type'] ?? 'mcq';
    final String content = q['content'] ?? '';
    final String qId = q['_id'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Câu ${index + 1}: $content", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (type == 'mcq') _buildMCQ(qId, q['options'])
            else if (type == 'true_false') _buildTrueFalse(qId)
            else if (type == 'fill_blank') _buildFillBlank(qId)
            else if (type == 'essay') _buildEssay(qId)
            else Text("Loại câu hỏi đang cập nhật: $type", style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildMCQ(String qId, List<dynamic>? options) {
    if (options == null) return const Text("Không có đáp án");
    return Column(
      children: options.map((opt) {
        return RadioListTile<String>(
          title: Text(opt.toString()),
          value: opt.toString(),
          groupValue: userAnswers[qId],
          onChanged: (val) {
            setState(() {
              userAnswers[qId] = val;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalse(String qId) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text("True"),
          value: "True",
          groupValue: userAnswers[qId],
          onChanged: (val) => setState(() => userAnswers[qId] = val),
        ),
        RadioListTile<String>(
          title: const Text("False"),
          value: "False",
          groupValue: userAnswers[qId],
          onChanged: (val) => setState(() => userAnswers[qId] = val),
        ),
      ],
    );
  }

  Widget _buildFillBlank(String qId) {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Nhập câu trả lời của bạn...",
      ),
      onChanged: (val) {
        userAnswers[qId] = val;
      },
    );
  }
  
  Widget _buildEssay(String qId) {
     return TextField(
      maxLines: 4,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Nhập câu trả lời tự luận...",
      ),
      onChanged: (val) {
        userAnswers[qId] = val;
      },
    );
  }
}
