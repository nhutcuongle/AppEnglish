import express from "express";
import {
  getSubmissions,
  createSubmission,
  gradeSubmission,
} from "../controller/submissionController.js";
import { authenticate, isTeacher } from "../middlewares/authMiddleware.js";

const router = express.Router();

<<<<<<< HEAD
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
=======
router.get("/", authenticate, getSubmissions);
router.post("/", authenticate, createSubmission); // Student submits
router.put("/:id/grade", authenticate, isTeacher, gradeSubmission); // Teacher grades
>>>>>>> origin/New-frontend-teacher

export default router;
