import Question from "../models/Question.js";
import Lesson from "../models/Lesson.js";
import Class from "../models/Class.js";
import Assignment from "../models/Assignment.js";

/* ================= CREATE QUESTION ================= */
export const createQuestion = async (req, res) => {
  try {
    /* ===== BULK CREATE ===== */
    let questionsData = null;
    let commonDeadline = null;
    let targetLesson = null;

    if (Array.isArray(req.body)) {
      questionsData = req.body;
    } else if (req.body.questions && Array.isArray(req.body.questions)) {
      questionsData = req.body.questions;
      commonDeadline = req.body.deadline;
      targetLesson = req.body.lessonId;
    }

    if (questionsData) {
      if (questionsData.length === 0) {
        return res.status(400).json({ message: "Danh sách câu hỏi trống" });
      }

      /* Check Permissions & Class */
      let classId = targetLesson ? req.body.classId : null; // targetLesson implies single lesson context in bulk body

      let teacherClass = null;
      if (req.user.role === "teacher") {
        return res.status(403).json({ message: "Giảng viên không có quyền tạo câu hỏi" });
      }

      if (req.user.role === "school") {
        if (!targetLesson && questionsData.some(q => !q.classId)) {
             return res.status(400).json({ message: "Thiếu classId cho một số câu hỏi" });
        }
      }

      const createdQuestions = [];
      
      for (const qData of questionsData) {
        const {
           lessonId: qLessonId, skill, type, content, options, correctAnswer, explanation, isPublished, points, classId: qClassId
        } = qData;

        const finalLesson = qLessonId || targetLesson;
        const finalClass = qClassId || req.body.classId;

        if (!finalLesson || !skill || !type || !content || !finalClass) {
          continue; 
        }

        /* Check if class belongs to school */
        const targetClass = await Class.findOne({ _id: finalClass, school: req.user._id });
        if (!targetClass) continue;

        const lessonExists = await Lesson.exists({ _id: finalLesson });
        if (!lessonExists) continue;

        /* Auto Order */
        const lastQuestion = await Question.findOne({
            lesson: finalLesson,
            class: finalClass,
        }).sort({ order: -1 }).select("order");
        const nextOrder = lastQuestion ? lastQuestion.order + 1 : 1;

        const newQuestion = await Question.create({
          lesson: finalLesson, skill, type, content, options, correctAnswer, explanation, isPublished,
          points: points || 1,
          class: finalClass,
          order: nextOrder,
          images: [], audios: [], videos: [] 
        });
        createdQuestions.push(newQuestion);
      }

      return res.status(201).json({
        message: `Đã tạo ${createdQuestions.length} câu hỏi`,
        data: createdQuestions,
        deadline: commonDeadline || null
      });
    }

    /* ===== SINGLE CREATE (Existing Logic) ===== */
    const {
      lessonId,
      skill,
      type,
      content,
      options,
      correctAnswer,
      explanation,
      isPublished,
      points,
      classId,
      deadline
    } = req.body;

    /* ===== VALIDATE ===== */
    if (!lessonId || !skill || !type || !content || !classId) {
      return res.status(400).json({
        message: "Thiếu lessonId, skill, type, content hoặc classId",
      });
    }

    if (req.user.role !== "school") {
        return res.status(403).json({ message: "Chỉ nhà trường mới có quyền tạo câu hỏi" });
    }

    /* ===== CHECK LESSON ===== */
    const lessonData = await Lesson.findById(lessonId);
    if (!lessonData) {
      return res.status(400).json({ message: "Lesson không tồn tại" });
    }

    /* ===== CHECK CLASS BELONGS TO SCHOOL ===== */
    const targetClass = await Class.findOne({
      _id: classId,
      school: req.user._id,
      isActive: true,
    });

    if (!targetClass) {
      return res.status(403).json({
        message: "Lớp không tồn tại hoặc không thuộc quản lý của trường bạn",
      });
    }

    /* ===== SYNC ASSIGNMENT DEADLINE ===== */
    if (deadline) {
      await Assignment.findOneAndUpdate(
        { class: classId, lesson: lessonId },
        { deadline: deadline },
        { upsert: true, new: true }
      );
    }

    /* ===== AUTO QUESTION ORDER (THEO LESSON + CLASS) ===== */
    const lastQuestion = await Question.findOne({
      lesson: lessonId,
      class: classId,
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
      lesson: lessonId,
      skill,
      type,
      content,
      options,
      correctAnswer,
      explanation,
      isPublished,
      points: points || 1,
      order: nextOrder,
      images,
      audios,
      videos,
      class: classId,
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

    /* ===== FETCH ASSIGNMENT SETTINGS (DEADLINE) ===== */
    const assignment = await Assignment.findOne({
      lesson: req.params.lessonId,
      class: classId
    }).select("deadline isPublished").lean();

    res.json({
      total: questions.length,
      data: questions,
      assignment: assignment || null, // Trả về deadline chung ở đây
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= UPDATE QUESTION ================= */
export const updateQuestion = async (req, res) => {
  try {
    // Chỉ School mới được sửa
    if (req.user.role !== "school") {
       return res.status(403).json({ message: "Chỉ nhà trường mới được sửa câu hỏi" });
    }

    /* ===== CHECK QUESTION BELONGS TO SCHOOL'S CLASS ===== */
    const question = await Question.findById(req.params.id).populate("class");

    if (!question) {
      return res.status(404).json({ message: "Question không tồn tại" });
    }

    if (question.class.school.toString() !== req.user._id.toString()) {
       return res.status(403).json({
        message: "Question không thuộc quản lý của trường bạn",
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
      "deadline",
      "points",
    ];

    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        question[field] = req.body[field];
      }
    });

    /* ===== SYNC ASSIGNMENT DEADLINE IF UPDATED ===== */
    if (req.body.deadline !== undefined) {
      await Assignment.findOneAndUpdate(
        { class: question.class._id, lesson: question.lesson },
        { deadline: req.body.deadline },
        { upsert: true, new: true }
      );
    }

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
    // Chỉ School mới được xóa
    if (req.user.role !== "school") {
       return res.status(403).json({ message: "Chỉ nhà trường mới được xóa câu hỏi" });
    }

    const question = await Question.findById(req.params.id).populate("class");

    if (!question) {
      return res.status(404).json({
        message: "Question không tồn tại",
      });
    }

    if (question.class.school.toString() !== req.user._id.toString()) {
        return res.status(403).json({
            message: "Question không thuộc quản lý của trường bạn",
        });
    }

    await Question.findByIdAndDelete(req.params.id);

    res.json({ message: "Xóa question thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
