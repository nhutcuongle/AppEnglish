import express from "express";
import {
  createUnit,
  getAllUnitsForSchool,
  getAllUnitsForTeacher,
  getPublishedUnits,
  getUnitById,
  updateUnit,
  deleteUnit,
  getPublishedUnitById,
} from "../controller/unitController.js";

import {
  authenticate,
  isSchool,
  isTeacher,
} from "../middlewares/authMiddleware.js";

import {
  uploadSingleImage,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/* ================= STUDENT ================= */

router.get("/public", getPublishedUnits);

router.get("/public/:id", getPublishedUnitById);

/* ================= TEACHER ================= */

router.get("/teacher/all", authenticate, isTeacher, getAllUnitsForTeacher);

router.get("/teacher/:id", authenticate, isTeacher, getUnitById);

/* ================= SCHOOL / ADMIN ================= */

router.post(
  "/",
  authenticate,
  isSchool,
  uploadSingleImage,
  uploadErrorHandler,
  createUnit
);

router.get("/", authenticate, isSchool, getAllUnitsForSchool);

router.get("/:id", authenticate, isSchool, getUnitById);

router.put(
  "/:id",
  authenticate,
  isSchool,
  uploadSingleImage,
  uploadErrorHandler,
  updateUnit
);

router.delete("/:id", authenticate, isSchool, deleteUnit);


export default router;
