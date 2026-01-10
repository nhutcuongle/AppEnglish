

import User from "../models/User.js";
import Class from "../models/Class.js";
import bcrypt from "bcryptjs";

/* ===========================
   GET ALL STUDENTS (SCHOOL)
=========================== */
export const getAllStudents = async (req, res) => {
  try {
    const students = await User.find({ role: "student" })
      .select("-password")
      .populate("class", "name grade");

    res.json(students);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   CREATE STUDENT + ASSIGN CLASS
=========================== */
export const createStudent = async (req, res) => {
  try {
    console.log("Create Student Body:", req.body);
    const { username, password, fullName, phone, classes, gender, dateOfBirth } = req.body;

    const hashedPassword = await bcrypt.hash(password, 10);

    const student = await User.create({
      username,
      email: null, // Students don't need email
      password: hashedPassword,
      fullName: fullName || "",
      phone: phone || "",
      gender: gender || "",
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,
      classes: classes || [],
      role: "student",
    });

    res.status(201).json({
      message: "Tạo học sinh thành công",
      student,
    });
  } catch (err) {
    console.error("Create Student Error:", err.message);
    res.status(500).json({ error: err.message });
  }
};



/* ===========================
   UPDATE STUDENT (KHÔNG ĐỔI LỚP)
=========================== */
export const updateStudent = async (req, res) => {
  try {
    // Không cho update class ở đây
    delete req.body.class;

    const student = await User.findOneAndUpdate(
      { _id: req.params.id, role: "student" },
      req.body,
      { new: true }
    )
      .select("-password")
      .populate("class", "name grade");

    if (!student)
      return res.status(404).json({ message: "Không tìm thấy học sinh" });

    res.json({
      message: "Cập nhật học sinh thành công",
      student,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   DISABLE STUDENT
=========================== */
export const disableUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isDisabled: true },
      { new: true }
    );

    if (!user)
      return res.status(404).json({ message: "Không tìm thấy user" });

    res.json({ message: "Khóa tài khoản thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   ENABLE STUDENT
=========================== */
export const enableUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isDisabled: false },
      { new: true }
    );

    if (!user)
      return res.status(404).json({ message: "Không tìm thấy user" });

    res.json({ message: "Mở khóa tài khoản thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   DELETE STUDENT
=========================== */
export const deleteStudent = async (req, res) => {
  try {
    const student = await User.findOne({
      _id: req.params.id,
      role: "student",
    });

    if (!student)
      return res.status(404).json({ message: "Không tìm thấy học sinh" });

    // Gỡ khỏi lớp
    if (student.class) {
      await Class.findByIdAndUpdate(student.class, {
        $pull: { students: student._id },
      });
    }

    await student.deleteOne();

    res.json({ message: "Xóa học sinh thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   TEACHER: GET ACTIVE STUDENTS
=========================== */
export const getAssignableStudents = async (req, res) => {
  try {
    const students = await User.find({
      role: "student",
      isDisabled: false,
    })
      .select("_id username email")
      .populate("class", "name");

    res.json(students);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
