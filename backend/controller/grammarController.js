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
