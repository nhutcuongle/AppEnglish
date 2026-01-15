import express from "express";
import { register, login, verifyOTP, forgotPassword, resetPassword, changePassword, toggle2FA } from "../controller/authController.js";
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.post("/verify-otp", verifyOTP);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.put("/change-password", authenticate, changePassword);
router.put("/toggle-2fa", authenticate, toggle2FA);

export default router;
