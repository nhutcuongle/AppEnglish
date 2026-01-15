import multer from "multer";
import {
  storage,
  videoStorage,
  lessonMediaStorage,
} from "../config/cloudinary.js";

/* ================= SINGLE IMAGE ================= */
/**
 * Upload 1 ảnh (thumbnail, cover, avatar…)
 * field name: image
 */
export const uploadSingleImage = multer({
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

/* ================= SINGLE MEDIA ================= */
/**
 * Upload 1 media (video hoặc audio)
 * field name: media
 */
export const uploadSingleMedia = multer({
  storage: videoStorage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB
  },
  fileFilter: (req, file, cb) => {
    if (
      file.mimetype.startsWith("video/") ||
      file.mimetype.startsWith("audio/")
    ) {
      cb(null, true);
    } else {
      cb(new Error("Chỉ cho phép upload video hoặc audio"), false);
    }
  },
}).single("media");

/* ================= MULTIPLE MEDIA ================= */
/**
 * Upload nhiều ảnh + audio + video (dùng khi tạo / update resource)
 *
 * fields:
 * - images[]  (image)
 * - audios[]  (audio)
 * - videos[]  (video)
 */
export const uploadMultipleMedia = multer({
  storage: lessonMediaStorage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB / file
  },
}).fields([
  { name: "images", maxCount: 10 },
  { name: "audios", maxCount: 5 },
  { name: "videos", maxCount: 5 },
]);

/* ================= NO FILES (ONLY FIELDS) ================= */
export const uploadNone = multer().none();

/* ================= ERROR HANDLER ================= */
export const uploadErrorHandler = (err, req, res, next) => {
  if (err) {
    return res.status(400).json({
      message: err.message || "Upload thất bại",
    });
  }
  next();
};
