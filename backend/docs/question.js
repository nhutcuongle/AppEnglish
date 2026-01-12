/**
 * @swagger
 * tags:
 *   name: Questions
 *   description: Bài tập / câu hỏi cho tất cả kỹ năng (Teacher CRUD theo lớp chủ nhiệm, Student xem theo lớp học)
 */

/* ================= TEACHER ================= */

/**
 * @swagger
 * /api/questions:
 *   post:
 *     summary: Giáo viên tạo question mới (Tự động gán vào lớp chủ nhiệm)
 *     description: >
 *       Chỉ giáo viên chủ nhiệm mới được tạo câu hỏi.
 *       Câu hỏi sẽ tự động được gán ID của lớp mà giáo viên đó đang chủ nhiệm.
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
 *       403:
 *         description: Không phải giáo viên chủ nhiệm nên không được tạo
 */

/**
 * @swagger
 * /api/questions/{id}:
 *   patch:
 *     summary: Giáo viên cập nhật question (Chỉ GVCN của lớp đó)
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
 *         description: Không tìm thấy question hoặc không thuộc lớp của GVCN
 */

/**
 * @swagger
 * /api/questions/{id}:
 *   delete:
 *     summary: Giáo viên xóa question (Chỉ GVCN của lớp đó)
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
 *         description: Không tìm thấy question hoặc không thuộc lớp của GVCN
 */

/* ================= STUDENT / TEACHER ================= */

/**
 * @swagger
 * /api/questions/lesson/{lessonId}:
 *   get:
 *     summary: Xem danh sách question theo lesson (Tự động lọc theo lớp)
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
 *         description: Danh sách question
 *       403:
 *         description: Học sinh chưa được xếp lớp hoặc giáo viên chưa có lớp chủ nhiệm
 */
