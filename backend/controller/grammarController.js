import Grammar from "../models/Grammar.js";
import Lesson from "../models/Lesson.js";

/* ================= CREATE GRAMMAR ================= */
export const createGrammar = async (req, res) => {
  try {
    const { lesson, title, theory, examples, isPublished } = req.body;

    if (!lesson || !title || !theory) {
      return res
        .status(400)
        .json({ message: "Thiếu lesson, title hoặc theory" });
    }

    /* ===== CHECK LESSON TYPE ===== */
    const lessonData = await Lesson.findById(lesson);
    if (!lessonData || lessonData.lessonType !== "grammar") {
      return res.status(400).json({ message: "Lesson không phải grammar" });
    }

    /* ===== AUTO ORDER ===== */
    const lastGrammar = await Grammar.findOne({ lesson })
      .sort({ order: -1 })
      .select("order");

    const nextOrder = lastGrammar ? lastGrammar.order + 1 : 1;

    /* ===== MEDIA ===== */
    const images =
      req.files?.images?.map((file, index) => ({
        url: file.path,
        caption: "",
        order: index + 1,
      })) || [];

    const audios =
      req.files?.audios?.map((file, index) => ({
        url: file.path,
        caption: "",
        order: index + 1,
      })) || [];

    const videos =
      req.files?.videos?.map((file, index) => ({
        url: file.path,
        caption: "",
        order: index + 1,
      })) || [];

    const grammar = await Grammar.create({
      lesson,
      title,
      theory,
      examples,
      isPublished,
      order: nextOrder,
      images,
      audios,
      videos,
    });

    res.status(201).json({
      message: "Tạo grammar thành công",
      grammar,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET GRAMMAR BY LESSON ================= */
export const getGrammarByLesson = async (req, res) => {
  try {
    const grammars = await Grammar.find({
      lesson: req.params.lessonId,
      isPublished: true,
    })
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: grammars.length,
      data: grammars,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= UPDATE GRAMMAR ================= */
export const updateGrammar = async (req, res) => {
  try {
    const allowedFields = [
      "title",
      "theory",
      "examples",
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

    const grammar = await Grammar.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
    });

    if (!grammar) {
      return res.status(404).json({ message: "Không tìm thấy grammar" });
    }

    res.json({
      message: "Cập nhật grammar thành công",
      grammar,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= DELETE GRAMMAR ================= */
export const deleteGrammar = async (req, res) => {
  try {
    const grammar = await Grammar.findByIdAndDelete(req.params.id);

    if (!grammar) {
      return res.status(404).json({ message: "Không tìm thấy grammar" });
    }

    res.json({ message: "Xóa grammar thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
