import express from "express";
import {
  createQuestion,
  getQuestionsByLesson,
  getQuestionsByAssignment,
  updateQuestion,
  deleteQuestion,
} from "../controller/questionController.js";

import { authenticate, isTeacher } from "../middlewares/authMiddleware.js";
import {
  uploadMultipleMedia,
  uploadErrorHandler,
} from "../middlewares/uploadMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Questions
 *   description: Bài tập / câu hỏi cho tất cả kỹ năng (Teacher CRUD, Student xem)
 */

/* ================= TEACHER ================= */

/**
 * @swagger
 * /api/questions:
 *   post:
 *     summary: Giáo viên tạo question mới (có thể upload media)
 *     tags: [Questions]
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
 *               - skill
 *               - type
 *               - content
 *             properties:
 *               lesson:
 *                 type: string
 *                 example: 695f79f2927eb2fb1a5d9ed3
 *
 *               skill:
 *                 type: string
 *                 enum:
 *                   - vocabulary
 *                   - grammar
 *                   - reading
 *                   - listening
 *                   - speaking
 *                   - writing
 *
 *               type:
 *                 type: string
 *                 enum:
 *                   - mcq
 *                   - true_false
 *                   - fill_blank
 *                   - matching
 *                   - essay
 *
 *               content:
 *                 type: string
 *                 description: Nội dung câu hỏi (HTML / Rich Text)
 *
 *               options:
 *                 type: array
 *                 items:
 *                   type: string
 *
 *               correctAnswer:
 *                 type: string
 *
 *               explanation:
 *                 type: string
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
 *         description: Tạo question thành công
 *       400:
 *         description: Dữ liệu không hợp lệ
 */
router.post(
  "/",
  authenticate,
  isTeacher,
  uploadMultipleMedia,
  uploadErrorHandler,
  createQuestion
);

/**
 * @swagger
 * /api/questions/{id}:
 *   patch:
 *     summary: Giáo viên cập nhật question
 *     tags: [Questions]
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
 *               content:
 *                 type: string
 *               options:
 *                 type: array
 *                 items:
 *                   type: string
 *               correctAnswer:
 *                 type: string
 *               explanation:
 *                 type: string
 *               isPublished:
 *                 type: boolean
 *               images:
 *                 type: array
 *               audios:
 *                 type: array
 *               videos:
 *                 type: array
 *     responses:
 *       200:
 *         description: Cập nhật question thành công
 *       404:
 *         description: Không tìm thấy question
 */
router.patch(
  "/:id",
  authenticate,
  isTeacher,
  uploadMultipleMedia,
  uploadErrorHandler,
  updateQuestion
);

/**
 * @swagger
 * /api/questions/{id}:
 *   delete:
 *     summary: Giáo viên xóa question
 *     tags: [Questions]
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
 *         description: Xóa question thành công
 *       404:
 *         description: Không tìm thấy question
 */
router.delete("/:id", authenticate, isTeacher, deleteQuestion);

/* ================= STUDENT / TEACHER ================= */

/**
 * @swagger
 * /api/questions/lesson/{lessonId}:
 *   get:
 *     summary: Giáo viên & học sinh xem danh sách question theo lesson
 *     tags: [Questions]
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
 *         description: Danh sách question
 */
router.get(
  "/lesson/:lessonId",
  authenticate,
  getQuestionsByLesson
);

router.get(
  "/assignment/:assignmentId",
  authenticate,
  getQuestionsByAssignment
);

export default router;
