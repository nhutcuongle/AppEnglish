import express from "express";
import {
  createTeacher,
  getTeachers,
  updateTeacher,
  deleteTeacher,
} from "../controller/teacherController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.use(authenticate);
router.use(isSchool);

router.post("/", createTeacher);
router.get("/", getTeachers);
router.put("/:id", updateTeacher);
router.delete("/:id", deleteTeacher);

export default router;
