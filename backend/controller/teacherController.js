import User from "../models/User.js";
import Class from "../models/Class.js";

/* SCHOOL: CREATE TEACHER */
import bcrypt from "bcryptjs";

export const createTeacher = async (req, res) => {
  try {
    console.log("Create Teacher Body:", req.body);
    const {
      username,
      email,
      password,
      fullName,
      phone,
      gender,
      dateOfBirth,
    } = req.body;

    // 1. Validate bắt buộc
    if (!username || !email || !password) {
      return res.status(400).json({
        message: "Thiếu username, email hoặc password",
      });
    }

    // 2. Check trùng email / username
    const existingUser = await User.findOne({
      $or: [{ email: email.toLowerCase() }, { username: username }],
    });

    if (existingUser) {
      return res.status(400).json({
        message: "Email hoặc Username đã tồn tại",
      });
    }

    // 3. Chuẩn hóa gender
    let normalizedGender = "";
    if (gender) {
      const g = gender.toString().toLowerCase().trim();
      if (g === "nam" || g === "male") normalizedGender = "male";
      else if (g === "nữ" || g === "nu" || g === "female")
        normalizedGender = "female";
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const teacher = await User.create({
      username,
      email: email.toLowerCase(),
      password: hashedPassword,
      fullName: fullName || "",
      phone: phone || "",
      gender: normalizedGender,
      dateOfBirth: dateOfBirth || null,
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
    const { classes: newClasses, ...otherData } = req.body;

    // Get teacher's old classes before update
    const oldTeacher = await User.findById(req.params.id);
    const oldClasses = oldTeacher?.classes || [];

    // Update teacher
    const teacher = await User.findOneAndUpdate(
      { _id: req.params.id, role: "teacher" },
      req.body,
      { new: true }
    ).select("-password");

    if (!teacher)
      return res.status(404).json({ message: "Không tìm thấy giảng viên" });

    // Sync homeroomTeacher in Class documents
    if (newClasses !== undefined) {
      // Remove teacher from old classes
      for (const className of oldClasses) {
        if (!newClasses.includes(className)) {
          await Class.updateMany(
            { name: className, homeroomTeacher: req.params.id },
            { $set: { homeroomTeacher: null } }
          );
        }
      }

      // Add teacher to new classes
      for (const className of newClasses) {
        await Class.updateOne(
          { name: className },
          { $set: { homeroomTeacher: req.params.id } }
        );
      }
    }

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
