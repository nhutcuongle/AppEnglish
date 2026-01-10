import express from "express";
import {
  getSubmissions,
  createSubmission,
  gradeSubmission,
} from "../controller/submissionController.js";
import { authenticate, isTeacher } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, getSubmissions);
router.post("/", authenticate, createSubmission); // Student submits
router.put("/:id/grade", authenticate, isTeacher, gradeSubmission); // Teacher grades

export default router;
