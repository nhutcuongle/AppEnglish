import express from "express";
import {
  createGrammar,
  getGrammarByLesson,
  updateGrammar,
  deleteGrammar,
} from "../controller/grammarController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";
import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Grammar
 *   description: Quản lý ngữ pháp theo lesson (lessonType = grammar)
 */

/* ================= SCHOOL ================= */

/**
 * @swagger
 * /api/grammar:
 *   post:
 *     summary: Nhà trường tạo nội dung ngữ pháp cho lesson
 *     tags: [Grammar]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - lesson
 *               - title
 *               - theory
 *             properties:
 *               lesson:
 *                 type: string
 *                 description: ID lesson (lessonType = grammar)
 *                 example: 665f79f2927eb2fb1a5d9ed3
 *
 *               title:
 *                 type: string
 *                 example: Present Simple Tense
 *
 *               theory:
 *                 type: string
 *                 description: Nội dung lý thuyết (HTML / rich text)
 *                 example: "<p>Present Simple is used for facts...</p>"
 *
 *               examples:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example:
 *                   - "I go to school every day."
 *                   - "She works as a teacher."
 *
 *               isPublished:
 *                 type: boolean
 *                 example: true
 *
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *
 *               audios:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *
 *               videos:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Tạo grammar thành công
 *       400:
 *         description: Lesson không hợp lệ hoặc không phải grammar
 */
router.post(
  "/",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  createGrammar
);

/**
 * @swagger
 * /api/grammar/{id}:
 *   patch:
 *     summary: Nhà trường cập nhật nội dung grammar
 *     tags: [Grammar]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *         description: Grammar ID
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               theory:
 *                 type: string
 *               examples:
 *                 type: array
 *                 items:
 *                   type: string
 *               order:
 *                 type: number
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
 *         description: Cập nhật grammar thành công
 *       404:
 *         description: Không tìm thấy grammar
 */
router.patch("/:id", authenticate, isSchool, updateGrammar);

/**
 * @swagger
 * /api/grammar/{id}:
 *   delete:
 *     summary: Nhà trường xóa grammar
 *     tags: [Grammar]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *         description: Grammar ID
 *     responses:
 *       200:
 *         description: Xóa grammar thành công
 *       404:
 *         description: Không tìm thấy grammar
 */
router.delete("/:id", authenticate, isSchool, deleteGrammar);

/* ================= TEACHER / STUDENT ================= */

/**
 * @swagger
 * /api/grammar/lesson/{lessonId}:
 *   get:
 *     summary: Giáo viên & học sinh xem grammar theo lesson
 *     tags: [Grammar]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: lessonId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *         description: Lesson ID (lessonType = grammar)
 *     responses:
 *       200:
 *         description: Danh sách grammar của lesson
 */
router.get("/lesson/:lessonId", authenticate, getGrammarByLesson);

export default router;
