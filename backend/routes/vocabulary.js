import express from "express";
import {
  createVocabulary,
  getVocabularyByLesson,
  updateVocabulary,
  deleteVocabulary,
} from "../controller/vocabularyController.js";

import { authenticate, isSchool } from "../middlewares/authMiddleware.js";
import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Vocabulary
 *   description: Quản lý từ vựng theo lesson (School CRUD, Teacher / Student xem)
 */

/* ================= SCHOOL / ADMIN ================= */

/**
 * @swagger
 * /api/vocabularies:
 *   post:
 *     summary: Nhà trường tạo từ vựng mới
 *     tags: [Vocabulary]
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
 *               - word
 *               - meaning
 *             properties:
 *               lesson:
 *                 type: string
 *                 example: 695f79f2927eb2fb1a5d9ed3
 *
 *               word:
 *                 type: string
 *                 example: family
 *
 *               phonetic:
 *                 type: string
 *                 example: /ˈfæm.əl.i/
 *
 *               meaning:
 *                 type: string
 *                 example: gia đình
 *
 *               example:
 *                 type: string
 *                 example: My family is very close.
 *
 *               isPublished:
 *                 type: boolean
 *
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *
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
 *
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
 *
 *               videoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       201:
 *         description: Tạo từ vựng thành công
 *       400:
 *         description: Dữ liệu không hợp lệ
 */
router.post(
  "/",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  createVocabulary
);

/**
 * @swagger
 * /api/vocabularies/{id}:
 *   patch:
 *     summary: Nhà trường cập nhật từ vựng
 *     tags: [Vocabulary]
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
 *               word:
 *                 type: string
 *               phonetic:
 *                 type: string
 *               meaning:
 *                 type: string
 *               example:
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
 *         description: Cập nhật từ vựng thành công
 *       404:
 *         description: Không tìm thấy từ vựng
 */
router.patch(
  "/:id",
  authenticate,
  isSchool,
  uploadMultipleMedia,
  uploadErrorHandler,
  updateVocabulary
);

/**
 * @swagger
 * /api/vocabularies/{id}:
 *   delete:
 *     summary: Nhà trường xóa từ vựng
 *     tags: [Vocabulary]
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
 *         description: Xóa từ vựng thành công
 *       404:
 *         description: Không tìm thấy từ vựng
 */
router.delete("/:id", authenticate, isSchool, deleteVocabulary);

/* ================= TEACHER / STUDENT ================= */

/**
 * @swagger
 * /api/vocabularies/lesson/{lessonId}:
 *   get:
 *     summary: Giáo viên & học sinh xem danh sách từ vựng theo lesson
 *     tags: [Vocabulary]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: lessonId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Danh sách từ vựng
 */
router.get(
  "/lesson/:lessonId",
  authenticate,
  getVocabularyByLesson
);

export default router;
