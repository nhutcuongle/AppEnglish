import Submission from "../models/Submission.js";
<<<<<<< HEAD
import Question from "../models/Question.js";
import Class from "../models/Class.js";
=======
>>>>>>> origin/New-frontend-teacher

export const getSubmissions = async (req, res) => {
  try {
    const { assignmentId, studentId } = req.query;
    const query = {};
    if (assignmentId) query.assignmentId = assignmentId;
    if (studentId) query.studentId = studentId;

    const submissions = await Submission.find(query)
      .populate("studentId", "username fullName email")
      .populate("assignmentId", "title");

    res.status(200).json(submissions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createSubmission = async (req, res) => {
  try {
    const { assignmentId, content } = req.body;
    const studentId = req.user.id; // From authMiddleware

    // Check if exists
    let submission = await Submission.findOne({ assignmentId, studentId });
    if (submission) {
      submission.content = content || submission.content;
      submission.submittedAt = Date.now();
      await submission.save();
    } else {
      submission = await Submission.create({
        assignmentId,
        studentId,
        content,
      });
    }

    res.status(201).json(submission);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const gradeSubmission = async (req, res) => {
  try {
<<<<<<< HEAD
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
      submittedAt: submission.createdAt,
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
      submittedAt: sub.createdAt,
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
      .populate("user", "username email")
      .sort({ createdAt: -1 })
      .lean();

    const result = submissions.map((sub) => ({
      submissionId: sub._id,
      student: {
        id: sub.user._id,
        username: sub.user.username,
        email: sub.user.email,
      },
      scores: sub.scores,
      totalScore: sub.totalScore,
      submittedAt: sub.createdAt,
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
      student: submission.user,
      lesson: submission.lesson,
      scores: submission.scores,
      totalScore: submission.totalScore,
      answers: submission.answers.map((a) => ({
        question: a.question.content,
        type: a.question.type,
        skill: a.question.skill,
        userAnswer: a.userAnswer,
        isCorrect: a.isCorrect,
      })),
      submittedAt: submission.createdAt,
    });
=======
    const { score, comment } = req.body;
    const submission = await Submission.findByIdAndUpdate(
      req.params.id,
      { score, comment, gradedAt: Date.now() },
      { new: true }
    );
    res.status(200).json(submission);
>>>>>>> origin/New-frontend-teacher
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
