// import User from "../models/User.js";

// /* GET ALL STUDENTS */
// export const getAllStudents = async (req, res) => {
//   try {
//     const students = await User.find({ role: "student" }).select("-password");
//     res.json(students);
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };

// /* CREATE STUDENT */

// export const createStudent = async (req, res) => {
//   try {
//     const { username, email, password, classId } = req.body;

//     const hashedPassword = await bcrypt.hash(password, 10);

//     const student = await User.create({
//       username,
//       email,
//       password: hashedPassword,
//       role: "student",
//       class: classId,
//     });

//     await Class.findByIdAndUpdate(classId, {
//       $push: { students: student._id },
//     });

//     res.status(201).json({
//       message: "Tạo học sinh và gán lớp thành công",
//       student,
//     });
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };
// /* UPDATE STUDENT */
// export const updateStudent = async (req, res) => {
//   try {
//     const student = await User.findOneAndUpdate(
//       { _id: req.params.id, role: "student" },
//       req.body,
//       { new: true }
//     ).select("-password");

//     if (!student)
//       return res.status(404).json({ message: "Không tìm thấy học sinh" });

//     res.json(student);
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };

// /* DISABLE USER */
// export const disableUser = async (req, res) => {
//   try {
//     const user = await User.findByIdAndUpdate(
//       req.params.id,
//       { isDisabled: true },
//       { new: true }
//     );

//     if (!user) return res.status(404).json({ message: "Không tìm thấy user" });

//     res.json({ message: "Khóa user thành công" });
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };

// /* ENABLE USER */
// export const enableUser = async (req, res) => {
//   try {
//     const user = await User.findByIdAndUpdate(
//       req.params.id,
//       { isDisabled: false },
//       { new: true }
//     );

//     if (!user) return res.status(404).json({ message: "Không tìm thấy user" });

//     res.json({ message: "Mở khóa user thành công" });
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };

// /* DELETE STUDENT */
// export const deleteStudent = async (req, res) => {
//   try {
//     const student = await User.findOneAndDelete({
//       _id: req.params.id,
//       role: "student",
//     });

//     if (!student)
//       return res.status(404).json({ message: "Không tìm thấy học sinh" });

//     res.json({ message: "Xóa học sinh thành công" });
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };

// /* TEACHER: GET ACTIVE STUDENTS (GÁN BÀI) */
// export const getAssignableStudents = async (req, res) => {
//   try {
//     const students = await User.find({
//       role: "student",
//       isDisabled: false,
//     }).select("_id username email");

//     res.json(students);
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// };


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
    const { username, email, password, classId } = req.body;

    let classData = null;

    // Nếu có classId → validate lớp
    if (classId) {
      classData = await Class.findOne({
        _id: classId,
        school: req.user.id,
      });

      if (!classData) {
        return res.status(400).json({ message: "Lớp không hợp lệ" });
      }
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const student = await User.create({
      username,
      email,
      password: hashedPassword,
      role: "student",
      class: classData ? classData._id : null,
    });

    // Đồng bộ Class → students[]
    if (classData) {
      await Class.findByIdAndUpdate(classData._id, {
        $addToSet: { students: student._id },
      });
    }

    res.status(201).json({
      message: "Tạo học sinh thành công",
      student,
    });
  } catch (err) {
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
