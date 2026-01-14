import express from "express";
import {
  createTeacher,
  getTeachers,
  updateTeacher,
  deleteTeacher,
} from "../controller/teacherController.js";

import {
  authenticate,
  isSchool,
  isTeacher,
} from "../middlewares/authMiddleware.js";

const router = express.Router();

// SCHOOL
router.post("/", authenticate, isSchool, createTeacher);
router.get("/", authenticate, isSchool, getTeachers);
router.put("/:id", authenticate, isSchool, updateTeacher);
router.delete("/:id", authenticate, isSchool, deleteTeacher);

export default router;
