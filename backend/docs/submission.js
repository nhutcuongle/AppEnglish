/**
 * @swagger
 * tags:
 *   name: Submissions
 *   description: Học sinh làm bài & nộp bài
 */

/**
 * @swagger
 * /api/submissions/submit:
 *   post:
 *     summary: Nộp bài học
 *     description: Học sinh nộp câu trả lời cho các câu hỏi trong bài học và nhận điểm theo từng kỹ năng
 *     tags: [Submissions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - lesson
 *               - answers
 *             properties:
 *               lesson:
 *                 type: string
 *                 description: ID của bài học
 *                 example: "507f1f77bcf86cd799439011"
 *               answers:
 *                 type: array
 *                 description: Danh sách câu trả lời của học sinh
 *                 items:
 *                   type: object
 *                   required:
 *                     - question
 *                     - userAnswer
 *                   properties:
 *                     question:
 *                       type: string
 *                       description: ID của câu hỏi
 *                       example: "507f1f77bcf86cd799439012"
 *                     userAnswer:
 *                       oneOf:
 *                         - type: string
 *                         - type: number
 *                         - type: array
 *                           items:
 *                             type: string
 *                       description: Câu trả lời của học sinh (có thể là string, number, hoặc array tùy loại câu hỏi)
 *                       example: "A"
 *     responses:
 *       201:
 *         description: Nộp bài thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Nộp bài thành công"
 *                 submissionId:
 *                   type: string
 *                   example: "507f1f77bcf86cd799439013"
 *                 scores:
 *                   type: object
 *                   description: Điểm theo từng kỹ năng
 *                   properties:
 *                     vocabulary:
 *                       type: number
 *                       example: 5
 *                     grammar:
 *                       type: number
 *                       example: 4
 *                     reading:
 *                       type: number
 *                       example: 3
 *                     listening:
 *                       type: number
 *                       example: 2
 *                     speaking:
 *                       type: number
 *                       example: 0
 *                     writing:
 *                       type: number
 *                       example: 0
 *                 totalScore:
 *                   type: number
 *                   description: Tổng điểm
 *                   example: 14
 *       400:
 *         description: Thiếu dữ liệu hoặc dữ liệu không hợp lệ
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Thiếu dữ liệu submit"
 *       401:
 *         description: Chưa xác thực hoặc không có quyền truy cập
 *       500:
 *         description: Lỗi server
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 error:
 *                   type: string
 *                   example: "Internal server error"
 */

/**
 * @swagger
 * /api/submissions/my:
 *   get:
 *     summary: Xem danh sách bài làm của tôi
 *     description: Học sinh xem tất cả bài làm đã nộp của mình với điểm theo từng kỹ năng
 *     tags: [Submissions]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy danh sách thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total:
 *                   type: number
 *                   example: 5
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       submissionId:
 *                         type: string
 *                         example: "507f1f77bcf86cd799439013"
 *                       lesson:
 *                         type: object
 *                         properties:
 *                           _id:
 *                             type: string
 *                           title:
 *                             type: string
 *                           lessonType:
 *                             type: string
 *                       scores:
 *                         type: object
 *                         properties:
 *                           vocabulary:
 *                             type: number
 *                           grammar:
 *                             type: number
 *                           reading:
 *                             type: number
 *                           listening:
 *                             type: number
 *                           speaking:
 *                             type: number
 *                           writing:
 *                             type: number
 *                       totalScore:
 *                         type: number
 *                         example: 14
 *                       submittedAt:
 *                         type: string
 *                         format: date-time
 *       401:
 *         description: Chưa xác thực
 *       500:
 *         description: Lỗi server
 */

