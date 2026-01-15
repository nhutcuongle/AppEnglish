import express from "express";
import {
  createExam,
  updateExam,
  deleteExam,
  getExamsForTeacher,
  getExamsForStudent,
  getExamReport,
  submitExam,
  getQuestionsByExam
} from "../controller/examController.js";
import { authenticate, isTeacher, isStudent } from "../middlewares/authMiddleware.js";
import { uploadNone } from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/* ================= TEACHER ================= */
router.post("/", authenticate, isTeacher, uploadNone, createExam);
router.get("/teacher", authenticate, isTeacher, getExamsForTeacher);
router.patch("/:id", authenticate, isTeacher, uploadNone, updateExam);
router.delete("/:id", authenticate, isTeacher, deleteExam);
router.get("/report/:id", authenticate, isTeacher, getExamReport);

/* ================= STUDENT ================= */
router.get("/student", authenticate, isStudent, getExamsForStudent);
router.post("/submit", authenticate, isStudent, uploadNone, submitExam);

/* ================= COMMON ================= */
router.get("/:id/questions", authenticate, getQuestionsByExam);

export default router;
