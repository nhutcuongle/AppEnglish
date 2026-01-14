import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';

class LessonExerciseScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const LessonExerciseScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<LessonExerciseScreen> createState() => _LessonExerciseScreenState();
}

class _LessonExerciseScreenState extends State<LessonExerciseScreen> {
  bool isLoading = true;
  bool isSubmitting = false;
  List<dynamic> questions = [];
  Map<String, dynamic> userAnswers = {}; // Map<QuestionId, Answer>
  
  // Submission đã làm trước đó (nếu có)
  Map<String, dynamic>? previousSubmission;
  Map<String, dynamic> previousAnswersMap = {}; // Map<QuestionId, AnswerInfo>
  bool isViewingResult = false; // Mode xem kết quả

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch questions
      final questionsData = await ApiService.getQuestions(lessonId: widget.lessonId);
      
      // Fetch previous submission for this lesson
      final mySubmissions = await ApiService.getMySubmissions();
      Map<String, dynamic>? existingSubmission;
      
      for (var sub in mySubmissions) {
        final lesson = sub['lesson'];
        final lessonId = lesson is Map ? lesson['_id'] : lesson;
        if (lessonId == widget.lessonId) {
          // Lấy submission chi tiết
          final details = await ApiService.getSubmissionById(sub['submissionId']);
          if (details != null && details['answers'] != null) {
            existingSubmission = details;
            // Tạo map để tra cứu nhanh
            for (var ans in details['answers'] ?? []) {
              previousAnswersMap[ans['question']] = {
                'userAnswer': ans['userAnswer'],
                'isCorrect': ans['isCorrect'],
                'pointsAwarded': ans['pointsAwarded'],
              };
            }
          }
          break;
        }
      }
      
