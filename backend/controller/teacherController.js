import User from "../models/User.js";

/* SCHOOL: CREATE TEACHER */
import bcrypt from "bcryptjs";

export const createTeacher = async (req, res) => {
  try {
    console.log("Create Teacher Body:", req.body);
    const { username, email, password, fullName, phone, classes } = req.body;

    const hashedPassword = await bcrypt.hash(password, 10);

    const teacher = await User.create({
      username,
      email,
      password: hashedPassword,
      fullName: fullName || "",
      phone: phone || "",
      classes: classes || [],
      role: "teacher",
    });

    res.status(201).json({
      message: "Tạo giảng viên thành công",
      teacher,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* SCHOOL: GET ALL TEACHERS */
export const getTeachers = async (req, res) => {
  try {
    const teachers = await User.find({ role: "teacher" }).select("-password");
    res.json(teachers);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* SCHOOL: UPDATE TEACHER */
export const updateTeacher = async (req, res) => {
  try {
    const teacher = await User.findOneAndUpdate(
      { _id: req.params.id, role: "teacher" },
      req.body,
      { new: true }
    ).select("-password");

    if (!teacher)
      return res.status(404).json({ message: "Không tìm thấy giảng viên" });

    res.json(teacher);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* SCHOOL: DELETE TEACHER */
export const deleteTeacher = async (req, res) => {
  try {
    const teacher = await User.findOneAndDelete({
      _id: req.params.id,
      role: "teacher",
    });

    if (!teacher)
      return res.status(404).json({ message: "Không tìm thấy giảng viên" });

    res.json({ message: "Xóa giảng viên thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
