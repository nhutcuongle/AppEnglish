/**
 * @swagger
 * tags:
 *   name: Students
 *   description: Quản lý học sinh
 */

/**
 * @swagger
 * /api/users/students:
 *   post:
 *     summary: Tạo học sinh mới (Nhà trường)
 *     tags: [Students]
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
 *               username: {type: string}
 *               email: {type: string}
 *               password: {type: string}
 *               fullName: {type: string}
 *               phone: {type: string}
 *               gender: {type: string}
 *               dateOfBirth: {type: string, format: date}
 *               classId: {type: string}
 *     responses:
 *       201: {description: Thành công}
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
 *       200: {description: Thành công}
 */

/**
 * @swagger
 * /api/users/teacher/class-students/{classId}:
 *   get:
 *     summary: Lấy danh sách học sinh của lớp mình chủ nhiệm (Giảng viên)
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: classId
 *         in: path
 *         required: true
 *         schema: {type: string}
 *     responses:
 *       200: {description: Thành công}
 */

/**
 * @swagger
 * /api/users/teacher/my-students:
 *   get:
 *     summary: Lấy toàn bộ học sinh do tôi chủ nhiệm (Giảng viên)
 *     tags: [Students]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: {description: Thành công}
 */
