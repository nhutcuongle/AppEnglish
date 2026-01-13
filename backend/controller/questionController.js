import Question from "../models/Question.js";
import Lesson from "../models/Lesson.js";
import Class from "../models/Class.js";
import Exam from "../models/Exam.js";

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
      let classId = targetLesson ? req.body.classId : null;
      const targetExamId = req.body.examId;

      if (req.user.role === "teacher") {
        if (!targetExamId) {
          return res.status(403).json({ message: "Giảng viên không có quyền tạo câu hỏi bài học hàng loạt" });
        }
        const exam = await Exam.findById(targetExamId);
        if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
          return res.status(403).json({ message: "Bạn không có quyền quản lý bài kiểm tra này" });
        }
      }

      if (req.user.role === "school") {
        // School no longer strictly requires classId in bulk
      }

      /* Get starting order number (query once for efficiency) */
      const firstQuestion = questionsData[0];
      const firstLesson = firstQuestion?.lessonId || targetLesson;
      const firstClass = firstQuestion?.classId || req.body.classId;
      const firstExam = firstQuestion?.examId || targetExamId;
      
      const lastQuestion = await Question.findOne({
        lesson: firstLesson || null,
        exam: firstExam || null,
        class: firstClass || null,
      }).sort({ order: -1 }).select("order");
      
      let currentOrder = lastQuestion ? lastQuestion.order + 1 : 1;

      const createdQuestions = [];
      
      for (const qData of questionsData) {
        const {
           lessonId: qLessonId, skill, type, content, options, correctAnswer, explanation, isPublished, points, classId: qClassId,
           images, audios, videos
        } = qData;

        const finalLesson = qLessonId || targetLesson;
        const finalClass = qClassId || req.body.classId;
        const finalExam = qData.examId || targetExamId;

        if ((!finalLesson && !finalExam) || !skill || !type || !content || (!isSchool && !finalClass)) {
          continue; 
        }

        /* Permission check for each question in bulk */
        if (isSchool) {
          if (finalClass) {
            const targetClass = await Class.findOne({ _id: finalClass, school: req.user._id });
            if (!targetClass) continue;
          }
        } else if (req.user.role === "teacher") {
          if (!finalExam || !finalClass) continue;
          // Teacher must be the homeroom teacher of finalClass
          const targetClass = await Class.findOne({ _id: finalClass, homeroomTeacher: req.user._id });
          if (!targetClass) continue;
          
          const exam = await Exam.findById(finalExam);
          if (!exam || exam.class.toString() !== finalClass.toString()) continue;
        }

        const newQuestion = await Question.create({
          lesson: isSchool ? (finalLesson || null) : null, // Teacher cannot link to Lesson
          exam: finalExam || null,
          skill, type, content, options, correctAnswer, explanation, isPublished,
          points: points || 1,
          class: finalClass || null,
          school: isSchool ? req.user._id : null,
          order: currentOrder++, // Auto-increment order
          images: images || [], 
          audios: audios || [], 
          videos: videos || []
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
    const { examId } = req.body;
    // School creates for all classes, so classId is NOT required for school role
    const isSchool = req.user.role === "school";
    
    if ((!lessonId && !examId) || !skill || !type || !content || (!isSchool && !classId)) {
      return res.status(400).json({
        message: "Thiếu lessonId/examId, skill, type, content hoặc classId",
      });
    }

    if (req.user.role !== "school") {
        // Teacher can create if it's for an Exam they own
        const { examId } = req.body;
        if (!examId || req.user.role !== "teacher") {
          return res.status(403).json({ message: "Chỉ nhà trường mới có quyền tạo câu hỏi bài học" });
        }
        const exam = await Exam.findById(examId);
        if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
           return res.status(403).json({ message: "Bạn không có quyền tạo câu hỏi cho bài kiểm tra này" });
        }
    }

    /* ===== CHECK LESSON / EXAM ===== */
    if (lessonId) {
      const lessonData = await Lesson.findById(lessonId);
      if (!lessonData) {
        return res.status(400).json({ message: "Lesson không tồn tại" });
      }
    }
    if (examId) {
      const examData = await Exam.findById(examId);
      if (!examData) {
        return res.status(400).json({ message: "Bài kiểm tra không tồn tại" });
      }
    }

    /* ===== CHECK CLASS BELONGS TO SCHOOL (IF CLASS PROVIDED) ===== */
    let targetClass = null;
    if (classId) {
       targetClass = await Class.findOne({
        _id: classId,
        isActive: true,
      });

      if (!targetClass) {
        return res.status(403).json({ message: "Lớp không tồn tại" });
      }

      // If school is creating for a specific class, verify ownership
      if (isSchool && targetClass.school.toString() !== req.user._id.toString()) {
        return res.status(403).json({ message: "Lớp không thuộc quản lý của trường bạn" });
      }
    }

    /* ===== VALIDATE EXAM BELONGS TO THIS TEACHER & CLASS ===== */
    if (req.user.role === "teacher") {
       if (!examId || !classId) {
         return res.status(400).json({ message: "Giảng viên cần cung cấp examId và classId" });
       }
       const exam = await Exam.findById(examId);
       if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
         return res.status(403).json({ message: "Bạn không có quyền quản lý bài kiểm tra này" });
       }
       if (exam.class.toString() !== classId) {
         return res.status(403).json({ message: "examId và classId không khớp nhau" });
       }
    }

    /* ===== SYNC LESSON DEADLINE ===== */
    if (deadline) {
      await Lesson.findByIdAndUpdate(
        lessonId,
        { deadline: deadline },
        { new: true }
      );
    }

    /* ===== AUTO QUESTION ORDER ===== */
    const lastQuestion = await Question.findOne({
      lesson: lessonId || null,
      exam: examId || null,
      class: classId || null,
      school: isSchool ? req.user._id : null
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
      lesson: isSchool ? (lessonId || null) : null,
      exam: examId || null,
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
      class: classId || null,
      school: isSchool ? req.user._id : null,
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

    /* Find schoolId to fetch school-wide questions */
    let schoolId = null;
    if (req.user.role === "student") {
        const studentClass = await Class.findById(classId).select("school");
        if (studentClass) schoolId = studentClass.school;
    } else if (req.user.role === "teacher") {
        const teacherClass = await Class.findById(classId).select("school");
        if (teacherClass) schoolId = teacherClass.school;
    } else if (req.user.role === "school") {
        schoolId = req.user._id;
    }

    const questions = await Question.find({
      lesson: req.params.lessonId,
      $or: [
        { class: classId }, // Lớp cụ thể
        { class: null, school: schoolId } // Toàn trường
      ],
      isPublished: true,
    })
      .sort({ order: 1, createdAt: 1 })
      .lean();

    /* ===== FETCH LESSON DEADLINE ===== */
    const lesson = await Lesson.findById(req.params.lessonId)
      .select("deadline")
      .lean();

    res.json({
      total: questions.length,
      data: questions,
      deadline: lesson?.deadline || null, // Trả về deadline từ lesson
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
      const question = await Question.findById(req.params.id);
      if (!question || !question.exam) {
        return res.status(403).json({ message: "Chỉ nhà trường mới được sửa câu hỏi bài học" });
      }
      const exam = await Exam.findById(question.exam);
      if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
        return res.status(403).json({ message: "Bạn không có quyền sửa câu hỏi bài kiểm tra này" });
      }
    }

    /* ===== CHECK QUESTION BELONGS TO SCHOOL'S CLASS ===== */
    const question = await Question.findById(req.params.id).populate("class");

    if (!question) {
      return res.status(404).json({ message: "Question không tồn tại" });
    }

    if (req.user.role === "school") {
      // If it has class, check class.school. If no class, check question.school
      const isOwner = (question.class && question.class.school.toString() === req.user._id.toString()) || 
                      (!question.class && question.school && question.school.toString() === req.user._id.toString());
      
      if (!isOwner) {
         return res.status(403).json({
          message: "Question không thuộc quản lý của trường bạn",
        });
      }
    } else if (req.user.role === "teacher") {
      const exam = await Exam.findById(question.exam);
      if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
        return res.status(403).json({ message: "Bạn không có quyền sửa câu hỏi bài kiểm tra này" });
      }
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
      "points",
    ];

    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        question[field] = req.body[field];
      }
    });

    /* ===== SYNC LESSON DEADLINE IF UPDATED ===== */
    if (req.body.deadline !== undefined && question.lesson) {
      await Lesson.findByIdAndUpdate(
        question.lesson,
        { deadline: req.body.deadline },
        { new: true }
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
      const question = await Question.findById(req.params.id);
      if (!question || !question.exam) {
        return res.status(403).json({ message: "Chỉ nhà trường mới được xóa câu hỏi bài học" });
      }
      const exam = await Exam.findById(question.exam);
      if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
        return res.status(403).json({ message: "Bạn không có quyền xóa câu hỏi bài kiểm tra này" });
      }
    }

    const question = await Question.findById(req.params.id).populate("class");

    if (!question) {
      return res.status(404).json({
        message: "Question không tồn tại",
      });
    }

    if (req.user.role === "school") {
      const isOwner = (question.class && question.class.school.toString() === req.user._id.toString()) || 
                      (!question.class && question.school && question.school.toString() === req.user._id.toString());

      if (!isOwner) {
          return res.status(403).json({
              message: "Question không thuộc quản lý của trường bạn",
          });
      }
    } else if (req.user.role === "teacher") {
      const exam = await Exam.findById(question.exam);
      if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
        return res.status(403).json({ message: "Bạn không có quyền xóa câu hỏi bài kiểm tra này" });
      }
    }

    await Question.findByIdAndDelete(req.params.id);

    res.json({ message: "Xóa question thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
