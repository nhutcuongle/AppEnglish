import express from "express";
import {
  createTeacher,
  getTeachers,
  updateTeacher,
  deleteTeacher,
} from "../controller/teacherController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";

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
// TODO: Add back authentication after testing: authenticate, isSchool
router.post("/", createTeacher);

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

export default router;
