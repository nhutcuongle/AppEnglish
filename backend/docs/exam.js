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
 *     description: >
 *       Sử dụng để tạo khung (metadata) cho một bài kiểm tra 15p hoặc 45p.
 *       Sau khi tạo xong, bạn lấy `_id` của bài kiểm tra để tiếp tục tạo câu hỏi ở mục **Questions**.
 *     tags: [Exams]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ExamRequest'
 *         multipart/form-data:
 *           schema:
 *             $ref: '#/components/schemas/ExamRequest'
 *     responses:
 *       201:
 *         description: Tạo thành công
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     ExamRequest:
 *       type: object
 *       required: [title, type, classId, startTime, endTime]
 *       properties:
 *         title:
 *           type: string
 *           description: Tiêu đề bài kiểm tra
 *           example: "Kiểm tra 15 phút Unit 1"
 *         type:
 *           type: string
 *           enum: [15m, 45m]
 *           description: Loại bài kiểm tra
 *         classId:
 *           type: string
 *           description: ID của lớp mà bạn đang chủ nhiệm
 *         startTime:
 *           type: string
 *           format: date-time
 *           description: Thời gian bắt đầu làm bài
 *         endTime:
 *           type: string
 *           format: date-time
 *           description: Thời gian kết thúc/hết hạn nộp bài
 *         description:
 *           type: string
 *           description: Mô tả chi tiết bài kiểm tra
 *         semester:
 *           type: string
 *           enum: ["1", "2"]
 *           description: Học kỳ
 *         academicYear:
 *           type: string
 *           description: Năm học (VD 2023-2024)
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
 *               description:
 *                 type: string
 *               semester:
 *                 type: string
 *               academicYear:
 *                 type: string
 *               isPublished:
 *                 type: boolean
 *         multipart/form-data:
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
 *               description:
 *                 type: string
 *               semester:
 *                 type: string
 *               academicYear:
 *                 type: string
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
