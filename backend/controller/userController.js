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

    if (!username || !email || !password) {
      return res.status(400).json({ message: "Thiếu username, email hoặc password" });
    }

    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ message: "Email đã tồn tại" });
    }

    let normalizedGender = "";
    if (gender) {
      const g = gender.toString().toLowerCase().trim();
      if (g === "nam" || g === "male") normalizedGender = "male";
      else if (g === "nữ" || g === "nu" || g === "female") normalizedGender = "female";
    }

    let classData = null;
    if (classId) {
      classData = await Class.findOne({ _id: classId, school: req.user.id });
      if (!classData) {
        return res.status(400).json({ message: "Lớp không hợp lệ" });
      }
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const student = await User.create({
      username: username.trim(),
      email: email.toLowerCase().trim(),
      password: hashedPassword,
      role: "student",
      fullName: fullName ? fullName.trim() : "",
      phone: phone ? phone.trim() : "",
      gender: normalizedGender,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,
      class: classData ? classData._id : null,
    });

    if (classData) {
      await Class.findByIdAndUpdate(classData._id, { $addToSet: { students: student._id } });
    }

    student.password = undefined;
    res.status(201).json({ message: "Tạo học sinh thành công", student });
  } catch (err) {
    res.status(500).json({ message: "Lỗi server", error: err.message });
  }
};

/* ===========================
   UPDATE STUDENT
=========================== */
export const updateStudent = async (req, res) => {
  try {
    delete req.body.class;
    const student = await User.findOneAndUpdate(
      { _id: req.params.id, role: "student" },
      req.body,
      { new: true }
    ).select("-password").populate("class", "name grade");

    if (!student) return res.status(404).json({ message: "Không tìm thấy học sinh" });
    res.json({ message: "Cập nhật học sinh thành công", student });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   DISABLE / ENABLE USER
=========================== */
export const disableUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "Không tìm thấy user" });

    // Chặn khóa tài khoản School
    if (user.role === "school") {
      return res.status(403).json({ message: "Không thể khóa tài khoản quản trị hệ thống" });
    }

    user.isDisabled = true;
    await user.save();
    res.json({ message: "Khóa tài khoản thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const enableUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, { isDisabled: false }, { new: true });
    if (!user) return res.status(404).json({ message: "Không tìm thấy user" });
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
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "Không tìm thấy người dùng" });

    // Bảo vệ tài khoản School
    if (user.role === "school") {
      return res.status(403).json({ message: "Không thể xóa tài khoản quản trị hệ thống" });
    }

    if (user.role === "student" && user.class) {
      await Class.findByIdAndUpdate(user.class, { $pull: { students: user._id } });
    }
    
    await user.deleteOne();
    res.json({ message: "Xóa người dùng thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   TEACHER: GET ACTIVE STUDENTS
=========================== */
export const getAssignableStudents = async (req, res) => {
  try {
    const students = await User.find({ role: "student", isDisabled: false })
      .select("_id username email")
      .populate("class", "name");
    res.json(students);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   GET PROFILE
=========================== */
export const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .select("-password")
      .populate("class", "name");
    if (!user) return res.status(404).json({ message: "Người dùng không tồn tại" });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ===========================
   UPDATE PROFILE
=========================== */
export const updateProfile = async (req, res) => {
  try {
    const { fullName, academicYear } = req.body;
    const user = await User.findById(req.user.id).select("-password");
    if (!user) return res.status(404).json({ message: "Người dùng không tồn tại" });
    if (fullName !== undefined) user.fullName = fullName;
    if (academicYear !== undefined) user.academicYear = academicYear;
    await user.save();
    res.json({ message: "Cập nhật thông tin thành công", user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* TEACHER: GET STUDENTS BY CLASS */
export const getStudentsByClassForTeacher = async (req, res) => {
  try {
    const { classId } = req.params;
    const classData = await Class.findOne({ homeroomTeacher: req.user._id, _id: classId, isActive: true });
    if (!classData) return res.status(403).json({ message: "Không có quyền xem học sinh lớp này" });

    const students = await User.find({ class: classId, role: "student" }).select("-password");
    res.json(students);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* TEACHER: GET ALL MY STUDENTS */
export const getMyStudents = async (req, res) => {
  try {
    const classes = await Class.find({ homeroomTeacher: req.user._id, isActive: true });
    if (classes.length === 0) return res.json([]);

    const classIds = classes.map(c => c._id);
    const students = await User.find({ class: { $in: classIds }, role: "student" })
      .select("-password").populate("class", "name grade");
    res.json(students);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