      if (mounted) {
        setState(() {
          questions = questionsData;
          previousSubmission = existingSubmission;
          isViewingResult = existingSubmission != null;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _submit() async {
    if (userAnswers.isEmpty) {
      _showError("Bạn chưa trả lời câu hỏi nào!");
      return;
    }

    final List<Map<String, dynamic>> submitData = [];
    userAnswers.forEach((key, value) {
      submitData.add({
        "question": key,
        "userAnswer": value,
      });
    });

    setState(() => isSubmitting = true);

    try {
      final result = await ApiService.submitLesson(
        lessonId: widget.lessonId,
        answers: submitData,
      );

      if (result.containsKey('error')) {
        _showError(result['error']);
      } else {
        _showResultDialog(result);
      }
    } catch (e) {
      _showError("Lỗi nộp bài: $e");
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final double totalScore = (result['totalScore'] ?? 0).toDouble();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Kết quả"),
        content: Text("Chúc mừng bạn đã hoàn thành bài tập!\n\nĐiểm số: $totalScore"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _switchToDoAgain() {
    setState(() {
      isViewingResult = false;
      userAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bài tập: ${widget.lessonTitle}"),
        backgroundColor: Colors.blue,
        actions: [
          if (previousSubmission != null)
            TextButton.icon(
              onPressed: () {
                setState(() => isViewingResult = !isViewingResult);
              },
              icon: Icon(isViewingResult ? Icons.edit : Icons.visibility, color: Colors.white),
              label: Text(
                isViewingResult ? "Làm lại" : "Xem kq",
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? const Center(child: Text("Bài học này chưa có câu hỏi nào."))
              : Column(
                  children: [
                    // Thông báo nếu đã làm trước đó
                    if (previousSubmission != null && isViewingResult)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Colors.green.shade100,
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Bạn đã làm bài này - Điểm: ${previousSubmission!['totalScore'] ?? 0}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    // Bottom button
                    if (!isViewingResult)
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
    final String? correctAnswer = q['correctAnswer'];
    
    // Kiểm tra xem có đáp án cũ không
    final previousAnswer = previousAnswersMap[qId];
    final bool? wasCorrect = previousAnswer?['isCorrect'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Đổi màu card nếu đang xem kết quả
      color: isViewingResult && wasCorrect != null
          ? (wasCorrect ? Colors.green.shade50 : Colors.red.shade50)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text("Câu ${index + 1}: $content", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                // Icon kết quả
                if (isViewingResult && wasCorrect != null)
                  Icon(
                    wasCorrect ? Icons.check_circle : Icons.cancel,
                    color: wasCorrect ? Colors.green : Colors.red,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (type == 'mcq') _buildMCQ(qId, q['options'], correctAnswer)
            else if (type == 'true_false') _buildTrueFalse(qId, correctAnswer)
            else if (type == 'fill_blank') _buildFillBlank(qId, correctAnswer)
            else if (type == 'essay') _buildEssay(qId)
            else Text("Loại câu hỏi đang cập nhật: $type", style: const TextStyle(color: Colors.red)),
            
            // Hiển thị đáp án đúng nếu đang xem kết quả và trả lời sai
            if (isViewingResult && wasCorrect == false && correctAnswer != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Đáp án đúng: $correctAnswer",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMCQ(String qId, List<dynamic>? options, String? correctAnswer) {
    if (options == null) return const Text("Không có đáp án");
    
    final previousAnswer = previousAnswersMap[qId];
    final String? previousUserAnswer = previousAnswer?['userAnswer']?.toString();
    
    return Column(
      children: options.map((opt) {
        final String optStr = opt.toString();
        final bool isUserPreviousAnswer = isViewingResult && previousUserAnswer == optStr;
        final bool isCorrectAnswer = isViewingResult && correctAnswer == optStr;
        
        return RadioListTile<String>(
          title: Row(
            children: [
              Expanded(child: Text(optStr)),
              if (isUserPreviousAnswer && !isCorrectAnswer)
                const Icon(Icons.close, color: Colors.red, size: 20),
              if (isCorrectAnswer)
                const Icon(Icons.check, color: Colors.green, size: 20),
            ],
          ),
          value: optStr,
          groupValue: isViewingResult ? previousUserAnswer : userAnswers[qId],
          activeColor: isViewingResult 
              ? (previousUserAnswer == correctAnswer ? Colors.green : Colors.red)
              : null,
          onChanged: isViewingResult ? null : (val) {
            setState(() {
              userAnswers[qId] = val;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalse(String qId, String? correctAnswer) {
    final previousAnswer = previousAnswersMap[qId];
    final String? previousUserAnswer = previousAnswer?['userAnswer']?.toString();
    
    return Column(
      children: ["True", "False"].map((opt) {
        final bool isUserPreviousAnswer = isViewingResult && previousUserAnswer == opt;
        final bool isCorrectAnswer = isViewingResult && correctAnswer == opt;
        
        return RadioListTile<String>(
          title: Row(
            children: [
              Text(opt),
              if (isUserPreviousAnswer && !isCorrectAnswer)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.close, color: Colors.red, size: 20),
                ),
              if (isCorrectAnswer)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: Colors.green, size: 20),
                ),
            ],
          ),
          value: opt,
          groupValue: isViewingResult ? previousUserAnswer : userAnswers[qId],
          activeColor: isViewingResult 
              ? (previousUserAnswer == correctAnswer ? Colors.green : Colors.red)
              : null,
          onChanged: isViewingResult ? null : (val) => setState(() => userAnswers[qId] = val),
        );
      }).toList(),
    );
  }

  Widget _buildFillBlank(String qId, String? correctAnswer) {
    final previousAnswer = previousAnswersMap[qId];
    final String? previousUserAnswer = previousAnswer?['userAnswer']?.toString();
    final bool? wasCorrect = previousAnswer?['isCorrect'];
    
    if (isViewingResult && previousUserAnswer != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Đáp án của bạn: $previousUserAnswer",
            style: TextStyle(
              color: wasCorrect == true ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    
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
    final previousAnswer = previousAnswersMap[qId];
    final String? previousUserAnswer = previousAnswer?['userAnswer']?.toString();
    
    if (isViewingResult && previousUserAnswer != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(previousUserAnswer),
      );
    }
    
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
