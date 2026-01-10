import express from "express";
import {
  submitLesson,
  getSubmissionById,
  getMySubmissions,
  getScoresByLesson,
  getSubmissionDetailForTeacher,
} from "../controller/submissionController.js";
import {
  authenticate,
  isStudent,
  isTeacher,
} from "../middlewares/authMiddleware.js";

const router = express.Router();

router.post("/submit", authenticate, isStudent, submitLesson);

router.get("/my", authenticate, isStudent, getMySubmissions);

router.get("/:id", authenticate, isStudent, getSubmissionById);

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

export default router;
