/**
 * @swagger
 * tags:
 *   name: Questions
 *   description: Quản lý câu hỏi (Nhà trường tạo bài học / Giáo viên tạo bài kiểm tra)
 */

/* ================= POST /api/questions (SCHOOL) ================= */

/**
 * @swagger
 * /api/questions:
 *   post:
 *     summary: "[Nhà trường] Tạo question mới cho Bài học (Lesson)"
 *     description: >
 *       - Dành riêng cho tài khoản **Nhà trường (SCHOOL)**.
 *       - Dùng để gắn câu hỏi vào bài học (`lessonId`).
 *       - Hỗ trợ tạo 1 câu (multipart/form-data) hoặc hàng loạt (application/json).
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
 *               - lessonId
 *               - skill
 *               - type
 *               - content
 *             properties:
 *               lessonId:
 *                 type: string
 *                 description: ID bài học để gắn câu hỏi.
 *                 example: "507f1f77bcf86cd799439011"
 *               classId:
 *                 type: string
 *                 description: Bỏ trống nếu tạo cho toàn trường, điền ID lớp nếu tạo riêng cho lớp.
 *               skill:
 *                 type: string
 *                 enum: [vocabulary, grammar, reading, listening, speaking, writing]
 *               type:
 *                 type: string
 *                 enum: [mcq, true_false, fill_blank, matching, essay]
 *               content:
 *                 type: string
 *                 description: Nội dung câu hỏi (HTML/Text).
 *               points:
 *                 type: number
 *                 default: 1
 *               options:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Danh sách lựa chọn cho MCQ.
 *               correctAnswer:
 *                 type: string
 *               explanation:
 *                 type: string
 *               isPublished:
 *                 type: boolean
 *                 default: true
 *               deadline:
 *                 type: string
 *                 format: date-time
 *                 description: Cập nhật hạn nộp cho Bài học (Hệ thống tính theo múi giờ VN +7)
 *                 example: "2026-01-15T23:59:59Z"
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               imageCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               audios:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               audioCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               videos:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               videoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               youtubeVideos:
 *                 type: array
 *                 items:
 *                   type: string
 *               youtubeVideoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               lessonId:
 *                 type: string
 *               deadline:
 *                 type: string
 *                 format: date-time
 *               questions:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required: [skill, type, content]
 *                   properties:
 *                     skill:
 *                       type: string
 *                     type:
 *                       type: string
 *                     content:
 *                       type: string
 *                     options:
 *                       type: array
 *                       items:
 *                         type: string
 *                     correctAnswer:
 *                       type: string
 *                     points:
 *                       type: number
 *     responses:
 *       201:
 *         description: Nhà trường tạo thành công
 *       403:
 *         description: Chỉ nhà trường mới có quyền (dành cho bài học)
 */

/* ================= POST /api/questions/teacher (TEACHER) ================= */

/**
 * @swagger
 * /api/questions/teacher:
 *   post:
 *     summary: "[Giáo viên] Tạo question bài kiểm tra (Exam)"
 *     description: >
 *       - Dành riêng cho tài khoản **Giáo viên (TEACHER)**.
 *       - Dùng để gắn câu hỏi vào bài kiểm tra (`examId`).
 *       - Tự động gán lớp dựa trên Exam.
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
 *               - examId
 *               - skill
 *               - type
 *               - content
 *             properties:
 *               examId:
 *                 type: string
 *                 description: ID bài kiểm tra (15p/45p).
 *                 example: "507f1f77bcf86cd799439099"
 *               skill:
 *                 type: string
 *                 enum: [vocabulary, grammar, reading, listening, speaking, writing]
 *               type:
 *                 type: string
 *                 enum: [mcq, true_false, fill_blank, matching, essay]
 *               content:
 *                 type: string
 *               points:
 *                 type: number
 *                 default: 1
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
 *                 default: true
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               imageCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               audios:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               audioCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               videos:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               videoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               youtubeVideos:
 *                 type: array
 *                 items:
 *                   type: string
 *               youtubeVideoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               examId:
 *                 type: string
 *               questions:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required: [skill, type, content]
 *                   properties:
 *                     skill:
 *                       type: string
 *                     type:
 *                       type: string
 *                     content:
 *                       type: string
 *                     points:
 *                       type: number
 *     responses:
 *       201:
 *         description: Giáo viên tạo thành công
 *       403:
 *         description: Chỉ giáo viên sở hữu đề thi mới được phép
 */

/**
 * @swagger
 * /api/questions/{id}:
 *   patch:
 *     summary: Cập nhật câu hỏi (Nhà trường / Giáo viên)
 *     description: >
 *       - Nhà trường: Sửa câu hỏi bài học.
 *       - Giáo viên: Sửa câu hỏi bài kiểm tra của mình.
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
 *               points:
 *                 type: number
 *               isPublished:
 *                 type: boolean
 *         multipart/form-data:
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
 *               points:
 *                 type: number
 *               isPublished:
 *                 type: boolean
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               imageCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               audios:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               audioCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               videos:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               videoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *               youtubeVideos:
 *                 type: array
 *                 items:
 *                   type: string
 *               youtubeVideoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 */

/**
 * @swagger
 * /api/questions/{id}:
 *   delete:
 *     summary: Xóa câu hỏi (Nhà trường / Giáo viên)
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
 *         description: Xóa thành công
 */

/**
 * @swagger
 * /api/questions/lesson/{lessonId}:
 *   get:
 *     summary: Lấy danh sách câu hỏi theo bài học (Student/Teacher)
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
 *         description: Thành công
 */
