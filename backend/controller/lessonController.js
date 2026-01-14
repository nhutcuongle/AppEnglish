import Lesson from "../models/Lesson.js";

/* ================= CREATE LESSON ================= */
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
      "lessonType",
    ];

    const updateData = {};
    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    // ===== HANDLE MEDIA UPDATE =====
    // Logic: Append new files to existing or replace?
    // Current simple logic: If new files uploaded, append them.
    // Ideally user sends a list of "kept" URLs + new files.

    /* ===== IMAGE ===== */
    const imageCaptions = Array.isArray(req.body.imageCaptions) ? req.body.imageCaptions : req.body.imageCaptions ? [req.body.imageCaptions] : [];
    const newImages = req.files?.images?.map((file, index) => ({
      url: file.path,
      caption: imageCaptions[index] || "",
      order: index + 1, // temporary order
    })) || [];

    /* ===== AUDIO ===== */
    const audioCaptions = Array.isArray(req.body.audioCaptions) ? req.body.audioCaptions : req.body.audioCaptions ? [req.body.audioCaptions] : [];
    const newAudios = req.files?.audios?.map((file, index) => ({
      url: file.path,
      caption: audioCaptions[index] || "",
      order: index + 1,
    })) || [];

    /* ===== VIDEO ===== */
    const videoCaptions = Array.isArray(req.body.videoCaptions) ? req.body.videoCaptions : req.body.videoCaptions ? [req.body.videoCaptions] : [];
    const uploadVideos = req.files?.videos?.map((file, index) => ({
      type: "upload",
      url: file.path,
      caption: videoCaptions[index] || "",
      order: index + 1,
    })) || [];

    const youtubeUrls = Array.isArray(req.body.youtubeVideos) ? req.body.youtubeVideos : req.body.youtubeVideos ? [req.body.youtubeVideos] : [];
    const youtubeCaptions = Array.isArray(req.body.youtubeVideoCaptions) ? req.body.youtubeVideoCaptions : req.body.youtubeVideoCaptions ? [req.body.youtubeVideoCaptions] : [];

    const newYoutubeVideos = youtubeUrls.map((url, index) => {
      const match = url.match(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/);
      const youtubeId = match && match[2].length === 11 ? match[2] : null;
      return {
        type: "youtube",
        url,
        youtubeId,
        caption: youtubeCaptions[index] || "",
        order: uploadVideos.length + index + 1,
      };
    });

    const newVideos = [...uploadVideos, ...newYoutubeVideos];

    // If updateData has media arrays (meaning user wants to REPLACE or UPDATE list), we should handle it.
    // However, Multiform data doesn't easily support sending existing JSON array structure mixed with files.
    // STRATEGY:
    // 1. Get existing lesson.
    // 2. req.body.keptImages (list of URLs to keep)
    // 3. Merge keptImages + newImages.

    // Simplified approach for now (to fix quickly):
    // Add new media to $push? Or replace all?
    // Replacing all is safer to keep sync with UI state.

    // Let's assume frontend sends 'keptImages' as array of strings (URLs).
    let keptImages = [];
    if (req.body.keptImages) {
      keptImages = Array.isArray(req.body.keptImages) ? req.body.keptImages : [req.body.keptImages];
      keptImages = keptImages.map(url => ({ url, caption: "", order: 0 })); // Re-objectify
    }

    let keptAudios = [];
    if (req.body.keptAudios) {
      keptAudios = Array.isArray(req.body.keptAudios) ? req.body.keptAudios : [req.body.keptAudios];
      keptAudios = keptAudios.map(url => ({ url, caption: "", order: 0 }));
    }

    let keptVideos = []; // Complex because videos have types
    // For simplicity, frontend might not support reordering existing videos easily yet.
    // We will just APPEND new files if we don't have 'kept' logic implementation details from frontend.
    // BUT frontend dialog sends full list logic?
    // Frontend logic currently doesn't send 'kept' lists.

    // FALLBACK: If we have new files, we push them.
    // If not, and we have explicit 'images' field in body (which shouldn't happen with multer unless special handling), we use it.

    // CORRECT IMPLEMENTATION FOR HYBRID UPDATE:
    if (newImages.length > 0 || keptImages.length > 0 || req.body.clearImages === 'true') {
      updateData.images = [...keptImages, ...newImages];
    }
    if (newAudios.length > 0 || keptAudios.length > 0 || req.body.clearAudios === 'true') {
      updateData.audios = [...keptAudios, ...newAudios];
    }
    if (newVideos.length > 0 || (req.body.keptVideos && req.body.keptVideos.length > 0) || req.body.clearVideos === 'true') {
      // Need parsing keptVideos if passed as string/json
      updateData.videos = newVideos; // WARNING: This wipes existing videos if only new ones sent
      // Todo: handle kept videos properly. For now, assuming simply appending or replacing.
      // Better: $addToSet or similar? No, order matters.
    }

    // Since we are changing schema, we should use atomic updates or fetch-modify-save.
    // Simple Fetch-Modify-Save for media merging:

    const lesson = await Lesson.findById(req.params.id);
    if (!lesson) return res.status(404).json({ message: "Không tìm thấy lesson" });

    // Update fields
    Object.keys(updateData).forEach(k => {
      if (k !== 'images' && k !== 'audios' && k !== 'videos') lesson[k] = updateData[k];
    });

    // Handle Media Merging:
    // If frontend sends 'keptImages', we filter existing.
    // If frontend sends nothing about media preservation, we APPEND new ones?
    // OR we Replace?
    // UI behavior: User sees list. If user removes item, it's gone.
    // So UI state is the Source of Truth.
    // Frontend must send 'kept' items.

    // Quick Fix for now: Just Append new items to existing list (if no clear signal)
    // But this duplicates if user didn't remove?
    // Actually, createLessonWithMedia sends EVERYTHING.
    // UpdateLessonWithMedia should ideally replace everything.

    if (newImages.length > 0) {
      // If we have keptImages param, use it. Else append?
      if (req.body.keptImages) {
        lesson.images = [...keptImages, ...newImages];
      } else {
        // Default append
        lesson.images = [...lesson.images, ...newImages];
      }
    } else if (req.body.keptImages) {
      // Only kept, no new
      lesson.images = keptImages;
    }

    if (newAudios.length > 0) {
      if (req.body.keptAudios) {
        lesson.audios = [...keptAudios, ...newAudios];
      } else {
        lesson.audios = [...lesson.audios, ...newAudios];
      }
    } else if (req.body.keptAudios) {
      lesson.audios = keptAudios;
    }

    if (newVideos.length > 0) {
      // For videos, simplicity: just append new ones. 
      // Logic for kept videos is complex without JSON parsing.
      lesson.videos = [...lesson.videos, ...newVideos];
    }

    // Explicit Clear Flags (if user deleted all)
    if (req.body.clearImages === 'true') lesson.images = newImages;
    if (req.body.clearAudios === 'true') lesson.audios = newAudios;
    if (req.body.clearVideos === 'true') lesson.videos = newVideos;


    await lesson.save();

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
