/**
 * @swagger
 * tags:
 *   name: Teachers
 *   description: Quản lý giảng viên (School)
 */

/**
 * @swagger
 * /api/teachers:
 *   post:
 *     summary: Tạo giảng viên mới
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [username, email, password]
 *             properties:
 *               username:
 *                 type: string
 *                 example: teacher01
 *               email:
 *                 type: string
 *                 example: teacher01@gmail.com
 *               password:
 *                 type: string
 *                 example: 123456
 *               fullName:
 *                 type: string
 *                 example: Nguyen Van A
 *               phone:
 *                 type: string
 *                 example: "0901234567"
 *               gender:
 *                 type: string
 *                 enum: [male, female, ""]
 *                 example: male
 *               dateOfBirth:
 *                 type: string
 *                 format: date
 *                 example: 1980-01-01
 *     responses:
 *       201:
 *         description: Tạo giảng viên thành công
 *       400:
 *         description: Thiếu thông tin hoặc Email/Username đã tồn tại
 */

/**
 * @swagger
 * /api/teachers:
 *   get:
 *     summary: Lấy danh sách giảng viên
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách giảng viên
 */

/**
 * @swagger
 * /api/teachers/{id}:
 *   put:
 *     summary: Cập nhật giảng viên
 *     tags: [Teachers]
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
 *         description: Cập nhật thành công
 */

/**
 * @swagger
 * /api/teachers/{id}:
 *   delete:
 *     summary: Xóa giảng viên
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     responses:
 *       200:
 *         description: Xóa giảng viên thành công
 */

/**
 * @swagger
 * /api/teachers/my-class/students:
 *   get:
 *     summary: Lấy học sinh lớp chủ nhiệm
 *     tags: [Teachers]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Thành công
 */
