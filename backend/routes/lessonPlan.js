import express from "express";
import {
    createLessonPlan,
    getLessonPlans,
    updateLessonPlan,
    deleteLessonPlan,
} from "../controller/lessonPlanController.js";
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

// Apply auth middleware to all routes if needed, or specific ones
// router.use(authenticate);

router.post("/", createLessonPlan);
router.get("/", getLessonPlans);
router.put("/:id", updateLessonPlan);
router.delete("/:id", deleteLessonPlan);

export default router;
