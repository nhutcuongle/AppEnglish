import Question from "../models/Question.js";
import Lesson from "../models/Lesson.js";
import Class from "../models/Class.js";
import Exam from "../models/Exam.js";
import { processMedia } from "../utils/mediaHelper.js";

/**
/**
 * CREATE QUESTION (SCHOOL ONLY - FOR LESSONS)
 */
export const createNewQuestion = async (user, body, files) => {
  if (user.role !== "school") {
    throw new Error("Chỉ nhà trường mới có quyền sử dụng đầu API này");
  }

  const { lessonId, deadline, classId } = body;

  /* ===== BULK CREATE LOGIC ===== */
  let questionsData = null;
  if (Array.isArray(body)) {
    questionsData = body;
  } else if (body.questions && Array.isArray(body.questions)) {
    questionsData = body.questions;
  }

  if (questionsData) {
    if (questionsData.length === 0) throw new Error("Danh sách câu hỏi trống");

    const targetLesson = body.lessonId || questionsData[0].lessonId;
    if (!targetLesson) throw new Error("Thiếu lessonId cho tất cả câu hỏi");

    const lastQuestion = await Question.findOne({
      lesson: targetLesson,
      school: user._id,
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
        class: qClassId || body.classId || null,
        school: user._id,
        order: currentOrder++,
        images: images || [],
        audios: audios || [],
        videos: videos || []
      });
      createdQuestions.push(newQuestion);
    }
    return { count: createdQuestions.length, data: createdQuestions };
  }

  /* ===== SINGLE CREATE LOGIC ===== */
  const { skill, type, content, isPublished, points, options, correctAnswer, explanation } = body;
  if (!lessonId || !skill || !type || !content) {
    throw new Error("Thiếu lessonId, skill, type hoặc content");
  }

  const lessonData = await Lesson.findById(lessonId);
  if (!lessonData) throw new Error("Lesson không tồn tại");

  if (deadline && user.role === "school") {
    await Lesson.findByIdAndUpdate(lessonId, { deadline });
  }

  const lastQuestion = await Question.findOne({
    lesson: lessonId,
    school: user._id
  }).sort({ order: -1 }).select("order");

  const nextOrder = lastQuestion ? lastQuestion.order + 1 : 1;
  const media = processMedia(files, body);

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
    school: user._id,
  });

  return question;
};

/**
 * CREATE QUESTION FOR TEACHER (EXAM ONLY)
 */
export const createNewQuestionForTeacher = async (user, body, files) => {
  if (user.role !== "teacher") {
    throw new Error("Chỉ giảng viên mới có quyền sử dụng đầu API này");
  }

  const { examId } = body;

  /* ===== BULK CREATE ===== */
  let questionsData = null;
  if (Array.isArray(body)) {
    questionsData = body;
  } else if (body.questions && Array.isArray(body.questions)) {
    questionsData = body.questions;
  }

  const targetExamId = examId || (questionsData && questionsData[0]?.examId);
  if (!targetExamId) throw new Error("Thiếu examId");

  const exam = await Exam.findById(targetExamId);
  if (!exam || exam.teacher.toString() !== user._id.toString()) {
    throw new Error("Bạn không có quyền quản lý bài kiểm tra này");
  }

  if (questionsData) {
    if (questionsData.length === 0) throw new Error("Danh sách câu hỏi trống");

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
    return { count: createdQuestions.length, data: createdQuestions };
  }

  /* ===== SINGLE CREATE ===== */
  const { skill, type, content, options, correctAnswer, explanation, isPublished, points } = body;
  if (!skill || !type || !content) {
    throw new Error("Thiếu skill, type hoặc content");
  }

  const lastQuestion = await Question.findOne({ exam: targetExamId }).sort({ order: -1 }).select("order");
  const nextOrder = lastQuestion ? lastQuestion.order + 1 : 1;
  const media = processMedia(files, body);

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

  return question;
};

/**
 * GET QUESTIONS BY LESSON
 */
