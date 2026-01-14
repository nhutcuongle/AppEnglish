import express from "express";
import {
  getAllStudents,
  createStudent,
  updateStudent,
  deleteStudent,
  disableUser,
  enableUser,
  getAssignableStudents,
  updateProfile,
  getProfile,
  getStudentsByClassForTeacher,
  getMyStudents,
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

router.post("/students", authenticate, isSchool, createStudent);

router.get("/students", authenticate, isSchool, getAllStudents);

/**
 * @swagger
 * /api/users/profile:
 *   put:
 *     summary: Cập nhật thông tin cá nhân (School / Teacher / Student)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               fullName:
 *                 type: string
 *               academicYear:
 *                 type: string
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 */
router.put("/profile", authenticate, updateProfile);

/**
 * @swagger
 * /api/users/profile:
 *   get:
 *     summary: Lấy thông tin cá nhân
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Thông tin user
 */
router.get("/profile", authenticate, getProfile);

/**
 * @swagger
 * /api/users/students/{id}:
 *   put:
 *     summary: Cập nhật thông tin học sinh (không đổi lớp)
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *           example: "64b9f3d8c2a1e9a123456789"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *       404:
 *         description: Không tìm thấy học sinh
 */
router.put("/students/:id", authenticate, isSchool, updateStudent);

router.delete("/students/:id", authenticate, isSchool, deleteStudent);

router.put("/students/:id/disable", authenticate, isSchool, disableUser);

router.put("/students/:id/enable", authenticate, isSchool, enableUser);

/* =====================================================
   TEACHER
===================================================== */
router.get("/teacher/class-students/:classId", authenticate, isTeacher, getStudentsByClassForTeacher);
router.get("/teacher/my-students", authenticate, isTeacher, getMyStudents);

export default router;
