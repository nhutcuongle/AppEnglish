import Vocabulary from "../models/Vocabulary.js";
import Lesson from "../models/Lesson.js";
import { processMedia } from "../utils/mediaHelper.js";

/* ================= CREATE VOCABULARY ================= */
export const createVocabulary = async (req, res) => {
  try {
    const { lesson, word, phonetic, meaning, example, isPublished } = req.body;

    /* ===== VALIDATE ===== */
    if (!lesson || !word || !meaning) {
      return res
        .status(400)
        .json({ message: "Thiếu lesson, word hoặc meaning" });
    }

    const lessonData = await Lesson.findById(lesson);
    if (!lessonData || lessonData.lessonType !== "vocabulary") {
      return res
        .status(400)
        .json({ message: "Lesson không phải vocabulary" });
    }

    /* ===== AUTO ORDER (THEO LESSON) ===== */
    const lastVocab = await Vocabulary.findOne({ lesson })
      .sort({ order: -1 })
      .select("order");

    const nextOrder = lastVocab ? lastVocab.order + 1 : 1;

    /* ===== MEDIA ===== */
    const media = processMedia(req.files, req.body);

    /* ===== CREATE ===== */
    const vocab = await Vocabulary.create({
      lesson,
      word,
      phonetic,
      meaning,
      example,
      isPublished,
      order: nextOrder,
      images: media.images || [],
      audios: media.audios || [],
      videos: media.videos || [],
    });

    res.status(201).json({
      message: "Tạo từ vựng thành công",
      vocab,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET VOCAB BY LESSON ================= */
export const getVocabularyByLesson = async (req, res) => {
  try {
    const vocabularies = await Vocabulary.find({
      lesson: req.params.lessonId,
      isPublished: true,
    })
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: vocabularies.length,
      data: vocabularies,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= UPDATE VOCABULARY (PARTIAL) ================= */
export const updateVocabulary = async (req, res) => {
  try {
    const allowedFields = [
      "word",
      "phonetic",
      "meaning",
      "example",
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

    /* ===== XỬ LÝ MEDIA MỚI (NẾU CÓ) ===== */
    const media = processMedia(req.files, req.body);
    if (media.images) updateData.images = media.images;
    if (media.audios) updateData.audios = media.audios;
    if (media.videos) updateData.videos = media.videos;

    const vocab = await Vocabulary.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );

    if (!vocab) {
return res.status(404).json({ message: "Không tìm thấy từ vựng" });
    }

    res.json({
      message: "Cập nhật từ vựng thành công",
      vocab,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= DELETE VOCABULARY ================= */
export const deleteVocabulary = async (req, res) => {
  try {
    const vocab = await Vocabulary.findByIdAndDelete(req.params.id);

    if (!vocab) {
      return res.status(404).json({ message: "Không tìm thấy từ vựng" });
    }

    // ⚠️ nâng cấp sau: xóa media cloud

    res.json({ message: "Xóa từ vựng thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};