/**
 * @swagger
 * /api/submissions/{id}:
 *   get:
 *     summary: Xem chi tiết bài làm của tôi
 *     description: Học sinh xem chi tiết bài làm của mình (chỉ chủ bài mới xem được)
 *     tags: [Submissions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của submission
 *     responses:
 *       200:
 *         description: Lấy chi tiết thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 lesson:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                     title:
 *                       type: string
 *                     lessonType:
 *                       type: string
 *                 scores:
 *                   type: object
 *                   properties:
 *                     vocabulary:
 *                       type: number
 *                     grammar:
 *                       type: number
 *                     reading:
 *                       type: number
 *                     listening:
 *                       type: number
 *                     speaking:
 *                       type: number
 *                     writing:
 *                       type: number
 *                 totalScore:
 *                   type: number
 *                   example: 14
 *                 submittedAt:
 *                   type: string
 *                   format: date-time
 *       403:
 *         description: Không có quyền xem bài này
 *       404:
 *         description: Không tìm thấy bài làm
 *       500:
 *         description: Lỗi server
 */

/**
 * @swagger
 * /api/submissions/lesson/{lessonId}/scores:
 *   get:
 *     summary: Xem điểm của học sinh theo bài học
 *     description: Giảng viên xem danh sách điểm của tất cả học sinh đã làm bài học cụ thể
 *     tags: [Submissions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: lessonId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của bài học
 *     responses:
 *       200:
 *         description: Lấy danh sách điểm thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 totalStudents:
 *                   type: number
 *                   example: 25
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       submissionId:
 *                         type: string
 *                         example: "507f1f77bcf86cd799439013"
 *                       student:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: string
 *                           username:
 *                             type: string
 *                           email:
 *                             type: string
 *                       scores:
 *                         type: object
 *                         properties:
 *                           vocabulary:
 *                             type: number
 *                           grammar:
 *                             type: number
 *                           reading:
 *                             type: number
 *                           listening:
 *                             type: number
 *                           speaking:
 *                             type: number
 *                           writing:
 *                             type: number
 *                       totalScore:
 *                         type: number
 *                         example: 14
 *                       submittedAt:
 *                         type: string
 *                         format: date-time
 *       401:
 *         description: Chưa xác thực
 *       403:
 *         description: Chỉ giảng viên được phép
 *       500:
 *         description: Lỗi server
 */

/**
 * @swagger
 * /api/submissions/teacher/{id}:
 *   get:
 *     summary: Xem chi tiết bài làm của học sinh (dành cho giảng viên)
 *     description: Giảng viên xem chi tiết bài làm của học sinh bao gồm tất cả câu trả lời (để chấm essay)
 *     tags: [Submissions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của submission
 *     responses:
 *       200:
 *         description: Lấy chi tiết thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 student:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                     username:
 *                       type: string
 *                     email:
 *                       type: string
 *                 lesson:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                     title:
 *                       type: string
 *                     lessonType:
 *                       type: string
 *                 scores:
 *                   type: object
 *                   properties:
 *                     vocabulary:
 *                       type: number
 *                     grammar:
 *                       type: number
 *                     reading:
 *                       type: number
 *                     listening:
 *                       type: number
 *                     speaking:
 *                       type: number
 *                     writing:
 *                       type: number
 *                 totalScore:
 *                   type: number
 *                   example: 14
 *                 answers:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       question:
 *                         type: string
 *                         description: Nội dung câu hỏi
 *                       type:
 *                         type: string
 *                         description: Loại câu hỏi (mcq, true_false, fill_blank, matching, essay)
 *                       skill:
 *                         type: string
 *                         description: Kỹ năng (vocabulary, grammar, reading, listening, speaking, writing)
 *                       userAnswer:
 *                         description: Câu trả lời của học sinh
 *                       isCorrect:
 *                         type: boolean
 *                         nullable: true
 *                         description: null nếu là essay
 *                 submittedAt:
 *                   type: string
 *                   format: date-time
 *       404:
 *         description: Không tìm thấy bài làm
 *       401:
 *         description: Chưa xác thực
 *       403:
 *         description: Chỉ giảng viên được phép
 *       500:
 *         description: Lỗi server
 */
