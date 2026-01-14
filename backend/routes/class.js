import express from "express";
import {
  createClass,
  assignTeacherToClass,
  getAllClasses,
  getClassDetail,
  updateClass,
  deleteClass,
  getTeacherClasses,
} from "../controller/classController.js";

import { authenticate, isSchool, isTeacher } from "../middlewares/authMiddleware.js";

const router = express.Router();

/* =====================================================
   TEACHER: GET MY CLASSES
===================================================== */
router.get("/teacher/my-classes", authenticate, isTeacher, getTeacherClasses);

/* =====================================================
   CREATE CLASS (School)
===================================================== */
router.post("/", authenticate, isSchool, createClass);

/* =====================================================
   GET ALL CLASSES (School)
===================================================== */
router.get("/", authenticate, isSchool, getAllClasses);

/* =====================================================
   GET CLASS DETAIL (School)
===================================================== */
router.get("/:id", authenticate, isSchool, getClassDetail);

/* =====================================================
   UPDATE CLASS (School)
===================================================== */
router.put("/:id", authenticate, isSchool, updateClass);

/* =====================================================
   DELETE CLASS (School)
==================================================== */
router.delete("/:id", authenticate, isSchool, deleteClass);

/* =====================================================
   ASSIGN / CHANGE TEACHER (School)
===================================================== */
router.post(
  "/assign-teacher",
  authenticate,
  isSchool,
  assignTeacherToClass
);

export default router;
