import Lesson from "../models/Lesson.js";

/* ================= CREATE LESSON ================= */
// export const createLesson = async (req, res) => {
//   try {
//     const {
//       unit,
//       title,
//       content,
//       order,
//       isPublished,
//       images,
//       audios,
//       videos,
//     } = req.body;

//     if (!unit || !title) {
//       return res
//         .status(400)
//         .json({ message: "Thiếu unit hoặc title" });
//     }

//     const lesson = await Lesson.create({
//       unit,
//       title,
//       content,
//       order,
//       isPublished,
//       images,
//       audios,
//       videos,
//     });

//     res.status(201).json({
//       message: "Tạo lesson thành công",
//       lesson,
//     });
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };
export const createLesson = async (req, res) => {
  try {
    const { unit, lessonType, title, content, isPublished } = req.body;

    /* ===== VALIDATE ===== */
    if (!unit || !title) {
      return res.status(400).json({ message: "Thiếu unit hoặc title" });
    }

    if (!lessonType) {
      return res.status(400).json({ message: "Thiếu lessonType" });
    }

    const allowedTypes = [
      "vocabulary",
      "grammar",
      "reading",
      "listening",
      "speaking",
      "writing",
    ];

    if (!allowedTypes.includes(lessonType)) {
      return res.status(400).json({ message: "lessonType không hợp lệ" });
    }

    /* ===== AUTO LESSON ORDER ===== */
    const lastLesson = await Lesson.findOne({ unit })
      .sort({ order: -1 })
      .select("order");

    const nextOrder = lastLesson ? lastLesson.order + 1 : 1;

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
    const lesson = await Lesson.create({
      unit,
      lessonType,
      title,
      content,
      isPublished,
      order: nextOrder,
      images,
      audios,
      videos,
    });

    res.status(201).json({
      message: "Tạo lesson thành công",
      lesson,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET LESSONS BY UNIT ================= */
export const getLessonsByUnit = async (req, res) => {
  try {
    const lessons = await Lesson.find({
      unit: req.params.unitId,
      isPublished: true,
    })
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: lessons.length,
      data: lessons,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= UPDATE LESSON (PARTIAL) ================= */
export const updateLesson = async (req, res) => {
  try {
    const allowedFields = [
      "title",
      "content",
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

    const lesson = await Lesson.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
    });

    if (!lesson) {
      return res.status(404).json({ message: "Không tìm thấy lesson" });
    }

    res.json({
      message: "Cập nhật lesson thành công",
      lesson,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= DELETE LESSON ================= */
export const deleteLesson = async (req, res) => {
  try {
    const lesson = await Lesson.findByIdAndDelete(req.params.id);

    if (!lesson) {
      return res.status(404).json({ message: "Không tìm thấy lesson" });
    }

    // ⚠️ Gợi ý nâng cấp:
    // Xóa ảnh / audio / video trên Cloudinary ở đây

    res.json({ message: "Xóa lesson thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
