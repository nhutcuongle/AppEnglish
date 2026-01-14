import express from "express";
import {
  createGrammar,
  getGrammarByLesson,
  updateGrammar,
  deleteGrammar,
} from "../controller/grammarController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";
import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/* ================= SCHOOL ================= */

router.post(
  "/",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  createGrammar
);

router.patch(
  "/:id",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  updateGrammar
);

router.delete("/:id", authenticate, isSchool, deleteGrammar);

/* ================= TEACHER / STUDENT ================= */

router.get("/lesson/:lessonId", authenticate, getGrammarByLesson);

export default router;
