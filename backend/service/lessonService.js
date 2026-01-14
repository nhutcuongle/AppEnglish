import Lesson from "../models/Lesson.js";
import { processMedia } from "../utils/mediaHelper.js";

/**
 * CREATE LESSON
 */
export const createNewLesson = async (lessonData, files) => {
  const { unit, lessonType, title, content, isPublished } = lessonData;

  /* ===== VALIDATE ===== */
  if (!unit || !title) throw new Error("Thiếu unit hoặc title");
  if (!lessonType) throw new Error("Thiếu lessonType");

  const allowedTypes = [
    "vocabulary",
    "grammar",
    "reading",
    "listening",
    "speaking",
    "writing",
  ];

  if (!allowedTypes.includes(lessonType)) {
    throw new Error("lessonType không hợp lệ");
  }

  /* ===== AUTO LESSON ORDER ===== */
  const lastLesson = await Lesson.findOne({ unit })
    .sort({ order: -1 })
    .select("order");

  const nextOrder = lastLesson ? lastLesson.order + 1 : 1;

  /* ===== MEDIA ===== */
  const media = processMedia(files, lessonData);

  /* ===== CREATE ===== */
  const lesson = await Lesson.create({
    unit,
    lessonType,
    title,
    content,
    isPublished,
    order: nextOrder,
    images: media.images || [],
    audios: media.audios || [],
    videos: media.videos || [],
  });

  return lesson;
};

/**
 * GET LESSONS BY UNIT
 */
export const fetchLessonsByUnit = async (unitId) => {
  const lessons = await Lesson.find({
    unit: unitId,
    isPublished: true,
  })
    .sort({ order: 1, createdAt: 1 })
    .lean();

  return {
    total: lessons.length,
    data: lessons,
  };
};

/**
 * UPDATE LESSON
 */
export const updateExistingLesson = async (lessonId, updateFields, files) => {
  const allowedFields = [
    "title",
    "content",
    "order",
    "isPublished",
    "lessonType",
    "images",
    "audios",
    "videos",
  ];

  const updateData = {};
  allowedFields.forEach((field) => {
    if (updateFields[field] !== undefined) {
      updateData[field] = updateFields[field];
    }
  });

  /* ===== HANDLE MEDIA UPDATE ===== */
  const media = processMedia(files, updateFields);
  if (media.images) updateData.images = media.images;
  if (media.audios) updateData.audios = media.audios;
  if (media.videos) updateData.videos = media.videos;

  const lesson = await Lesson.findByIdAndUpdate(lessonId, updateData, { new: true });
  if (!lesson) throw new Error("Không tìm thấy lesson");

  return lesson;
};

/**
 * DELETE LESSON
 */
export const removeLesson = async (lessonId) => {
  const lesson = await Lesson.findByIdAndDelete(lessonId);
  if (!lesson) throw new Error("Không tìm thấy lesson");
  
  // TODO: Xóa media trên Cloudinary (nếu cần)
  
  return true;
};
