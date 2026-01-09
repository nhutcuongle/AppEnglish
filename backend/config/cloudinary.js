import dotenv from "dotenv";
dotenv.config();

import { v2 as cloudinary } from "cloudinary";
import { CloudinaryStorage } from "multer-storage-cloudinary";

cloudinary.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.CLOUD_KEY,
  api_secret: process.env.CLOUD_SECRET,
});

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "lms/units", // 👈 đổi tên folder
    allowed_formats: ["jpg", "jpeg", "png", "webp"],
    transformation: [{ quality: "auto", fetch_format: "webp" }],
  },
});

const videoStorage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "lms/media", // 👈 đổi tên cho đúng bản chất
    resource_type: "video",
    allowed_formats: ["mp4", "mov", "avi", "webm", "mp3", "wav", "m4a", "ogg"],
    transformation: [{ quality: "auto" }],
  },
});
const lessonMediaStorage = new CloudinaryStorage({
  cloudinary,
  params: (req, file) => {
    if (file.mimetype.startsWith("image/")) {
      return {
        folder: "lms/lesson-images",
        allowed_formats: ["jpg", "jpeg", "png", "webp"],
        transformation: [{ quality: "auto", fetch_format: "webp" }],
      };
    }

    return {
      folder: "lms/lesson-media",
      resource_type: "video",
      allowed_formats: [
        "mp4",
        "mov",
        "avi",
        "webm",
        "mp3",
        "wav",
        "m4a",
        "ogg",
      ],
      transformation: [{ quality: "auto" }],
    };
  },
});

export { cloudinary, storage, videoStorage, lessonMediaStorage };


