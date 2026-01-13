import Exam from "../models/Exam.js";
import Class from "../models/Class.js";
import Submission from "../models/Submission.js";
import Question from "../models/Question.js";

/* ================= CREATE EXAM ================= */
export const createExam = async (req, res) => {
  try {
    const { title, type, classId, startTime, endTime } = req.body;

    if (!title || !type || !classId || !startTime || !endTime) {
      return res.status(400).json({ message: "Thiếu thông tin bắt buộc" });
    }

    // Kiểm tra lớp có thuộc giáo viên này không
    const targetClass = await Class.findOne({
      _id: classId,
      homeroomTeacher: req.user._id,
      isActive: true,
    });

    if (!targetClass) {
      return res.status(403).json({ message: "Bạn không có quyền tạo bài kiểm tra cho lớp này" });
    }

    const exam = await Exam.create({
      title,
      type,
      class: classId,
      teacher: req.user._id,
      startTime,
      endTime,
    });

    res.status(201).json({ message: "Tạo bài kiểm tra thành công", exam });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= UPDATE EXAM ================= */
export const updateExam = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, type, startTime, endTime, isPublished } = req.body;

    const exam = await Exam.findById(id);
    if (!exam) return res.status(404).json({ message: "Không tìm thấy bài kiểm tra" });

    if (exam.teacher.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Bạn không có quyền sửa bài kiểm tra này" });
    }

    if (title) exam.title = title;
    if (type) exam.type = type;
    if (startTime) exam.startTime = startTime;
    if (endTime) exam.endTime = endTime;
    if (isPublished !== undefined) exam.isPublished = isPublished;

    await exam.save();
    res.json({ message: "Cập nhật bài kiểm tra thành công", exam });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= DELETE EXAM ================= */
export const deleteExam = async (req, res) => {
  try {
    const { id } = req.params;

    const exam = await Exam.findById(id);
    if (!exam) return res.status(404).json({ message: "Không tìm thấy bài kiểm tra" });

    if (exam.teacher.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Bạn không có quyền xóa bài kiểm tra này" });
    }

    // Xóa tất cả câu hỏi thuộc bài kiểm tra này
    await Question.deleteMany({ exam: id });

    // Xóa bài kiểm tra
    await Exam.findByIdAndDelete(id);

    res.json({ message: "Xóa bài kiểm tra và các câu hỏi liên quan thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


/* ================= GET EXAMS FOR TEACHER ================= */
export const getExamsForTeacher = async (req, res) => {
  try {
    const exams = await Exam.find({ teacher: req.user._id })
      .populate("class", "name")
      .sort({ createdAt: -1 });
    res.json(exams);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET EXAMS FOR STUDENT ================= */
export const getExamsForStudent = async (req, res) => {
  try {
    if (!req.user.class) {
      return res.status(403).json({ message: "Học sinh chưa được xếp lớp" });
    }

    const exams = await Exam.find({
      class: req.user.class,
      isPublished: true,
    }).sort({ startTime: 1 });

    res.json(exams);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET EXAM REPORT (FOR TEACHER) ================= */
export const getExamReport = async (req, res) => {
  try {
    const { id } = req.params;
    const exam = await Exam.findById(id).populate("class");

    if (!exam) return res.status(404).json({ message: "Không tìm thấy bài kiểm tra" });

    if (exam.teacher.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Bạn không có quyền xem báo cáo này" });
    }

    const submissions = await Submission.find({ exam: id })
      .populate("user", "username fullName email")
      .sort({ totalScore: -1 });

    const report = submissions.map(s => ({
      student: {
        username: s.user.username,
        fullName: s.user.fullName || s.user.username,
        email: s.user.email,
      },
      totalScore: s.totalScore,
      submittedAt: s.submittedAt,
    }));

    res.json({
      examTitle: exam.title,
      examType: exam.type,
      className: exam.class.name,
      totalSubmissions: report.length,
      data: report,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= SUBMIT EXAM ================= */
export const submitExam = async (req, res) => {
  try {
    const { examId, answers } = req.body;
    const userId = req.user._id;

    const exam = await Exam.findById(examId);
    if (!exam) return res.status(404).json({ message: "Không tìm thấy bài kiểm tra" });

    // Kiểm tra thời gian
    const now = new Date();
    if (now < new Date(exam.startTime)) {
      return res.status(403).json({ message: "Bài kiểm tra chưa bắt đầu" });
    }
    if (now > new Date(exam.endTime)) {
      return res.status(403).json({ message: "Đã hết thời gian làm bài" });
    }

    // Logic tính điểm tương tự submit bài học
    let totalScore = 0;
    const checkedAnswers = [];

    for (const ans of answers) {
      const question = await Question.findById(ans.question).lean();
      if (!question) continue;

      let isCorrect = null;
      if (question.type !== "essay") {
        isCorrect = JSON.stringify(ans.userAnswer) === JSON.stringify(question.correctAnswer);
      }

      const p = isCorrect ? (question.points || 1) : 0;
      totalScore += p;

      checkedAnswers.push({
        question: ans.question,
        userAnswer: ans.userAnswer,
        isCorrect,
        pointsAwarded: p,
      });
    }

    const submission = await Submission.create({
      user: userId,
      exam: examId,
      answers: checkedAnswers,
      totalScore,
    });

    res.status(201).json({
      message: "Nộp bài kiểm tra thành công",
      submissionId: submission._id,
      totalScore,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET QUESTIONS BY EXAM ================= */
export const getQuestionsByExam = async (req, res) => {
  try {
    const { id } = req.params;
    const questions = await Question.find({ exam: id }).sort({ order: 1 });
    res.json(questions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

