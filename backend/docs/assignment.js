/**
 * @swagger
 * tags:
 *   name: Assignments
 *   description: Thiết lập bài tập (Hạn nộp, công khai...) cho từng lớp/bài học
 */

/**
 * @swagger
 * /api/assignments:
 *   post:
 *     summary: Thiết lập bài tập (Hạn nộp) cho lớp (Giảng viên)
 *     description: >
 *       Giáo viên thiết lập thời hạn cho một bài học cụ thể trong lớp mình chủ nhiệm.
 *       Nếu một thiết lập đã tồn tại cho cặp (Lớp, Bài học) này, nó sẽ được cập nhật.
 *     tags: [Assignments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - lessonId
 *             properties:
 *               lessonId:
 *                 type: string
 *                 description: ID của bài học (Lesson)
 *               classId:
 *                 type: string
 *                 description: ID của lớp (Nếu không truyền sẽ lấy lớp chủ nhiệm)
 *               deadline:
 *                 type: string
 *                 format: date-time
 *                 description: Thời hạn nộp bài
 *                 example: "2026-01-30T23:59:59+07:00"
 *               description:
 *                 type: string
 *                 description: Hướng dẫn/Mô tả bài tập
 *               isPublished:
 *                 type: boolean
 *                 default: true
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *       403:
 *         description: Không phải giáo viên chủ nhiệm
 */

/**
 * @swagger
 * /api/assignments/lesson/{lessonId}:
 *   get:
 *     summary: Lấy thiết lập bài tập theo bài học (Giảng viên, Học sinh)
 *     tags: [Assignments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: lessonId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - name: classId
 *         in: query
 *         required: false
 *         schema:
 *           type: string
 *         description: ID của lớp (Dành cho giáo viên muốn xem lớp cụ thể)
 *     responses:
 *       200:
 *         description: Thông tin thiết lập (bao gồm deadline)
 */
