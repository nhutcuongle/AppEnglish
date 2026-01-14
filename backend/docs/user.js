/**
 * @swagger
 * tags:
 *   name: Students
 *   description: Quản lý học sinh (School / Teacher)
 */

/**
 * @swagger
 * /api/users/students:
 *   post:
 *     summary: Tạo học sinh mới (có thể gán lớp) (Nhà trường)
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - email
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               fullName:
 *                 type: string
 *               phone:
 *                 type: string
 *               gender:
 *                 type: string
 *               dateOfBirth:
 *                 type: string
 *                 format: date
 *               classId:
 *                 type: string
 *                 nullable: true
 *     responses:
 *       201:
 *         description: Tạo học sinh thành công
 *       400:
 *         description: Lớp không hợp lệ
 */

/**
 * @swagger
 * /api/users/students:
 *   get:
 *     summary: Lấy danh sách học sinh (Nhà trường)
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách học sinh
 */

/**
 * @swagger
 * /api/users/students/{id}:
 *   put:
 *     summary: Cập nhật thông tin học sinh (Nhà trường)
 *     tags: [Students]
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
 *         description: Cập nhật thành công
 *       404:
 *         description: Không tìm thấy học sinh
 */

/**
 * @swagger
 * /api/users/students/{id}:
 *   delete:
 *     summary: Xóa học sinh (Nhà trường)
 *     tags: [Students]
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
 *         description: Xóa học sinh thành công
 *       404:
 *         description: Không tìm thấy học sinh
 */

/**
 * @swagger
 * /api/users/students/{id}/disable:
 *   put:
 *     summary: Khóa tài khoản học sinh (Nhà trường)
 *     tags: [Students]
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
 *         description: Khóa tài khoản thành công
 */

/**
 * @swagger
 * /api/users/students/{id}/enable:
 *   put:
 *     summary: Mở khóa tài khoản học sinh (Nhà trường)
 *     tags: [Students]
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
 *         description: Mở khóa tài khoản thành công
 */

/**
 * @swagger
 * /api/users/teacher/class-students/{classId}:
 *   get:
 *     summary: Lấy danh sách học sinh của lớp mình chủ nhiệm (Giảng viên)
 *     description: Trả về danh sách đầy đủ học sinh của lớp do Giảng viên đang đăng nhập quản lý.
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: classId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Danh sách học sinh của lớp
 *       403:
 *         description: Không có quyền (Chỉ dành cho GVCN của lớp này)
 */
