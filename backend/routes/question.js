import express from "express";
import {
  createQuestion,                // School
  createQuestionForTeacher,      // Teacher (NEW)
  getQuestionsByLesson,
  updateQuestion,
  deleteQuestion,
} from "../controller/questionController.js";

import {
  authenticate,
  isSchool,
  isTeacher,
} from "../middlewares/authMiddleware.js";

import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/* ================= TEACHER (EXAM QUESTIONS) ================= */

router.post(
  "/teacher",
  authenticate,
  isTeacher,
  uploadMultipleMedia,
  uploadErrorHandler,
  createQuestionForTeacher
);

/* ================= SCHOOL / TEACHER (CRUD) ================= */

// POST / for School (Lesson questions)
router.post(
  "/",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  createQuestion
);

// PATCH / DELETE for both (Granular checks in controller)
router.patch(
  "/:id",
  authenticate,
  uploadMultipleMedia,
  uploadErrorHandler,
  updateQuestion
);

router.delete(
  "/:id",
  authenticate,
  deleteQuestion
);

/* ================= STUDENT / TEACHER / SCHOOL (VIEW) ================= */

router.get(
  "/lesson/:lessonId",
  authenticate,
  getQuestionsByLesson
);

export default router;
