import Class from "../models/Class.js";
import User from "../models/User.js";


/* SCHOOL: CREATE CLASS */
export const createClass = async (req, res) => {
  try {
    const { name, grade, homeroomTeacher } = req.body;

    // 1. Validate dữ liệu cơ bản
    if (!name || !grade) {
      return res.status(400).json({
        message: "Tên lớp và khối là bắt buộc",
      });
    }

    // 2. Kiểm tra trùng lớp trong cùng school
    const existedClass = await Class.findOne({
      name,
      grade,
      school: req.user.id,
    });

    if (existedClass) {
      return res.status(400).json({
        message: "Lớp đã tồn tại trong hệ thống",
      });
    }

    // 3. Tạo lớp
    const newClass = await Class.create({
      name,
      grade,
      school: req.user.id,
      homeroomTeacher: homeroomTeacher || null,
    });

    res.status(201).json({
      message: "Tạo lớp học thành công",
      newClass,
    });
  } catch (err) {
    res.status(500).json({
      message: "Lỗi server",
      error: err.message,
    });
  }
};


/* SCHOOL: ASSIGN TEACHER */
export const assignTeacherToClass = async (req, res) => {
  try {
    const { classId, teacherId } = req.body;

    const updatedClass = await Class.findByIdAndUpdate(
      classId,
      { homeroomTeacher: teacherId },
      { new: true }
    ).populate("homeroomTeacher", "username email");

    res.json({
      message: "Gán giáo viên thành công",
      updatedClass,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
/* SCHOOL: GET ALL CLASSES */
export const getAllClasses = async (req, res) => {
  try {
    const classes = await Class.find({ school: req.user.id })
      .populate("homeroomTeacher", "username email fullName")
      .sort({ grade: 1, name: 1 });

    // Count students for each class by querying Users with matching class name
    const classesWithCounts = await Promise.all(
      classes.map(async (classDoc) => {
        const studentCount = await User.countDocuments({
          role: "student",
          classes: classDoc.name, // Students store class name in their classes array
        });

        return {
          ...classDoc.toObject(),
          studentCount,
        };
      })
    );

    res.json(classesWithCounts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* SCHOOL: UPDATE CLASS */
export const updateClass = async (req, res) => {
  try {
    const { name, grade, homeroomTeacher, schedule, room } = req.body;

    // Kiểm tra trùng lớp
    const duplicatedClass = await Class.findOne({
      _id: { $ne: req.params.id },
      name,
      grade,
      school: req.user.id,
    });

    if (duplicatedClass) {
      return res
        .status(400)
        .json({ message: "Lớp đã tồn tại trong hệ thống" });
    }

    const updateData = { name, grade };
    if (homeroomTeacher !== undefined) updateData.homeroomTeacher = homeroomTeacher;
    if (schedule !== undefined) updateData.schedule = schedule;
    if (room !== undefined) updateData.room = room;

    const updatedClass = await Class.findOneAndUpdate(
      { _id: req.params.id, school: req.user.id },
      updateData,
      { new: true }
    ).populate("homeroomTeacher", "username email");


    if (!updatedClass)
      return res.status(404).json({ message: "Không tìm thấy lớp" });

    res.json({
      message: "Cập nhật lớp thành công",
      updatedClass,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
/* SCHOOL: DELETE CLASS */
export const deleteClass = async (req, res) => {
  try {
    const classData = await Class.findOne({
      _id: req.params.id,
      school: req.user.id,
    });

    if (!classData)
      return res.status(404).json({ message: "Không tìm thấy lớp" });

    // Gỡ lớp khỏi học sinh
    await User.updateMany(
      { class: classData._id },
      { $set: { class: null } }
    );

    await classData.deleteOne();

    res.json({ message: "Xóa lớp học thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
/* SCHOOL: GET CLASS DETAIL */
export const getClassDetail = async (req, res) => {
  try {
    const classData = await Class.findOne({
      _id: req.params.id,
      school: req.user.id,
    })
      .populate("homeroomTeacher", "username email")
      .populate("students", "username email");

    if (!classData)
      return res.status(404).json({ message: "Không tìm thấy lớp" });

    res.json(classData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* TEACHER: GET MY CLASSES */
export const getTeacherClasses = async (req, res) => {
  try {
    const classes = await Class.find({ 
      homeroomTeacher: req.user._id,
      isActive: true 
    })
    .populate("school", "username fullName")
    .sort({ grade: 1, name: 1 });

    const classesWithCounts = await Promise.all(
      classes.map(async (classDoc) => {
        const studentCount = await User.countDocuments({
          role: "student",
          class: classDoc._id,
        });

        return {
          ...classDoc.toObject(),
          studentCount,
        };
      })
    );

    res.json(classesWithCounts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

