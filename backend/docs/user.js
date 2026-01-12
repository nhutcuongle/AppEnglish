/**
 * @swagger
 * tags:
 *   name: Students
 *   description: Quản lý học sinh (School / Teacher)
 */

/* =====================================================
   SCHOOL
===================================================== */

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
 *                 example: "Nguyễn Văn A"
 *               email:
 *                 type: string
 *                 example: "a@gmail.com"
 *               password:
 *                 type: string
 *                 example: "123456"
 *               fullName:
 *                 type: string
 *                 example: "Nguyễn Văn A"
 *               phone:
 *                 type: string
 *                 example: "0901234567"
 *               gender:
 *                 type: string
 *                 enum: ["Nam", "Nữ", "Khác"]
 *                 example: "Nam"
 *               dateOfBirth:
 *                 type: string
 *                 format: date
 *                 example: "2005-01-01"
 *               classId:
 *                 type: string
 *                 nullable: true
 *                 example: "64b9f3d8c2a1e9a987654321"
 *     responses:
 *       201:
 *         description: Tạo học sinh thành công
 *       400:
 *         description: Lớp không hợp lệ
 *       401:
 *         description: Chưa đăng nhập
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
 *       401:
 *         description: Chưa đăng nhập
 */

/**
 * @swagger
 * /api/users/students/{id}:
 *   put:
 *     summary: Cập nhật thông tin học sinh (không đổi lớp) (Nhà trường)
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *           example: "64b9f3d8c2a1e9a123456789"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *               email:
 *                 type: string
 *               fullName:
 *                 type: string
 *               phone:
 *                 type: string
 *               gender:
 *                 type: string
 *                 enum: ["Nam", "Nữ", "Khác"]
 *               dateOfBirth:
 *                 type: string
 *                 format: date
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

/* =====================================================
   TEACHER
===================================================== */
