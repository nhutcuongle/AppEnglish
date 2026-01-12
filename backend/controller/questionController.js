import Question from "../models/Question.js";
import Lesson from "../models/Lesson.js";
import Class from "../models/Class.js";

/* ================= CREATE QUESTION ================= */
export const createQuestion = async (req, res) => {
  try {
    const {
      lesson,
      skill,
      type,
      content,
      options,
      correctAnswer,
      explanation,
      isPublished,
    } = req.body;

    /* ===== VALIDATE ===== */
    if (!lesson || !skill || !type || !content) {
      return res.status(400).json({
        message: "Thiếu lesson, skill, type hoặc content",
      });
    }

    /* ===== CHECK LESSON ===== */
    const lessonData = await Lesson.findById(lesson);
    if (!lessonData) {
      return res.status(400).json({ message: "Lesson không tồn tại" });
    }

    /* ===== CHECK HOMEROOM TEACHER ===== */
    const teacherClass = await Class.findOne({
      homeroomTeacher: req.user._id,
      isActive: true,
    });

    if (!teacherClass) {
      return res.status(403).json({
        message: "Bạn không phải giáo viên chủ nhiệm lớp nào",
      });
    }

    /* ===== AUTO QUESTION ORDER (THEO LESSON + CLASS) ===== */
    const lastQuestion = await Question.findOne({
      lesson,
      class: teacherClass._id,
    })
      .sort({ order: -1 })
      .select("order");

    const nextOrder = lastQuestion ? lastQuestion.order + 1 : 1;

    /* ===== IMAGE ===== */
    const imageCaptions = Array.isArray(req.body.imageCaptions)
      ? req.body.imageCaptions
      : req.body.imageCaptions
      ? [req.body.imageCaptions]
      : [];

    const images =
      req.files?.images?.map((file, index) => ({
        url: file.path,
        caption: imageCaptions[index] || "",
        order: index + 1,
      })) || [];

    /* ===== AUDIO ===== */
    const audioCaptions = Array.isArray(req.body.audioCaptions)
      ? req.body.audioCaptions
      : req.body.audioCaptions
      ? [req.body.audioCaptions]
      : [];

    const audios =
      req.files?.audios?.map((file, index) => ({
        url: file.path,
        caption: audioCaptions[index] || "",
        order: index + 1,
      })) || [];

    /* ===== VIDEO ===== */
    const videoCaptions = Array.isArray(req.body.videoCaptions)
      ? req.body.videoCaptions
      : req.body.videoCaptions
      ? [req.body.videoCaptions]
      : [];

    const videos =
      req.files?.videos?.map((file, index) => ({
        url: file.path,
        caption: videoCaptions[index] || "",
        order: index + 1,
      })) || [];

    /* ===== CREATE ===== */
    const question = await Question.create({
      lesson,
      skill,
      type,
      content,
      options,
      correctAnswer,
      explanation,
      isPublished,
      order: nextOrder,
      images,
      audios,
      videos,
      class: teacherClass._id, // ⭐ GẮN LỚP
    });

    res.status(201).json({
      message: "Tạo question thành công",
      question,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET QUESTIONS BY LESSON ================= */
export const getQuestionsByLesson = async (req, res) => {
  try {
    let classId = null;

    /* REQ.USER.CLASS chỉ có ở Student (do authMiddleware populate hoặc có sẵn) 
       Teacher thì không có field này trong User model -> phải tìm trong Class collection */
    
    if (req.user.role === "student") {
      if (!req.user.class) {
        return res.status(403).json({
          message: "Học sinh chưa được xếp lớp",
        });
      }
      classId = req.user.class;
    } else if (req.user.role === "teacher") {
       // Tìm lớp mà giáo viên này chủ nhiệm
      const teacherClass = await Class.findOne({
        homeroomTeacher: req.user._id,
        isActive: true,
      });

      if (!teacherClass) {
        return res.status(403).json({
          message: "Bạn không phải giáo viên chủ nhiệm lớp nào",
        });
      }
      classId = teacherClass._id;
    } else if (req.user.role === "admin" || req.user.role === "school") {
      // Admin/School có thể xem nội dung nếu muốn (tùy logic, ở đây tạm allow all hoặc chặn)
      // Nếu muốn test nhanh có thể return, hoặc yêu cầu gửi classId trong query
      // Ở đây tạm thời chặn nếu không logic cụ thể
       return res.status(403).json({
          message: "Role này cần gửi classId cụ thể (chưa implement)",
       });
    }

    const questions = await Question.find({
      lesson: req.params.lessonId,
      class: classId, // ⭐ FILTER THEO LỚP ĐÃ XÁC ĐỊNH
      isPublished: true,
    })
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: questions.length,
      data: questions,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= UPDATE QUESTION ================= */
export const updateQuestion = async (req, res) => {
  try {
    // Chỉ Teacher mới được sửa
    if (req.user.role !== "teacher") {
       return res.status(403).json({ message: "Chỉ giáo viên mới được sửa câu hỏi" });
    }

    /* ===== CHECK HOMEROOM TEACHER ===== */
    const teacherClass = await Class.findOne({
      homeroomTeacher: req.user._id,
      isActive: true,
    });

    if (!teacherClass) {
      return res.status(403).json({
        message: "Bạn không phải giáo viên chủ nhiệm lớp nào",
      });
    }

    /* ===== CHECK QUESTION BELONGS TO TEACHER'S CLASS ===== */
    const question = await Question.findOne({
      _id: req.params.id,
      class: teacherClass._id, // Question phải thuộc lớp của GV
    });

    if (!question) {
      return res.status(404).json({
        message: "Question không tồn tại hoặc không thuộc lớp chủ nhiệm của bạn",
      });
    }

    const allowedFields = [
      "content",
      "options",
      "correctAnswer",
      "explanation",
      "order",
      "isPublished",
      "images",
      "audios",
      "videos",
    ];

    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        question[field] = req.body[field];
      }
    });

    await question.save();

    res.json({
      message: "Cập nhật question thành công",
      question,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= DELETE QUESTION ================= */
export const deleteQuestion = async (req, res) => {
  try {
     // Chỉ Teacher mới được xóa
    if (req.user.role !== "teacher") {
       return res.status(403).json({ message: "Chỉ giáo viên mới được xóa câu hỏi" });
    }

    /* ===== CHECK HOMEROOM TEACHER ===== */
    const teacherClass = await Class.findOne({
      homeroomTeacher: req.user._id,
      isActive: true,
    });

    if (!teacherClass) {
      return res.status(403).json({
        message: "Bạn không phải giáo viên chủ nhiệm lớp nào",
      });
    }

    const question = await Question.findOneAndDelete({
      _id: req.params.id,
      class: teacherClass._id, // Chỉ xóa nếu thuộc lớp GV chủ nhiệm
    });

    if (!question) {
      return res.status(404).json({
        message: "Question không tồn tại hoặc không thuộc lớp chủ nhiệm của bạn",
      });
    }

    res.json({ message: "Xóa question thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
