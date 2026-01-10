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
  isSchool,
  isTeacher,
} from "../middlewares/authMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Students
 *   description: Quản lý học sinh (School / Teacher)
 */

/* =====================================================
   SCHOOL
===================================================== */

/**
 * @swagger
 * /api/users/students:
 *   post:
 *     summary: Tạo học sinh mới (có thể gán lớp)
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
 *                 example: "Nguyễn Văn A"
 *               email:
 *                 type: string
 *                 example: "a@gmail.com"
 *               password:
 *                 type: string
 *                 example: "123456"
 *               classId:
 *                 type: string
 *                 nullable: true
 *                 example: "64b9f3d8c2a1e9a987654321"
 *     responses:
 *       201:
 *         description: Tạo học sinh thành công
 *       400:
 *         description: Lớp không hợp lệ
 *       401:
 *         description: Chưa đăng nhập
 */
// TODO: Add back authentication after testing: authenticate, isSchool
router.post("/students", createStudent);

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
 *       401:
 *         description: Chưa đăng nhập
 */
router.get("/students", authenticate, isSchool, getAllStudents);

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
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Xóa học sinh thành công
 *       404:
 *         description: Không tìm thấy học sinh
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
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Khóa tài khoản thành công
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
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Mở khóa tài khoản thành công
 */
router.put("/students/:id/enable", authenticate, isSchool, enableUser);

/* =====================================================
   TEACHER
===================================================== */

/**
 * @swagger
 * /api/users/students/assignable:
 *   get:
 *     summary: Giáo viên lấy danh sách học sinh đang hoạt động
 *     description: |
 *       Dùng để gán bài / giao bài cho học sinh.
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách học sinh
 *       401:
 *         description: Chưa đăng nhập
 *       403:
 *         description: Không có quyền
 */
router.get(
  "/students/assignable",
  authenticate,
  isTeacher,
  getAssignableStudents
);

export default router;
