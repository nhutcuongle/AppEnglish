import Submission from "../models/Submission.js";
import Question from "../models/Question.js";
import Class from "../models/Class.js";
import Lesson from "../models/Lesson.js";
import User from "../models/User.js";

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
      const lesson = await Lesson.findById(lessonId)
        .select("deadline")
        .lean();

      if (lesson && lesson.deadline && new Date() > new Date(lesson.deadline)) {
        return res.status(403).json({
          message: "Đã hết hạn nộp bài cho bài tập này",
          deadline: lesson.deadline
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

    /* ===== UPDATE STUDENT TOTAL PROGRESS & SCORE ===== */
    const allSubmissions = await Submission.find({ user: userId }).lean();
    if (allSubmissions.length > 0) {
      const totalPoints = allSubmissions.reduce((acc, curr) => acc + (curr.totalScore || 0), 0);
      const avgScore = totalPoints / allSubmissions.length;

      // Calculate progress roughly as percentage of total available lessons (mock/simple)
      const totalLessons = await Lesson.countDocuments({ isPublished: true });
      const progress = totalLessons > 0 ? allSubmissions.length / totalLessons : 0;

      await User.findByIdAndUpdate(userId, {
        score: avgScore,
        progress: progress > 1 ? 1 : progress
      });
    }

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

    // 1. Tìm lớp giáo viên tham gia (chủ nhiệm hoặc được gán)
    const teacherClasses = await Class.find({
      $or: [
        { homeroomTeacher: req.user._id },
        { teachers: req.user._id }
      ],
      isActive: true,
    });

    if (teacherClasses.length === 0) {
      return res.status(403).json({
        message: "Bạn không được phân công quản lý lớp nào",
      });
    }

    const classIds = teacherClasses.map(c => c._id);
    const managedStudents = await User.find({ class: { $in: classIds } }).select("_id");
    const managedStudentIds = managedStudents.map(s => s._id);

    // 2. Chỉ lấy bài nộp của học sinh trong các lớp này
    const submissions = await Submission.find({
      lesson: lessonId,
      user: { $in: managedStudentIds },
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

    const classNames = teacherClasses.map(c => c.name).join(", ");

    res.json({
      className: classNames || "Managed Classes",
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

    // 2. Kiểm tra quyền của giáo viên (chủ nhiệm hoặc được gán vào lớp của học sinh)
    const isAuthorized = await Class.exists({
      _id: submission.user.class,
      $or: [
        { homeroomTeacher: req.user._id },
        { teachers: req.user._id }
      ],
      isActive: true,
    });

    if (!isAuthorized) {
      return res.status(403).json({
        message: "Bạn không có quyền xem bài của học sinh này",
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
