import User from "../models/User.js";

/* GET ALL STUDENTS */
export const getAllStudents = async (req, res) => {
  try {
    const students = await User.find({ role: "student" }).select("-password");
    res.json(students);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* CREATE STUDENT */
export const createStudent = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    const student = await User.create({
      username,
      email,
      password,
      role: "student",
    });

    res.status(201).json({
      message: "Tạo học sinh thành công",
      student,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* UPDATE STUDENT */
export const updateStudent = async (req, res) => {
  try {
    const student = await User.findOneAndUpdate(
      { _id: req.params.id, role: "student" },
      req.body,
      { new: true }
    ).select("-password");

    if (!student)
      return res.status(404).json({ message: "Không tìm thấy học sinh" });

    res.json(student);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* DISABLE USER */
export const disableUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isDisabled: true },
      { new: true }
    );

    if (!user)
      return res.status(404).json({ message: "Không tìm thấy user" });

    res.json({ message: "Khóa user thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ENABLE USER */
export const enableUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isDisabled: false },
      { new: true }
    );

    if (!user)
      return res.status(404).json({ message: "Không tìm thấy user" });

    res.json({ message: "Mở khóa user thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* DELETE STUDENT */
export const deleteStudent = async (req, res) => {
  try {
    const student = await User.findOneAndDelete({
      _id: req.params.id,
      role: "student",
    });

    if (!student)
      return res.status(404).json({ message: "Không tìm thấy học sinh" });

    res.json({ message: "Xóa học sinh thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* TEACHER: GET ACTIVE STUDENTS (GÁN BÀI) */
export const getAssignableStudents = async (req, res) => {
  try {
    const students = await User.find({
      role: "student",
      isDisabled: false,
    }).select("_id username email");

    res.json(students);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