export const fetchQuestionsByLesson = async (lessonId, user) => {
  let query = { lesson: lessonId };

  if (user.role === "student") {
    if (!user.class) throw new Error("Học sinh chưa được xếp lớp");
    const classId = user.class;
    const targetClass = await Class.findById(classId).select("school");
    const schoolId = targetClass ? targetClass.school : null;

    query = {
      lesson: lessonId,
      $or: [
        { class: classId },
        { class: null, school: schoolId }
      ],
      isPublished: true,
    };
  } else if (user.role === "teacher") {
    // Teacher access logic
    const teacherClass = await Class.findOne({ homeroomTeacher: user._id, isActive: true });
    if (!teacherClass) throw new Error("Bạn không phải giáo viên chủ nhiệm lớp nào");
    const classId = teacherClass._id;
    const schoolId = teacherClass.school;

    query = {
      lesson: lessonId,
      $or: [
        { class: classId },
        { class: null, school: schoolId }
      ],
      isPublished: true,
    };
  } else if (user.role === "school") {
    query = { lesson: lessonId, school: user._id };
  }

  const questions = await Question.find(query).sort({ order: 1, createdAt: 1 }).lean();
  const lesson = await Lesson.findById(lessonId).select("deadline").lean();

  return {
    total: questions.length,
    data: questions,
    deadline: lesson?.deadline || null,
  };
};

/**
 * UPDATE QUESTION
 */
export const updateExistingQuestion = async (questionId, user, body, files) => {
  const question = await Question.findById(questionId);
  if (!question) throw new Error("Question không tồn tại");

  // Permission Check
  if (user.role === "school") {
    const targetClass = question.class ? await Class.findById(question.class) : null;
    const isOwner = (targetClass && targetClass.school.toString() === user._id.toString()) ||
      (!question.class && question.school && question.school.toString() === user._id.toString());
    if (!isOwner) throw new Error("Question không thuộc quản lý của trường bạn");
  } else if (user.role === "teacher") {
    if (!question.exam) throw new Error("Giáo viên chỉ được sửa câu hỏi trong bài kiểm tra");
    const exam = await Exam.findById(question.exam);
    if (!exam || exam.teacher.toString() !== user._id.toString()) {
      throw new Error("Bạn không có quyền sửa câu hỏi bài kiểm tra này");
    }
  } else {
    throw new Error("Bạn không có quyền thực hiện hành động này");
  }

  const allowedFields = ["content", "options", "correctAnswer", "explanation", "order", "isPublished", "images", "audios", "videos", "points"];
  allowedFields.forEach((field) => {
    if (body[field] !== undefined) question[field] = body[field];
  });

  /* ===== PROCESS MEDIA ===== */
  const media = processMedia(files, body);
  if (media.images) question.images = media.images;
  if (media.audios) question.audios = media.audios;
  if (media.videos) question.videos = media.videos;

  if (body.deadline !== undefined && question.lesson && user.role === "school") {
    await Lesson.findByIdAndUpdate(question.lesson, { deadline: body.deadline });
  }

  await question.save();
  return question;
};

/**
 * DELETE QUESTION
 */
export const removeQuestion = async (questionId, user) => {
  const question = await Question.findById(questionId);
  if (!question) throw new Error("Question không tồn tại");

  // Permission Check
  if (user.role === "school") {
    const targetClass = question.class ? await Class.findById(question.class) : null;
    const isOwner = (targetClass && targetClass.school.toString() === user._id.toString()) ||
      (!question.class && question.school && question.school.toString() === user._id.toString());
    if (!isOwner) throw new Error("Question không thuộc quản lý của trường bạn");
  } else if (user.role === "teacher") {
    if (!question.exam) throw new Error("Giáo viên chỉ được xóa câu hỏi trong bài kiểm tra");
    const exam = await Exam.findById(question.exam);
    if (!exam || exam.teacher.toString() !== user._id.toString()) {
      throw new Error("Bạn không có quyền xóa câu hỏi bài kiểm tra này");
    }
  } else {
    throw new Error("Bạn không có quyền thực hiện hành động này");
  }

  await Question.findByIdAndDelete(questionId);
  return true;
};
