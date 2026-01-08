import express from "express";
import {
  createTeacher,
  getTeachers,
  updateTeacher,
  deleteTeacher,
  getMyClassStudents,
} from "../controller/teacherController.js";

import {
  authenticate,
  isSchool,
  isTeacher,
} from "../middlewares/authMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Teachers
 *   description: Quản lý giảng viên (School)
 */

/* ================= SCHOOL ================= */

/**
 * @swagger
 * /api/teachers:
 *   post:
 *     summary: Tạo giảng viên mới
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [username, email, password]
 *             properties:
 *               username:
 *                 type: string
 *                 example: teacher01
 *               email:
 *                 type: string
 *                 example: teacher01@gmail.com
 *               password:
 *                 type: string
 *                 example: 123456
 *     responses:
 *       201:
 *         description: Tạo giảng viên thành công
 */
router.post("/", authenticate, isSchool, createTeacher);

/**
 * @swagger
 * /api/teachers:
 *   get:
 *     summary: Lấy danh sách giảng viên
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách giảng viên
 */
router.get("/", authenticate, isSchool, getTeachers);

/**
 * @swagger
 * /api/teachers/{id}:
 *   put:
 *     summary: Cập nhật giảng viên
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *               email:
 *                 type: string
 *               isDisabled:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *       404:
 *         description: Không tìm thấy giảng viên
 */
router.put("/:id", authenticate, isSchool, updateTeacher);

/**
 * @swagger
 * /api/teachers/{id}:
 *   delete:
 *     summary: Xóa giảng viên
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *     responses:
 *       200:
 *         description: Xóa giảng viên thành công
 *       404:
 *         description: Không tìm thấy giảng viên
 */
router.delete("/:id", authenticate, isSchool, deleteTeacher);

/**
 * @swagger
 * /api/teachers/my-class/students:
 *   get:
 *     summary: Lấy danh sách học sinh lớp chủ nhiệm của giảng viên(teacher)
 *     description: |
 *       API dành cho **giảng viên**.
 *       Trả về danh sách học sinh của lớp mà giảng viên đang làm giáo viên chủ nhiệm.
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy danh sách học sinh thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 class:
 *                   type: string
 *                   example: "10A1"
 *                 students:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       _id:
 *                         type: string
 *                         example: "64b9f3d8c2a1e9a123456789"
 *                       username:
 *                         type: string
 *                         example: "student01"
 *                       email:
 *                         type: string
 *                         example: "student01@gmail.com"
 *       401:
 *         description: Không có quyền truy cập (chưa đăng nhập hoặc không phải giảng viên)
 *       404:
 *         description: Giảng viên chưa được phân lớp
 *       500:
 *         description: Lỗi server
 */

router.get("/my-class/students", authenticate, isTeacher, getMyClassStudents);

export default router;
