import Class from "../models/Class.js";

/* SCHOOL: CREATE CLASS */
export const createClass = async (req, res) => {
  try {
    const { name, grade } = req.body;

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

    // 3. Tạo lớp (KHÔNG gán homeroomTeacher)
    const newClass = await Class.create({
      name,
      grade,
      school: req.user.id,
      // homeroomTeacher sẽ tự = null theo schema
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
      .populate("homeroomTeacher", "username email")
      .sort({ grade: 1, name: 1 });

    res.json(classes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
/* SCHOOL: UPDATE CLASS */
export const updateClass = async (req, res) => {
  try {
    const { name, grade, homeroomTeacher } = req.body;

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

    const updatedClass = await Class.findOneAndUpdate(
      { _id: req.params.id, school: req.user.id },
      { name, grade, homeroomTeacher },
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
