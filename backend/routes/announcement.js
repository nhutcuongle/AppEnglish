import express from "express";
import {
    createAnnouncement,
    getAnnouncements,
    updateAnnouncement,
    deleteAnnouncement,
} from "../controller/announcementController.js";
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Announcements
 *   description: Quản lý thông báo
 */

router.post("/", authenticate, createAnnouncement);
router.get("/", authenticate, getAnnouncements);
router.put("/:id", authenticate, updateAnnouncement);
router.delete("/:id", authenticate, deleteAnnouncement);

export default router;
