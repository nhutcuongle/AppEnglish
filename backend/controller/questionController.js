import Question from "../models/Question.js";
import Lesson from "../models/Lesson.js";
import Class from "../models/Class.js";
import Exam from "../models/Exam.js";
import { processMedia } from "../utils/mediaHelper.js";

/* ================= CREATE QUESTION (SCHOOL ONLY - FOR LESSONS) ================= */
export const createQuestion = async (req, res) => {
  try {
    if (req.user.role !== "school") {
      return res.status(403).json({ message: "Chỉ nhà trường mới có quyền sử dụng đầu API này" });
    }

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

    /* ===== BULK CREATE ===== */
    let questionsData = null;
    if (Array.isArray(req.body)) {
      questionsData = req.body;
    } else if (req.body.questions && Array.isArray(req.body.questions)) {
      questionsData = req.body.questions;
    }

    if (questionsData) {
      if (questionsData.length === 0) {
        return res.status(400).json({ message: "Danh sách câu hỏi trống" });
      }

      const targetLesson = req.body.lessonId || questionsData[0].lessonId;
      if (!targetLesson) {
        return res.status(400).json({ message: "Thiếu lessonId cho tất cả câu hỏi" });
      }

      const lastQuestion = await Question.findOne({
        lesson: targetLesson,
        school: req.user._id,
      }).sort({ order: -1 }).select("order");
      
      let currentOrder = lastQuestion ? lastQuestion.order + 1 : 1;
      const createdQuestions = [];
      
      for (const qData of questionsData) {
        const {
           skill, type, content, options, correctAnswer, explanation, isPublished, points, classId: qClassId,
           images, audios, videos
        } = qData;

        if (!skill || !type || !content) continue;

        const newQuestion = await Question.create({
          lesson: targetLesson,
          exam: null,
          skill, type, content, options, correctAnswer, explanation, isPublished,
          points: points || 1,
          class: qClassId || req.body.classId || null,
          school: req.user._id,
          order: currentOrder++,
          images: images || [], 
          audios: audios || [], 
          videos: videos || []
        });
        createdQuestions.push(newQuestion);
      }

      return res.status(201).json({
        message: `Đã tạo ${createdQuestions.length} câu hỏi cho bài học`,
        data: createdQuestions
      });
    }

    /* ===== SINGLE CREATE ===== */
    if (!lessonId || !skill || !type || !content) {
      return res.status(400).json({ message: "Thiếu lessonId, skill, type hoặc content" });
    }

    const lessonData = await Lesson.findById(lessonId);
    if (!lessonData) return res.status(400).json({ message: "Lesson không tồn tại" });

    if (deadline && req.user.role === "school") {
      await Lesson.findByIdAndUpdate(lessonId, { deadline });
    }

    const lastQuestion = await Question.findOne({
      lesson: lessonId,
      school: req.user._id
    }).sort({ order: -1 }).select("order");

    const nextOrder = lastQuestion ? lastQuestion.order + 1 : 1;

    /* Media Handling */
    const media = processMedia(req.files, req.body);

    const question = await Question.create({
      lesson: lessonId,
      exam: null,
      skill, type, content, options, correctAnswer, explanation,
      isPublished,
      points: points || 1,
      order: nextOrder,
      images: media.images || [],
      audios: media.audios || [],
      videos: media.videos || [],
      class: classId || null,
      school: req.user._id,
    });

    res.status(201).json({ message: "Tạo câu hỏi bài học thành công", question });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= CREATE QUESTION FOR TEACHER (EXAM ONLY) ================= */
export const createQuestionForTeacher = async (req, res) => {
  try {
    if (req.user.role !== "teacher") {
      return res.status(403).json({ message: "Chỉ giảng viên mới có quyền sử dụng đầu API này" });
    }

    const {
      examId,
      skill,
      type,
      content,
      options,
      correctAnswer,
      explanation,
      isPublished,
      points
    } = req.body;

    /* ===== BULK CREATE ===== */
    let questionsData = null;
    if (Array.isArray(req.body)) {
      questionsData = req.body;
    } else if (req.body.questions && Array.isArray(req.body.questions)) {
      questionsData = req.body.questions;
    }

    const targetExamId = examId || (questionsData && questionsData[0]?.examId);
    if (!targetExamId) return res.status(400).json({ message: "Thiếu examId" });

    const exam = await Exam.findById(targetExamId);
    if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Bạn không có quyền quản lý bài kiểm tra này" });
    }

    if (questionsData) {
      if (questionsData.length === 0) {
        return res.status(400).json({ message: "Danh sách câu hỏi trống" });
      }

      const lastQuestion = await Question.findOne({ exam: targetExamId }).sort({ order: -1 }).select("order");
      let currentOrder = lastQuestion ? lastQuestion.order + 1 : 1;
      const createdQuestions = [];
      
      for (const qData of questionsData) {
        const {
           skill, type, content, options, correctAnswer, explanation, isPublished, points,
           images, audios, videos
        } = qData;

        if (!skill || !type || !content) continue;

        const newQuestion = await Question.create({
          lesson: null,
          exam: targetExamId,
          skill, type, content, options, correctAnswer, explanation, isPublished,
          points: points || 1,
          class: exam.class,
          school: null,
          order: currentOrder++,
          images: images || [], 
          audios: audios || [], 
          videos: videos || []
        });
        createdQuestions.push(newQuestion);
      }

      return res.status(201).json({
        message: `Đã tạo ${createdQuestions.length} câu hỏi cho bài kiểm tra`,
        data: createdQuestions
      });
    }

    /* ===== SINGLE CREATE ===== */
    if (!skill || !type || !content) {
      return res.status(400).json({ message: "Thiếu skill, type hoặc content" });
    }

    const lastQuestion = await Question.findOne({ exam: targetExamId }).sort({ order: -1 }).select("order");
    const nextOrder = lastQuestion ? lastQuestion.order + 1 : 1;

    /* Media Handling */
    const media = processMedia(req.files, req.body);

    const question = await Question.create({
      lesson: null,
      exam: targetExamId,
      skill, type, content, options, correctAnswer, explanation,
      isPublished,
      points: points || 1,
      order: nextOrder,
      images: media.images || [],
      audios: media.audios || [],
      videos: media.videos || [],
      class: exam.class,
      school: null,
    });

    res.status(201).json({ message: "Tạo câu hỏi bài kiểm tra thành công", question });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= GET QUESTIONS BY LESSON ================= */
export const getQuestionsByLesson = async (req, res) => {
  try {
    let query = { lesson: req.params.lessonId };

    if (req.user.role === "student") {
      if (!req.user.class) return res.status(403).json({ message: "Học sinh chưa được xếp lớp" });
      const classId = req.user.class;
      const targetClass = await Class.findById(classId).select("school");
      const schoolId = targetClass ? targetClass.school : null;

      query = {
        lesson: req.params.lessonId,
        $or: [
          { class: classId },
          { class: null, school: schoolId }
        ],
        isPublished: true,
      };
    } else if (req.user.role === "teacher") {
      const teacherClass = await Class.findOne({ homeroomTeacher: req.user._id, isActive: true });
      if (!teacherClass) return res.status(403).json({ message: "Bạn không phải giáo viên chủ nhiệm lớp nào" });
      const classId = teacherClass._id;
      const schoolId = teacherClass.school;

      query = {
        lesson: req.params.lessonId,
        $or: [
          { class: classId },
          { class: null, school: schoolId }
        ],
        isPublished: true,
      };
    } else if (req.user.role === "school") {
      // School can see all questions they created for this lesson
      query = {
        lesson: req.params.lessonId,
        school: req.user._id,
      };
    }

    const questions = await Question.find(query).sort({ order: 1, createdAt: 1 }).lean();
    const lesson = await Lesson.findById(req.params.lessonId).select("deadline").lean();

    res.json({
      total: questions.length,
      data: questions,
      deadline: lesson?.deadline || null,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
/* ================= UPDATE QUESTION ================= */
export const updateQuestion = async (req, res) => {
  try {
    const question = await Question.findById(req.params.id);
    if (!question) return res.status(404).json({ message: "Question không tồn tại" });

    // Permission Check
    if (req.user.role === "school") {
      const targetClass = question.class ? await Class.findById(question.class) : null;
      const isOwner = (targetClass && targetClass.school.toString() === req.user._id.toString()) || 
                      (!question.class && question.school && question.school.toString() === req.user._id.toString());
      if (!isOwner) return res.status(403).json({ message: "Question không thuộc quản lý của trường bạn" });
    } else if (req.user.role === "teacher") {
      if (!question.exam) return res.status(403).json({ message: "Giáo viên chỉ được sửa câu hỏi trong bài kiểm tra" });
      const exam = await Exam.findById(question.exam);
      if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
        return res.status(403).json({ message: "Bạn không có quyền sửa câu hỏi bài kiểm tra này" });
      }
    } else {
      return res.status(403).json({ message: "Bạn không có quyền thực hiện hành động này" });
    }

    const allowedFields = ["content", "options", "correctAnswer", "explanation", "order", "isPublished", "images", "audios", "videos", "points"];
    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) question[field] = req.body[field];
    });

    /* ===== XỬ LÝ MEDIA MỚI (NẾU CÓ) ===== */
    const media = processMedia(req.files, req.body);
    if (media.images) question.images = media.images;
    if (media.audios) question.audios = media.audios;
    if (media.videos) question.videos = media.videos;

    if (req.body.deadline !== undefined && question.lesson && req.user.role === "school") {
      await Lesson.findByIdAndUpdate(question.lesson, { deadline: req.body.deadline });
    }

    await question.save();
    res.json({ message: "Cập nhật question thành công", question });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= DELETE QUESTION ================= */
export const deleteQuestion = async (req, res) => {
  try {
    const question = await Question.findById(req.params.id);
    if (!question) return res.status(404).json({ message: "Question không tồn tại" });

    // Permission Check
    if (req.user.role === "school") {
      const targetClass = question.class ? await Class.findById(question.class) : null;
      const isOwner = (targetClass && targetClass.school.toString() === req.user._id.toString()) || 
                      (!question.class && question.school && question.school.toString() === req.user._id.toString());
      if (!isOwner) return res.status(403).json({ message: "Question không thuộc quản lý của trường bạn" });
    } else if (req.user.role === "teacher") {
      if (!question.exam) return res.status(403).json({ message: "Giáo viên chỉ được xóa câu hỏi trong bài kiểm tra" });
      const exam = await Exam.findById(question.exam);
      if (!exam || exam.teacher.toString() !== req.user._id.toString()) {
        return res.status(403).json({ message: "Bạn không có quyền xóa câu hỏi bài kiểm tra này" });
      }
    } else {
      return res.status(403).json({ message: "Bạn không có quyền thực hiện hành động này" });
    }

    await Question.findByIdAndDelete(req.params.id);
    res.json({ message: "Xóa question thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
