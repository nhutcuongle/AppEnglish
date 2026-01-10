import express from "express";
import {
  createQuestion,
  getQuestionsByLesson,
  updateQuestion,
  deleteQuestion,
} from "../controller/questionController.js";

import { authenticate, isTeacher } from "../middlewares/authMiddleware.js";
import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/* ================= TEACHER ================= */

router.post(
  "/",
  authenticate,
  isTeacher,
  uploadMultipleMedia,
  uploadErrorHandler,
  createQuestion
);

router.patch(
  "/:id",
  authenticate,
  isTeacher,
  uploadMultipleMedia,
  uploadErrorHandler,
  updateQuestion
);

router.delete("/:id", authenticate, isTeacher, deleteQuestion);

/* ================= STUDENT / TEACHER ================= */

router.get(
  "/lesson/:lessonId",
  authenticate,
  getQuestionsByLesson
);

export default router;
