import Vocabulary from "../models/Vocabulary.js";
import Lesson from "../models/Lesson.js";

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

    /* ===== VIDEO (UPLOAD + YOUTUBE) ===== */

    // caption cho video upload
    const videoCaptions = Array.isArray(req.body.videoCaptions)
      ? req.body.videoCaptions
      : req.body.videoCaptions
      ? [req.body.videoCaptions]
      : [];

    // video upload từ máy
    const uploadVideos =
      req.files?.videos?.map((file, index) => ({
        type: "upload",
        url: file.path,
        caption: videoCaptions[index] || "",
        order: index + 1,
      })) || [];

    // ===== YOUTUBE URL =====
    const youtubeUrls = Array.isArray(req.body.youtubeVideos)
      ? req.body.youtubeVideos
      : req.body.youtubeVideos
      ? [req.body.youtubeVideos]
      : [];

    const youtubeCaptions = Array.isArray(req.body.youtubeVideoCaptions)
      ? req.body.youtubeVideoCaptions
      : req.body.youtubeVideoCaptions
      ? [req.body.youtubeVideoCaptions]
      : [];

    const youtubeVideos = youtubeUrls.map((url, index) => {
      // Regex support:
      // - https://youtu.be/ID
      // - https://www.youtube.com/watch?v=ID
      // - https://www.youtube.com/watch?v=ID&list=...
      // - https://www.youtube.com/watch?param=...&v=ID
      // - https://www.youtube.com/embed/ID
      const match = url.match(
        /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/
      );
      const youtubeId = match && match[2].length === 11 ? match[2] : null;

      return {
        type: "youtube",
        url,
        youtubeId,
        caption: youtubeCaptions[index] || "",
        order: uploadVideos.length + index + 1,
      };
    });

    // ===== GỘP CHUNG =====
    const videos = [...uploadVideos, ...youtubeVideos];

    /* ===== CREATE ===== */
    const vocab = await Vocabulary.create({
      lesson,
      word,
      phonetic,
      meaning,
      example,
      isPublished,
      order: nextOrder,
      images,
      audios,
      videos,
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
