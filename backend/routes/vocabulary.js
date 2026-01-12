import express from "express";
import {
  createVocabulary,
  getVocabularyByLesson,
  updateVocabulary,
  deleteVocabulary,
} from "../controller/vocabularyController.js";

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
  createVocabulary
);

router.patch(
  "/:id",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  updateVocabulary
);

router.delete("/:id", authenticate, isSchool, deleteVocabulary);

/* ================= TEACHER / STUDENT ================= */

router.get("/lesson/:lessonId", authenticate, getVocabularyByLesson);

export default router;
