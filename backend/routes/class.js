import express from "express";
import {
  createClass,
  assignTeacherToClass,
  getAllClasses,
  getClassDetail,
  updateClass,
  deleteClass,
} from "../controller/classController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";

const router = express.Router();

/* =====================================================
   CREATE CLASS
===================================================== */

router.post("/", authenticate, isSchool, createClass);

/* =====================================================
   GET ALL CLASSES
===================================================== */

router.get("/", authenticate, isSchool, getAllClasses);

/* =====================================================
   GET CLASS DETAIL
===================================================== */

router.get("/:id", authenticate, isSchool, getClassDetail);

/* =====================================================
   UPDATE CLASS
===================================================== */

router.put("/:id", authenticate, isSchool, updateClass);

/* =====================================================
   DELETE CLASS
===================================================== */

router.delete("/:id", authenticate, isSchool, deleteClass);

/* =====================================================
   ASSIGN / CHANGE TEACHER
===================================================== */

router.post(
  "/assign-teacher",
  authenticate,
  isSchool,
  assignTeacherToClass
);

export default router;
