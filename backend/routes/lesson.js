import express from "express";
import {
  createLesson,
  getLessonsByUnit,
  updateLesson,
  deleteLesson,
} from "../controller/lessonController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";
import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Lessons
 *   description: Quản lý bài học(School CRUD, Teacher / Student xem)
 */

/* ================= SCHOOL / ADMIN ================= */

/**
 * @swagger
 * /api/lessons:
 *   post:
 *     summary: Nhà trường tạo lesson mới (có upload media)
 *     tags: [Lessons]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
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
 *               isPublished:
 *                 type: boolean
 *
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               imageCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *
 *               audios:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               audioCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *
 *               videos:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               videoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       201:
 *         description: Tạo lesson thành công
 */
router.post(
  "/",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  createLesson
);

/**
 * @swagger
 * /api/lessons/{id}:
 *   patch:
 *     summary: Nhà trường cập nhật lesson (nội dung + media đã reorder)
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
 *               isPublished:
 *                 type: boolean
 *
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
 *
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
 *
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
 *     summary: Giáo viên & học sinh xem danh sách lesson theo unit
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
