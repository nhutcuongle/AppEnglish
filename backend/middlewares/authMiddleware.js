import jwt from "jsonwebtoken";
import User from "../models/User.js";

/* ================= AUTH ================= */
export const authenticate = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader)
    return res.status(401).json({ message: "Thiếu token" });

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findById(decoded.id).select(
      "_id role isDisabled class"
    );

    if (!user)
      return res.status(401).json({ message: "User không tồn tại" });

    if (user.isDisabled)
      return res.status(403).json({ message: "Tài khoản đã bị khóa" });

    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ message: "Token không hợp lệ" });
  }
};

/* ================= ROLE CHECK ================= */
export const isAdmin = (req, res, next) => {
  if (req.user.role !== "admin")
    return res.status(403).json({ message: "Chỉ admin được phép" });
  next();
};

export const isSchool = (req, res, next) => {
  if (!["admin", "school"].includes(req.user.role))
    return res.status(403).json({ message: "Chỉ nhà trường được phép" });
  next();
};

export const isTeacher = (req, res, next) => {
  if (req.user.role !== "teacher")
    return res.status(403).json({ message: "Chỉ giảng viên được phép" });
  next();
};
export const isStudent = (req, res, next) => {
  if (req.user.role !== "student")
    return res.status(403).json({ message: "Chỉ học sinh được phép" });
  next();
};
