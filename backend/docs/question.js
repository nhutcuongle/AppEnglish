/**
 * @swagger
 * tags:
 *   name: Questions
 *   description: Bài tập / câu hỏi cho tất cả kỹ năng (Nhà trường CRUD, Học sinh & Giảng viên xem)
 */

/* ================= TEACHER ================= */

/**
 * @swagger
 * /api/questions:
 *   post:
 *     summary: Tạo question mới (Tạo đơn lẻ kèm media hoặc tạo hàng loạt) (Nhà trường / Giảng viên)
 *     description: >
 *       Hệ thống phân tách rõ rệt quyền tạo câu hỏi theo vai trò của người dùng:
 *
 *       1. **NHÀ TRƯỜNG (SCHOOL)**: Chỉ tạo nội dung cho Bài học (`lessonId`).
 *       2. **GIẢNG VIÊN (TEACHER)**: Chỉ tạo nội dung cho Bài kiểm tra (`examId`).
 *
 *       Xem chi tiết quy tắc của từng trường (lessonId, examId, classId) ở phần `properties` bên dưới.
 *
 *       - Dùng `multipart/form-data`: Tạo 1 câu hỏi + Upload Media.
 *       - Dùng `application/json`: Bulk Create (Tạo hàng loạt mảng JSON).
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
 *               - skill
 *               - type
 *               - content
 *             properties:
 *               lessonId:
 *                 type: string
 *                 description: |
 *                   - **Nhà trường**: BẮT BUỘC. Dùng để gắn câu hỏi vào bài học.
 *                   - **Giảng viên**: KHÔNG ĐƯỢC DÙNG (Sẽ bị server bỏ qua).
 *                 example: "507f1f77bcf86cd799439011"
 *               examId:
 *                 type: string
 *                 description: |
 *                   - **Nhà trường**: KHÔNG DÙNG.
 *                   - **Giảng viên**: BẮT BUỘC. Dùng để gắn câu hỏi vào bài kiểm tra 15p/45p.
 *                 example: "507f1f77bcf86cd799439099"
 *               classId:
 *                 type: string
 *                 description: |
 *                   - **Nhà trường**: TÙY CHỌN. Điền ID lớp để tạo cho 1 lớp, BỎ TRỐNG để tạo dùng chung toàn trường.
 *                   - **Giảng viên**: BẮT BUỘC. Phải là ID lớp mà bạn đang chủ nhiệm.
 *                 example: "507f1f77bcf86cd799439015"
 *               skill:
 *                 type: string
 *                 enum: [vocabulary, grammar, reading, listening, speaking, writing]
 *                 example: vocabulary
 *               type:
 *                 type: string
 *                 enum: [mcq, true_false, fill_blank, matching, essay]
 *                 example: mcq
 *               content:
 *                 type: string
 *                 description: Nội dung câu hỏi (HTML / Rich Text)
 *                 example: "Chọn từ đồng nghĩa với 'Happy':"
 *               points:
 *                 type: number
 *                 example: 1
 *                 description: Số điểm cho câu hỏi này
 *               options:
 *                 type: array
 *                 description: Danh sách lựa chọn (cho mcq, matching)
 *                 items:
 *                   type: string
 *                 example: ["Joyful", "Sad", "Angry", "Bored"]
 *               correctAnswer:
 *                 type: string
 *                 description: Đáp án đúng (String cho MCQ, JSON String cho Matching/FillBlank)
 *                 example: "Joyful"
 *               explanation:
 *                 type: string
 *                 example: "Joyful là từ đồng nghĩa phổ biến nhất của Happy."
 *               order:
 *                 type: number
 *                 example: 1
 *               isPublished:
 *                 type: boolean
 *                 example: true
 *               deadline:
 *                 type: string
 *                 format: date-time
 *                 example: "2026-01-30T23:59:59+07:00"
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
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               lessonId:
 *                 type: string
 *                 description: |
 *                    - **Nhà trường**: BẮT BUỘC để import hàng loạt vào Bài học.
 *                    - **Giảng viên**: Bỏ trống.
 *                 example: "507f1f77bcf86cd799439011"
 *               examId:
 *                 type: string
 *                 description: |
 *                    - **Nhà trường**: Bỏ trống.
 *                    - **Giảng viên**: BẮT BUỘC để tạo đề kiểm tra hàng loạt.
 *                 example: "507f1f77bcf86cd799439099"
 *               classId:
 *                 type: string
 *                 description: |
 *                    - **Nhà trường**: Tùy chọn (để trống nếu tạo toàn trường).
 *                    - **Giảng viên**: Bắt buộc (phải là lớp mình chủ nhiệm).
 *                 example: "507f1f77bcf86cd799439015"
 *               deadline:
 *                 type: string
 *                 format: date-time
 *                 example: "2026-01-30T23:59:59+07:00"
 *               questions:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required: [skill, type, content]
 *                   properties:
 *                     skill:
 *                       type: string
 *                       enum: [vocabulary, grammar, reading, listening, speaking, writing]
 *                     type:
 *                       type: string
 *                       enum: [mcq, true_false, fill_blank, matching, essay]
 *                     content:
 *                       type: string
 *                     points:
 *                       type: number
 *                       example: 1
 *                     options:
 *                       type: array
 *                       items:
 *                         type: string
 *                     correctAnswer:
 *                       type: string
 *                     explanation:
 *                       type: string
 *                     isPublished:
 *                       type: boolean
 *                     examId:
 *                       type: string
 *                       description: Gắn trực tiếp examId vào từng câu (nếu cần)
 *                     images:
 *                       type: array
 *                       description: Mảng hình ảnh (URL từ Cloudinary hoặc nguồn khác)
 *                       items:
 *                         type: object
 *                         properties:
 *                           url:
 *                             type: string
 *                             example: "https://res.cloudinary.com/.../image.jpg"
 *                           caption:
 *                             type: string
 *                             example: "Question image"
 *                           order:
 *                             type: number
 *                             example: 1
 *                     audios:
 *                       type: array
 *                       description: Mảng audio (URL từ Cloudinary hoặc nguồn khác)
 *                       items:
 *                         type: object
 *                         properties:
 *                           url:
 *                             type: string
 *                             example: "https://res.cloudinary.com/.../audio.mp3"
 *                           caption:
 *                             type: string
 *                             example: "Listening audio"
 *                           order:
 *                             type: number
 *                             example: 1
 *                     videos:
 *                       type: array
 *                       description: Mảng video (URL từ Cloudinary hoặc nguồn khác)
 *                       items:
 *                         type: object
 *                         properties:
 *                           url:
 *                             type: string
 *                             example: "https://res.cloudinary.com/.../video.mp4"
 *                           caption:
 *                             type: string
 *                             example: "Video description"
 *                           order:
 *                             type: number
 *                             example: 1
 *     responses:
 *       201:
 *         description: Tạo thành công
 *       400:
 *         description: Dữ liệu không hợp lệ
 *       403:
 *         description: Không có quyền truy cập (Chỉ Nhà trường được phép)
 */

