import express from "express";
import {
  getSubmissions,
  createSubmission,
  gradeSubmission,
  submitLesson,
  getMySubmissions,
  getSubmissionById,
  getScoresByLesson,
  getSubmissionDetailForTeacher,
} from "../controller/submissionController.js";
import { authenticate, isTeacher, isStudent } from "../middlewares/authMiddleware.js";

const router = express.Router();

// Student routes
router.post("/submit", authenticate, isStudent, submitLesson);
router.get("/my", authenticate, isStudent, getMySubmissions);
router.get("/:id", authenticate, isStudent, getSubmissionById);

// Teacher routes
router.get(
  "/lesson/:lessonId/scores",
  authenticate,
  isTeacher,
  getScoresByLesson
);
router.get(
  "/teacher/:id",
  authenticate,
  isTeacher,
  getSubmissionDetailForTeacher
);
router.put("/:id/grade", authenticate, isTeacher, gradeSubmission);

// General routes
router.get("/", authenticate, getSubmissions);
router.post("/", authenticate, createSubmission);

export default router;
