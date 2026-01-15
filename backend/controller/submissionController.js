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
      exam: sub.exam, // Add this line
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
    const { classId } = req.query; // Nhận classId từ frontend

    // 1. Tìm lớp giáo viên tham gia (chủ nhiệm hoặc được gán)
    let query = {
      $or: [
        { homeroomTeacher: req.user._id },
        { teachers: req.user._id }
      ],
      isActive: true,
    };

    // Nếu frontend yêu cầu lọc theo classId, ta thêm điều kiện vào query
    if (classId) {
      query._id = classId;
    }

    const teacherClasses = await Class.find(query);

    if (teacherClasses.length === 0) {
      // Nếu lọc theo classId mà không tìm thấy -> có thể giáo viên không quản lý lớp đó hoặc lớp không tồn tại
      return res.status(403).json({
        message: "Không có quyền xem điểm lớp này hoặc không có dữ liệu",
      });
    }

    // Prepare lists for robust matching
    const allowedClassIds = teacherClasses.map(c => c._id.toString());
    const allowedClassNames = teacherClasses.map(c => c.name);

    // 2. Fetch ALL submissions for this lesson, populate user info including class
    // We filter in memory because standard DB query fails on "dirty" data (String vs ObjectId)
    const allSubmissions = await Submission.find({ lesson: lessonId })
      .populate("user", "username email fullName class")
      .sort({ createdAt: -1 })
      .lean();

    // 3. Filter submissions: Keep if user belongs to one of the authorized classes
    // (Check both ID match and Name match to handle legacy/dirty data like "10A1")
    const filteredSubmissions = allSubmissions.filter(sub => {
      if (!sub.user) return false;

      const userClass = sub.user.class; // Can be ObjectId string or "10A1"
      if (!userClass) return false;

      const userClassStr = String(userClass);

      // Check ID match
      if (allowedClassIds.includes(userClassStr)) return true;
      // Check Name match (fallback for dirty data)
      if (allowedClassNames.includes(userClassStr)) return true;

      return false;
    });

    const result = filteredSubmissions.map((sub) => ({
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
