import Question from "../models/Question.js";
import Lesson from "../models/Lesson.js";

/* ================= CREATE QUESTION ================= */
export const createQuestion = async (req, res) => {
  try {
    const {
      lesson,
      skill,
      type,
      content,
      options,
      correctAnswer,
      explanation,
      isPublished,
    } = req.body;

    /* ===== VALIDATE ===== */
    if ((!lesson && !req.body.assignment) || !skill || !type || !content) {
      return res.status(400).json({
        message: "Thiếu lesson/assignment, skill, type hoặc content",
      });
    }

    if (lesson) {
      /* ===== CHECK LESSON ===== */
      const lessonData = await Lesson.findById(lesson);
      if (!lessonData) {
        return res.status(400).json({ message: "Lesson không tồn tại" });
      }
    }

    // Auto order based on lesson OR assignment
    const filter = lesson ? { lesson } : { assignment: req.body.assignment };
    const lastQuestion = await Question.findOne(filter)
      .sort({ order: -1 })
      .select("order");

    const nextOrder = lastQuestion ? lastQuestion.order + 1 : 1;

    /* ===== IMAGE ===== */
    const imageCaptions = Array.isArray(req.body.imageCaptions)
      ? req.body.imageCaptions
      : req.body.imageCaptions
        ? [req.body.imageCaptions]
        : [];

    const images =
      req.files?.images?.map((file, index) => ({
        url: file.path,
        caption: imageCaptions[index] || "",
        order: index + 1,
      })) || [];

    /* ===== AUDIO ===== */
    const audioCaptions = Array.isArray(req.body.audioCaptions)
      ? req.body.audioCaptions
      : req.body.audioCaptions
        ? [req.body.audioCaptions]
        : [];

    const audios =
      req.files?.audios?.map((file, index) => ({
        url: file.path,
        caption: audioCaptions[index] || "",
        order: index + 1,
      })) || [];

    /* ===== VIDEO ===== */
    const videoCaptions = Array.isArray(req.body.videoCaptions)
      ? req.body.videoCaptions
      : req.body.videoCaptions
        ? [req.body.videoCaptions]
        : [];

    const videos =
      req.files?.videos?.map((file, index) => ({
        url: file.path,
        caption: videoCaptions[index] || "",
        order: index + 1,
      })) || [];

    /* ===== CREATE ===== */
    const question = await Question.create({
      lesson: lesson || undefined,
      assignment: req.body.assignment || undefined,
      skill,
      type,
      content,
      options,
      correctAnswer,
      explanation,
      isPublished,
      order: nextOrder,
      images,
      audios,
      videos,
    });

    res.status(201).json({
      message: "Tạo question thành công",
      question,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET QUESTIONS BY LESSON ================= */
export const getQuestionsByLesson = async (req, res) => {
  try {
    const questions = await Question.find({
      lesson: req.params.lessonId,
      isPublished: true,
    })
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: questions.length,
      data: questions,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= UPDATE QUESTION (PARTIAL) ================= */
export const updateQuestion = async (req, res) => {
  try {
    const allowedFields = [
      "content",
      "options",
      "correctAnswer",
      "explanation",
      "order",
      "isPublished",
      "images",
      "audios",
      "videos",
    ];

    const updateData = {};
    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    const question = await Question.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );

    if (!question) {
      return res.status(404).json({ message: "Không tìm thấy question" });
    }

    res.json({
      message: "Cập nhật question thành công",
      question,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= DELETE QUESTION ================= */
export const deleteQuestion = async (req, res) => {
  try {
    const question = await Question.findByIdAndDelete(req.params.id);

    if (!question) {
      return res.status(404).json({ message: "Không tìm thấy question" });
    }

    // ⚠️ nâng cấp sau: xóa media cloud

    res.json({ message: "Xóa question thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET QUESTIONS BY ASSIGNMENT ================= */
export const getQuestionsByAssignment = async (req, res) => {
  try {
    const questions = await Question.find({
      assignment: req.params.assignmentId,
    })
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: questions.length,
      data: questions,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
