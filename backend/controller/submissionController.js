import Submission from "../models/Submission.js";
import Question from "../models/Question.js";
import Class from "../models/Class.js";
import Lesson from "../models/Lesson.js";

/* ================= SUBMIT LESSON ================= */
export const submitLesson = async (req, res) => {
  try {
    const { lessonId, answers } = req.body;
    const userId = req.user.id;

    if (!lessonId || !Array.isArray(answers)) {
      return res.status(400).json({ message: "Thiếu dữ liệu submit" });
    }

    /* ===== CHECK DEADLINE ===== */
    if (req.user.role === "student") {
      const lesson = await Lesson.findById(lessonId).select("deadline").lean();

      // FIX TIMEZONE: Cộng 7 tiếng để khớp với giờ Face Value trong DB
      const now = new Date(Date.now() + 7 * 60 * 60 * 1000);

      if (lesson && lesson.deadline && now > new Date(lesson.deadline)) {
        return res.status(403).json({
          message: "Đã hết hạn nộp bài cho bài tập này",
          deadline: lesson.deadline,
        });
      }
    }

    const scores = {
      vocabulary: 0,
      grammar: 0,
      reading: 0,
      listening: 0,
      speaking: 0,
      writing: 0,
    };

    let totalScore = 0;
    const checkedAnswers = [];

    for (const ans of answers) {
      const question = await Question.findById(ans.question).lean();
      if (!question) continue;

      let isCorrect = null;

      if (question.type !== "essay") {
        isCorrect =
          JSON.stringify(ans.userAnswer) ===
          JSON.stringify(question.correctAnswer);
      }

      checkedAnswers.push({
        question: ans.question,
        userAnswer: ans.userAnswer,
        isCorrect,
        pointsAwarded: isCorrect ? (question.points || 1) : 0,
      });

      if (isCorrect) {
        const p = question.points || 1;
        scores[question.skill] += p;
        totalScore += p;
      }
    }

    const submission = await Submission.create({
      user: userId,
      lesson: lessonId,
      answers: checkedAnswers,
      scores,
      totalScore,
    });

    res.status(201).json({
      message: "Nộp bài thành công",
      submissionId: submission._id,
      scores,
      totalScore,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= STUDENT: VIEW OWN SUBMISSION ================= */
export const getSubmissionById = async (req, res) => {
  try {
    const submission = await Submission.findById(req.params.id)
      .populate("lesson", "title lessonType")
      .lean();

    if (!submission) {
      return res.status(404).json({ message: "Không tìm thấy bài làm" });
    }

    if (submission.user.toString() !== req.user.id) {
      return res.status(403).json({ message: "Không có quyền xem bài này" });
    }

    res.json({
      lesson: submission.lesson,
      scores: submission.scores,
      totalScore: submission.totalScore,
      answers: submission.answers,
      submittedAt: submission.submittedAt,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= STUDENT: VIEW ALL SUBMISSIONS ================= */
export const getMySubmissions = async (req, res) => {
  try {
    const submissions = await Submission.find({ user: req.user.id })
      .populate("lesson", "title lessonType")
      .sort({ createdAt: -1 })
      .lean();

    const result = submissions.map((sub) => ({
      submissionId: sub._id,
      lesson: sub.lesson,
      scores: sub.scores,
      totalScore: sub.totalScore,
      submittedAt: sub.submittedAt,
    }));

    res.json({
      total: result.length,
      data: result,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= TEACHER: VIEW SCORES BY LESSON ================= */
export const getScoresByLesson = async (req, res) => {
  try {
    const { lessonId } = req.params;

    // 1. Tìm lớp chủ nhiệm của giáo viên
    const teacherClass = await Class.findOne({
      homeroomTeacher: req.user._id,
      isActive: true,
    });

    if (!teacherClass) {
      return res.status(403).json({
        message: "Bạn không phải giáo viên chủ nhiệm lớp nào",
      });
    }

    // 2. Chỉ lấy bài nộp của học sinh trong lớp này
    const submissions = await Submission.find({
      lesson: lessonId,
      user: { $in: teacherClass.students }, // ⭐ CHỈ LẤY CỦA HỌC SINH LỚP MÌNH
    })
      .populate("user", "username email fullName")
      .sort({ createdAt: -1 })
      .lean();

    const result = submissions.map((sub) => ({
      submissionId: sub._id,
      student: {
        id: sub.user._id,
        username: sub.user.username,
        email: sub.user.email,
        fullName: sub.user.fullName || sub.user.username,
      },
      scores: sub.scores,
      totalScore: sub.totalScore,
      submittedAt: sub.submittedAt,
    }));

    res.json({
      className: teacherClass.name, // Trả thêm tên lớp cho FE dễ hiển thị
      totalStudents: result.length,
      data: result,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= TEACHER: VIEW SUBMISSION DETAIL (ESSAY) ================= */
export const getSubmissionDetailForTeacher = async (req, res) => {
  try {
    // 1. Tìm bài làm
    const submission = await Submission.findById(req.params.id)
      .populate("user", "username email")
      .populate("lesson", "title lessonType")
      .populate("answers.question", "content type skill")
      .lean();

    if (!submission) {
      return res.status(404).json({ message: "Không tìm thấy bài làm" });
    }

    // 2. Kiểm tra quyền của giáo viên (phải là GVCN của học sinh này)
    const teacherClass = await Class.findOne({
      homeroomTeacher: req.user._id,
      students: submission.user._id, // Kiểm tra xem học sinh có trong list students không
      isActive: true,
    });

    if (!teacherClass) {
      return res.status(403).json({
        message: "Học sinh này không thuộc lớp chủ nhiệm của bạn",
      });
    }

    res.json({
      student: {
        id: submission.user._id,
        username: submission.user.username,
        email: submission.user.email,
        fullName: submission.user.fullName || submission.user.username,
      },
      lesson: submission.lesson,
      scores: submission.scores,
      totalScore: submission.totalScore,
      answers: submission.answers.map((a) => ({
        question: a.question.content,
        type: a.question.type,
        skill: a.question.skill,
        userAnswer: a.userAnswer,
        isCorrect: a.isCorrect,
        pointsAwarded: a.pointsAwarded || 0,
      })),
      submittedAt: submission.submittedAt,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
