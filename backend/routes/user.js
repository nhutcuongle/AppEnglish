import express from "express";
import {
  getAllStudents,
  createStudent,
  updateStudent,
  deleteStudent,
  disableUser,
  enableUser,
} from "../controller/userController.js";

import {
  authenticate,
  isSchool,
  isTeacher,
} from "../middlewares/authMiddleware.js";

const router = express.Router();

/* =====================================================
   SCHOOL
===================================================== */

// TODO: Add back authentication after testing: authenticate, isSchool
router.post("/students", authenticate, isSchool, createStudent);

router.get("/students", authenticate, isSchool, getAllStudents);

router.put("/students/:id", authenticate, isSchool, updateStudent);

router.delete("/students/:id", authenticate, isSchool, deleteStudent);

router.put("/students/:id/disable", authenticate, isSchool, disableUser);

router.put("/students/:id/enable", authenticate, isSchool, enableUser);

export default router;
