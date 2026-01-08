import express from "express";
import {
  createLesson,
  getLessonsByUnit,
  updateLesson,
  deleteLesson,
} from "../controller/lessonController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Lessons
 *   description: Quản lý bài học (School CRUD, Teacher / Student xem)
 */

/* ================= SCHOOL / ADMIN ================= */

/**
 * @swagger
 * /api/lessons:
 *   post:
 *     summary: Nhà trường tạo lesson mới
 *     tags: [Lessons]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - unit
 *               - title
 *             properties:
 *               unit:
 *                 type: string
 *                 example: 695f79f2927eb2fb1a5d9ed3
 *               title:
 *                 type: string
 *                 example: Listening - Greetings
 *               content:
 *                 type: string
 *                 example: Nội dung bài nghe chào hỏi
 *               order:
 *                 type: number
 *                 example: 1
 *               isPublished:
 *                 type: boolean
 *                 example: false
 *               images:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     url:
 *                       type: string
 *                       example: https://res.cloudinary.com/xxx/image1.webp
 *                     caption:
 *                       type: string
 *                       example: Ảnh minh họa
 *                     order:
 *                       type: number
 *                       example: 1
 *               audios:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     url:
 *                       type: string
 *                       example: https://res.cloudinary.com/xxx/audio1.mp3
 *                     caption:
 *                       type: string
 *                       example: Bài nghe số 1
 *                     order:
 *                       type: number
 *                       example: 1
 *               videos:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     url:
 *                       type: string
 *                       example: https://res.cloudinary.com/xxx/video1.mp4
 *                     caption:
 *                       type: string
 *                       example: Video hội thoại
 *                     order:
 *                       type: number
 *                       example: 1
 *     responses:
 *       201:
 *         description: Tạo lesson thành công
 */
router.post("/", authenticate, isSchool, createLesson);

/**
 * @swagger
 * /api/lessons/{id}:
 *   patch:
 *     summary: Nhà trường cập nhật lesson (cập nhật từng phần)
 *     tags: [Lessons]
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
 *               title:
 *                 type: string
 *               content:
 *                 type: string
 *               order:
 *                 type: number
 *               isPublished:
 *                 type: boolean
 *               images:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     url:
 *                       type: string
 *                     caption:
 *                       type: string
 *                     order:
 *                       type: number
 *               audios:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     url:
 *                       type: string
 *                     caption:
 *                       type: string
 *                     order:
 *                       type: number
 *               videos:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     url:
 *                       type: string
 *                     caption:
 *                       type: string
 *                     order:
 *                       type: number
 *     responses:
 *       200:
 *         description: Cập nhật lesson thành công
 *       404:
 *         description: Không tìm thấy lesson
 */
router.patch("/:id", authenticate, isSchool, updateLesson);

/**
 * @swagger
 * /api/lessons/{id}:
 *   delete:
 *     summary: Nhà trường xóa lesson
 *     tags: [Lessons]
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
 *         description: Xóa lesson thành công
 *       404:
 *         description: Không tìm thấy lesson
 */
router.delete("/:id", authenticate, isSchool, deleteLesson);

/* ================= TEACHER / STUDENT ================= */

/**
 * @swagger
 * /api/lessons/unit/{unitId}:
 *   get:
 *     summary: Giáo viên & học sinh xem danh sách lesson theo unit (chỉ lesson đã publish)
 *     tags: [Lessons]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: unitId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Danh sách lesson
 */
router.get("/unit/:unitId", authenticate, getLessonsByUnit);

export default router;
