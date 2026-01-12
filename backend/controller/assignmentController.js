import Assignment from "../models/Assignment.js";
import Class from "../models/Class.js";

/* ================= CREATE OR UPDATE ASSIGNMENT ================= */
export const createOrUpdateAssignment = async (req, res) => {
  try {
    const { lesson, deadline, isPublished } = req.body;

    if (!lesson) {
      return res.status(400).json({ message: "Thiếu lesson ID" });
    }

    /* Kiểm tra giáo viên chủ nhiệm để xác định lớp */
    const teacherClass = await Class.findOne({
      homeroomTeacher: req.user._id,
      isActive: true,
    });

    if (!teacherClass) {
      return res.status(403).json({
        message: "Bạn không phải giáo viên chủ nhiệm lớp nào",
      });
    }

    /* Upsert Assignment */
    const assignment = await Assignment.findOneAndUpdate(
      { class: teacherClass._id, lesson },
      { 
        deadline: deadline !== undefined ? deadline : null,
        isPublished: isPublished !== undefined ? isPublished : true 
      },
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    res.status(200).json({
      message: "Cập nhật thiết lập bài tập thành công",
      assignment,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET ASSIGNMENT SETTINGS ================= */
export const getAssignmentByLesson = async (req, res) => {
  try {
    const { lessonId } = req.params;
    let classId = null;

    if (req.user.role === "student") {
      if (!req.user.class) {
        return res.status(403).json({ message: "Học sinh chưa được xếp lớp" });
      }
      classId = req.user.class;
    } else if (req.user.role === "teacher") {
      const teacherClass = await Class.findOne({
        homeroomTeacher: req.user._id,
        isActive: true,
      });
      if (!teacherClass) {
        return res.status(403).json({ message: "Bạn không phải giáo viên chủ nhiệm lớp nào" });
      }
      classId = teacherClass._id;
    }

    const assignment = await Assignment.findOne({ class: classId, lesson: lessonId });

    res.json({
      data: assignment || null,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
