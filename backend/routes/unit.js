import express from "express";
import {
  createUnit,
  getAllUnitsForSchool,
  getAllUnitsForTeacher,
  getPublishedUnits,
  getUnitById,
  updateUnit,
  deleteUnit,
} from "../controller/unitController.js";

import {
  authenticate,
  isSchool,
  isTeacher,
} from "../middlewares/authMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Units
 *   description: Quản lý Unit (School / Teacher / Student)
 */

/* ================= SCHOOL / ADMIN ================= */

/**
 * @swagger
 * /api/units:
 *   get:
 *     summary: Nhà trường lấy danh sách tất cả unit
 *     tags: [Units]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách unit
 */
router.get(
  "/",
  authenticate,
  isSchool,
  getAllUnitsForSchool
);

/**
 * @swagger
 * /api/units:
 *   post:
 *     summary: Nhà trường tạo unit mới
 *     tags: [Units]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title]
 *     responses:
 *       201:
 *         description: Tạo unit thành công
 */
router.post(
  "/",
  authenticate,
  isSchool,
  createUnit
);

/**
 * @swagger
 * /api/units/{id}:
 *   get:
 *     summary: Nhà trường xem chi tiết unit
 *     tags: [Units]
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
 *         description: Chi tiết unit
 */
router.get(
  "/:id",
  authenticate,
  isSchool,
  getUnitById
);

/**
 * @swagger
 * /api/units/{id}:
 *   put:
 *     summary: Nhà trường cập nhật unit
 *     tags: [Units]
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
 *         description: Cập nhật unit thành công
 */
router.put(
  "/:id",
  authenticate,
  isSchool,
  updateUnit
);

/**
 * @swagger
 * /api/units/{id}:
 *   delete:
 *     summary: Nhà trường xóa unit
 *     tags: [Units]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *     responses:
 *       200:
 *         description: Xóa unit thành công
 */
router.delete(
  "/:id",
  authenticate,
  isSchool,
  deleteUnit
);

/* ================= TEACHER ================= */

/**
 * @swagger
 * /api/units/teacher/all:
 *   get:
 *     summary: Giảng viên xem danh sách unit
 *     tags: [Units]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách unit
 */
router.get(
  "/teacher/all",
  authenticate,
  isTeacher,
  getAllUnitsForTeacher
);

/**
 * @swagger
 * /api/units/teacher/{id}:
 *   get:
 *     summary: Giảng viên xem chi tiết unit
 *     tags: [Units]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *     responses:
 *       200:
 *         description: Chi tiết unit
 */
router.get(
  "/teacher/:id",
  authenticate,
  isTeacher,
  getUnitById
);

/* ================= STUDENT ================= */

/**
 * @swagger
 * /api/units/public:
 *   get:
 *     summary: Học sinh xem danh sách unit đã publish
 *     tags: [Units]
 *     responses:
 *       200:
 *         description: Danh sách unit đã publish
 */
router.get(
  "/public",
  getPublishedUnits
);

/**
 * @swagger
 * /api/units/public/{id}:
 *   get:
 *     summary: Học sinh xem chi tiết unit đã publish
 *     tags: [Units]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *     responses:
 *       200:
 *         description: Chi tiết unit
 */
router.get(
  "/public/:id",
  getUnitById
);

export default router;