/**
 * @swagger
 * /api/questions/{id}:
 *   patch:
 *     summary: Cập nhật question (Nhà trường)
 *     description: Chỉ có thể cập nhật câu hỏi thuộc trường mình quản lý.
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
 *               deadline:
 *                 type: string
 *                 format: date-time
 *                 example: "2026-01-30T23:59:59+07:00"
 *               points:
 *                 type: number
 *                 example: 2
 *     responses:
 *       200:
 *         description: Cập nhật question thành công
 *       404:
 *         description: Không tìm thấy question
 *       403:
 *         description: Không thuộc quản lý của trường bạn
 */

/**
 * @swagger
 * /api/questions/{id}:
 *   delete:
 *     summary: Xóa question (Nhà trường)
 *     description: Chỉ có thể xóa câu hỏi thuộc trường mình quản lý.
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
 *       403:
 *         description: Không thuộc quản lý của trường bạn
 */

/* ================= STUDENT / TEACHER ================= */

/**
 * @swagger
 * /api/questions/lesson/{lessonId}:
 *   get:
 *     summary: Xem danh sách question theo bài học (Giảng viên, Học sinh)
 *     description: >
 *       - Giáo viên: Chỉ thấy question của lớp mình chủ nhiệm.
 *       - Học sinh: Chỉ thấy question của lớp mình đang theo học.
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
 *         description: Danh sách question kèm thông tin assignment (hạn nộp)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total:
 *                   type: number
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       _id:
 *                         type: string
 *                       content:
 *                         type: string
 *                       points:
 *                         type: number
 *                       skill:
 *                         type: string
 *                       type:
 *                         type: string
 *                       options:
 *                         type: array
 *                         items:
 *                           type: string
 *                       isPublished:
 *                         type: boolean
 *                       order:
 *                         type: number
 *                 deadline:
 *                   type: string
 *                   format: date-time
 *                   description: Hạn nộp bài từ Lesson model (null nếu không có)
 *                   nullable: true
 *       403:
 *         description: Học sinh chưa được xếp lớp hoặc giáo viên chưa có lớp chủ nhiệm
 */
