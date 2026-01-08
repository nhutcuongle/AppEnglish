import User from "../models/User.js";
import Class from "../models/Class.js";

/* SCHOOL: CREATE TEACHER */
import bcrypt from "bcryptjs";

export const createTeacher = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    const hashedPassword = await bcrypt.hash(password, 10);

    const teacher = await User.create({
      username,
      email,
      password: hashedPassword,
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

/* TEACHER: GET MY CLASS STUDENTS */
export const getMyClassStudents = async (req, res) => {
  try {
    const classData = await Class.findOne({
      homeroomTeacher: req.user.id,
    }).populate("students", "username email");

    if (!classData)
      return res.status(404).json({ message: "Bạn chưa được phân lớp" });

    res.json({
      class: classData.name,
      students: classData.students,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
