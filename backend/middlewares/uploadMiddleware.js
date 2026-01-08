import multer from "multer";
import { storage, videoStorage } from "../config/cloudinary.js";

/**
 * Upload 1 ảnh cho Unit (thumbnail)
 * field name: image
 */
export const uploadUnitImage = multer({
  storage,
  limits: {
    fileSize: 2 * 1024 * 1024, // 2MB
  },
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith("image/")) {
      cb(new Error("Chỉ cho phép upload file ảnh"), false);
    } else {
      cb(null, true);
    }
  },
}).single("image");

/**
 * Upload 1 video cho Lesson
 * field name: video
 */
export const uploadLessonVideo = multer({
  storage: videoStorage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB
  },
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith("video/")) {
      cb(new Error("Chỉ cho phép upload file video"), false);
    } else {
      cb(null, true);
    }
  },
}).single("video");
