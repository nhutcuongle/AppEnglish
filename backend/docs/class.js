/**
 * @swagger
 * tags:
 *   name: Classes
 *   description: Quản lý lớp học (School)
 */

/* =====================================================
   CREATE CLASS
===================================================== */

/**
 * @swagger
 * /api/classes:
 *   post:
 *     summary: Tạo lớp học mới (Nhà trường)
 *     description: |
 *       School tạo lớp học.
 *       - Không được trùng **tên + khối** trong cùng school
 *       - Giáo viên chủ nhiệm sẽ được gán sau qua endpoint `/assign-teacher`
 *     tags: [Classes]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - grade
 *             properties:
 *               name:
 *                 type: string
 *                 description: Tên lớp học
 *                 example: "10A1"
 *               grade:
 *                 type: number
 *                 description: Khối (10, 11, 12...)
 *                 example: 10
 *     responses:
 *       201:
 *         description: Tạo lớp học thành công
 *       400:
 *         description: Lớp đã tồn tại hoặc thiếu dữ liệu
 *       401:
 *         description: Không có quyền truy cập
 */

/* =====================================================
   GET ALL CLASSES
===================================================== */

/**
 * @swagger
 * /api/classes:
 *   get:
 *     summary: Lấy danh sách lớp học (Nhà trường)
 *     tags: [Classes]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách lớp học
 *       401:
 *         description: Không có quyền truy cập
 */

/* =====================================================
   GET CLASS DETAIL
===================================================== */

/**
 * @swagger
 * /api/classes/{id}:
 *   get:
 *     summary: Lấy chi tiết lớp học (kèm học sinh) (Nhà trường)
 *     tags: [Classes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *           example: "64b9f3d8c2a1e9a123456789"
 *     responses:
 *       200:
 *         description: Chi tiết lớp học
 *       404:
 *         description: Không tìm thấy lớp
 */

/* =====================================================
   UPDATE CLASS
===================================================== */

/**
 * @swagger
 * /api/classes/{id}:
 *   put:
 *     summary: Cập nhật lớp học (Nhà trường)
 *     description: |
 *       - Không được trùng **tên + khối**
 *       - Có thể đổi giáo viên chủ nhiệm
 *     tags: [Classes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: "10A2"
 *               grade:
 *                 type: number
 *                 example: 10
 *               homeroomTeacher:
 *                 type: string
 *                 nullable: true
 *     responses:
 *       200:
 *         description: Cập nhật lớp thành công
 *       400:
 *         description: Lớp đã tồn tại
 *       404:
 *         description: Không tìm thấy lớp
 */

/* =====================================================
   DELETE CLASS
===================================================== */

/**
 * @swagger
 * /api/classes/{id}:
 *   delete:
 *     summary: Xóa lớp học (Nhà trường)
 *     description: |
 *       - Không xóa học sinh
 *       - Học sinh thuộc lớp sẽ được gán `class = null`
 *     tags: [Classes]
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
 *         description: Xóa lớp thành công
 *       404:
 *         description: Không tìm thấy lớp
 */

/* =====================================================
   ASSIGN / CHANGE TEACHER
===================================================== */

/**
 * @swagger
 * /api/classes/assign-teacher:
 *   post:
 *     summary: Gán hoặc đổi giáo viên chủ nhiệm cho lớp (Nhà trường)
 *     tags: [Classes]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - classId
 *               - teacherId
 *             properties:
 *               classId:
 *                 type: string
 *               teacherId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Gán giáo viên thành công
 *       404:
 *         description: Không tìm thấy lớp
 */
