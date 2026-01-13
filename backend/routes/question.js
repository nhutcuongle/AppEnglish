import express from "express";
import {
  createQuestion,
  getQuestionsByLesson,
  updateQuestion,
  deleteQuestion,
} from "../controller/questionController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";
import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/* ================= SCHOOL (CRUD) ================= */

router.post(
  "/",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  createQuestion
);

router.patch(
  "/:id",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  updateQuestion
);

router.delete("/:id", authenticate, isSchool, deleteQuestion);

/* ================= STUDENT / TEACHER / SCHOOL (VIEW) ================= */

router.get(
  "/lesson/:lessonId",
  authenticate,
  getQuestionsByLesson
);

export default router;
