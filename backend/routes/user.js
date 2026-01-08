import express from "express";
import {
  getAllStudents,
  createStudent,
  updateStudent,
  deleteStudent,
  disableUser,
  enableUser,
  getAssignableStudents,
} from "../controller/userController.js";

import {
  authenticate,
  isAdmin,
  isSchool,
  isTeacher,
} from "../middlewares/authMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Students
 *   description: Quản lý học sinh (School / Admin)
 */

/* ================= SCHOOL / ADMIN ================= */

/**
 * @swagger
 * /api/users/students:
 *   post:
 *     summary: Tạo học sinh mới
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - email
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *                 example: student01
 *               email:
 *                 type: string
 *                 example: student01@gmail.com
 *               password:
 *                 type: string
 *                 example: 123456
 *     responses:
 *       201:
 *         description: Tạo học sinh thành công
 */
router.post("/students", authenticate, isSchool, createStudent);

/**
 * @swagger
 * /api/users/students:
 *   get:
 *     summary: Lấy danh sách học sinh
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách học sinh
 */
router.get("/students", authenticate, isSchool, getAllStudents);

/**
 * @swagger
 * /api/users/students/{id}:
 *   put:
 *     summary: Cập nhật học sinh
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
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
 */

router.put("/students/:id", authenticate, isSchool, updateStudent);

/**
 * @swagger
 * /api/users/students/{id}:
 *   delete:
 *     summary: Xóa học sinh
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *     responses:
 *       200:
 *         description: Xóa học sinh thành công
 */
router.delete("/students/:id", authenticate, isSchool, deleteStudent);

/**
 * @swagger
 * /api/users/students/{id}/disable:
 *   put:
 *     summary: Khóa tài khoản học sinh
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *     responses:
 *       200:
 *         description: Khóa học sinh thành công
 */
router.put("/students/:id/disable", authenticate, isSchool, disableUser);

/**
 * @swagger
 * /api/users/students/{id}/enable:
 *   put:
 *     summary: Mở khóa tài khoản học sinh
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *     responses:
 *       200:
 *         description: Mở khóa học sinh thành công
 */
router.put("/students/:id/enable", authenticate, isSchool, enableUser);

/* ================= TEACHER ================= */

/**
 * @swagger
 * /api/users/students/assignable:
 *   get:
 *     summary: Giảng viên lấy danh sách học sinh đang hoạt động
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách học sinh
 */
router.get(
  "/students/assignable",
  authenticate,
  isTeacher,
  getAssignableStudents
);

export default router;
