/**
 * @swagger
 * tags:
 *   name: Vocabulary
 *   description: Quản lý từ vựng theo lesson (School CRUD, Teacher / Student xem)
 */

/**
 * @swagger
 * /api/vocabularies:
 *   post:
 *     summary: Nhà trường tạo từ vựng mới (Nhà trường)
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
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               audios:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               videos:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Tạo từ vựng thành công
 *       400:
 *         description: Dữ liệu không hợp lệ
 */

/**
 * @swagger
 * /api/vocabularies/{id}:
 *   patch:
 *     summary: Nhà trường cập nhật từ vựng (Nhà trường)
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
 *         description: Cập nhật từ vựng thành công
 *       404:
 *         description: Không tìm thấy từ vựng
 */

/**
 * @swagger
 * /api/vocabularies/{id}:
 *   delete:
 *     summary: Nhà trường xóa từ vựng (Nhà trường)
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

/**
 * @swagger
 * /api/vocabularies/lesson/{lessonId}:
 *   get:
 *     summary: Giáo viên & học sinh xem danh sách từ vựng theo lesson (Giảng viên, Học sinh)
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
