import express from "express";
import {
    createAssignment,
    getAssignments,
    getAssignmentById,
    updateAssignment,
    deleteAssignment,
} from "../controller/assignmentController.js";
import { authenticate, isTeacher, isSchool } from "../middlewares/authMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Assignments
 *   description: Quản lý bài tập
 */

// Create
router.post("/", authenticate, createAssignment); // Teacher/School creates

// Read
router.get("/", authenticate, getAssignments); // All authenticated can read (filter logic in controller)
router.get("/:id", authenticate, getAssignmentById);

// Update
router.put("/:id", authenticate, updateAssignment); // Teacher/School updates

// Delete
router.delete("/:id", authenticate, deleteAssignment); // Teacher/School deletes

export default router;
