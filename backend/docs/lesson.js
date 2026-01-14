/**
 * @swagger
 * tags:
 *   name: Lessons
 *   description: Quản lý bài học (School CRUD, Teacher / Student xem)
 */

/* ================= SCHOOL / ADMIN ================= */

/**
 * @swagger
 * /api/lessons:
 *   post:
 *     summary: Nhà trường tạo lesson mới (mỗi lesson = 1 skill) (Nhà trường)
 *     tags: [Lessons]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - unit
 *               - lessonType
 *               - title
 *             properties:
 *               unit:
 *                 type: string
 *                 example: 695f79f2927eb2fb1a5d9ed3
 *
 *               lessonType:
 *                 type: string
 *                 description: Loại bài học / kỹ năng
 *                 enum:
 *                   - vocabulary
 *                   - grammar
 *                   - reading
 *                   - listening
 *                   - speaking
 *                   - writing
 *                 example: listening
 *
 *               title:
 *                 type: string
 *                 example: Listening – Family Life
 *
 *               content:
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
 *
 *               youtubeVideos:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: List of YouTube URLs (e.g. https://www.youtube.com/watch?v=...)
 *
 *               youtubeVideoCaptions:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Captions for YouTube videos
 *     responses:
 *       201:
 *         description: Tạo lesson thành công
 *       400:
 *         description: Thiếu hoặc sai lessonType
 */

/**
 * @swagger
 * /api/lessons/{id}:
 *   patch:
 *     summary: Nhà trường cập nhật lesson (không đổi lessonType) (Nhà trường)
 *     tags: [Lessons]
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
 *               title:
 *                 type: string
 *               content:
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
 *                     type:
 *                       type: string
 *                       enum: [upload, youtube]
 *                     youtubeId:
 *                       type: string
 *     responses:
 *       200:
 *         description: Cập nhật lesson thành công
 *       404:
 *         description: Không tìm thấy lesson
 */

/**
 * @swagger
 * /api/lessons/{id}:
 *   delete:
 *     summary: Nhà trường xóa lesson (Nhà trường)
 *     tags: [Lessons]
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
 *         description: Xóa lesson thành công
 *       404:
 *         description: Không tìm thấy lesson
 */

/* ================= TEACHER / STUDENT ================= */

/**
 * @swagger
 * /api/lessons/unit/{unitId}:
 *   get:
 *     summary: Giáo viên & học sinh xem danh sách lesson theo unit (Giảng viên, Học sinh)
 *     tags: [Lessons]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: unitId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Danh sách lesson
 */
