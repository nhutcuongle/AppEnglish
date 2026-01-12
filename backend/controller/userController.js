

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
    const {
      username,
      email,
      password,
      fullName,
      phone,
      gender,
      dateOfBirth,
      classId,
    } = req.body;

    // ===== 1. Validate bắt buộc =====
    if (!username || !email || !password) {
      return res.status(400).json({
        message: "Thiếu username, email hoặc password",
      });
    }

    // ===== 2. Check email trùng =====
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({
        message: "Email đã tồn tại",
      });
    }

    // ===== 3. Chuẩn hóa gender =====
    let normalizedGender = "";
    if (gender) {
      const g = gender.toString().toLowerCase().trim();
      if (g === "nam" || g === "male") normalizedGender = "male";
      else if (g === "nữ" || g === "nu" || g === "female")
        normalizedGender = "female";
    }

    // ===== 4. Validate class (nếu có) =====
    let classData = null;
    if (classId) {
      classData = await Class.findOne({
        _id: classId,
        school: req.user.id, // school đang đăng nhập
      });

      if (!classData) {
        return res.status(400).json({
          message: "Lớp không hợp lệ",
        });
      }
    }

    // ===== 5. Hash password =====
    const hashedPassword = await bcrypt.hash(password, 10);

    // ===== 6. Create student =====
    const student = await User.create({
      username: username.trim(),
      email: email.toLowerCase().trim(),
      password: hashedPassword,
      role: "student",

      // Profile
      fullName: fullName ? fullName.trim() : "",
      phone: phone ? phone.trim() : "",
      gender: normalizedGender,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,

      // Class relation
      class: classData ? classData._id : null,
    });

    // ===== 7. Đồng bộ Class → students[] =====
    if (classData) {
      await Class.findByIdAndUpdate(classData._id, {
        $addToSet: { students: student._id },
      });
    }

    // ===== 8. Ẩn password khi trả về =====
    student.password = undefined;

    // ===== 9. Response =====
    res.status(201).json({
      message: "Tạo học sinh thành công",
      student,
    });
  } catch (err) {
    console.error(err);

    // Validation error → 400
    if (err.name === "ValidationError") {
      return res.status(400).json({
        message: err.message,
      });
    }

    res.status(500).json({
      message: "Lỗi server",
      error: err.message,
    });
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

/* ===========================
   GET PROFILE (SELF)
=========================== */
export const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    if (!user) return res.status(404).json({ message: "Người dùng không tồn tại" });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   UPDATE PROFILE (SELF)
=========================== */
export const updateProfile = async (req, res) => {
  try {
    const { fullName, academicYear } = req.body;
    const user = await User.findById(req.user.id).select("-password");

    if (!user) return res.status(404).json({ message: "Người dùng không tồn tại" });

    if (fullName !== undefined) user.fullName = fullName;
    if (academicYear !== undefined) user.academicYear = academicYear;

    await user.save();

    res.json({
      message: "Cập nhật thông tin thành công",
      user,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
