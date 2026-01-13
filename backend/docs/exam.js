/**
 * @swagger
 * tags:
 *   name: Exams
 *   description: Chức năng Bài kiểm tra (15 phút / 45 phút) dành cho Giảng viên và Học sinh
 */

/**
 * @swagger
 * /api/exams:
 *   post:
 *     summary: Tạo bài kiểm tra mới (Giảng viên)
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, type, classId, startTime, endTime]
 *             properties:
 *               title:
 *                 type: string
 *                 example: "Kiểm tra 15 phút Unit 1"
 *               type:
 *                 type: string
 *                 enum: [15m, 45m]
 *               classId:
 *                 type: string
 *               startTime:
 *                 type: string
 *                 format: date-time
 *               endTime:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       201:
 *         description: Tạo thành công
 */

/**
 * @swagger
 * /api/exams/teacher:
 *   get:
 *     summary: Lấy danh sách bài kiểm tra đã tạo (Giảng viên)
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách bài kiểm tra
 */

/**
 * @swagger
 * /api/exams/{id}:
 *   patch:
 *     summary: Cập nhật bài kiểm tra (Giảng viên)
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
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
 *               type:
 *                 type: string
 *                 enum: [15m, 45m]
 *               startTime:
 *                 type: string
 *                 format: date-time
 *               endTime:
 *                 type: string
 *                 format: date-time
 *               isPublished:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 */

/**
 * @swagger
 * /api/exams/{id}:
 *   delete:
 *     summary: Xóa bài kiểm tra (Giảng viên)
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Xóa thành công
 */

/**
 * @swagger
 * /api/exams/student:
 *   get:
 *     summary: Lấy danh sách bài kiểm tra của lớp (Học sinh)
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách bài kiểm tra
 */

/**
 * @swagger
 * /api/exams/submit:
 *   post:
 *     summary: Nộp bài kiểm tra (Học sinh)
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [examId, answers]
 *             properties:
 *               examId:
 *                 type: string
 *               answers:
 *                 type: array
 *                 items:
 *                   type: object
 *     responses:
 *       201:
 *         description: Nộp bài thành công
 */

/**
 * @swagger
 * /api/exams/report/{id}:
 *   get:
 *     summary: Xem báo cáo kết quả bài kiểm tra (Giảng viên)
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Báo cáo điểm số
 */

/**
 * @swagger
 * /api/exams/{id}/questions:
 *   get:
 *     summary: Lấy danh sách câu hỏi của bài kiểm tra
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Danh sách câu hỏi
 */
