import express from "express";
import {
  createLesson,
  getLessonsByUnit,
  updateLesson,
  deleteLesson,
} from "../controller/lessonController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";
import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/* ================= SCHOOL / ADMIN ================= */

router.post(
  "/",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  createLesson
);

router.patch(
  "/:id",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  updateLesson
);

router.delete("/:id", authenticate, isSchool, deleteLesson);

/* ================= TEACHER / STUDENT ================= */

router.get("/unit/:unitId", authenticate, getLessonsByUnit);

export default router;
