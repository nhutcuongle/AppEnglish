import * as questionService from "../service/questionService.js";

/* ================= CREATE QUESTION (SCHOOL ONLY - FOR LESSONS) ================= */
export const createQuestion = async (req, res) => {
  try {
    const result = await questionService.createNewQuestion(req.user, req.body, req.files);
    
    if (result.count) {
      return res.status(201).json({
        message: `Đã tạo ${result.count} câu hỏi cho bài học`,
        data: result.data
      });
    }

    res.status(201).json({ message: "Tạo câu hỏi bài học thành công", question: result });
  } catch (err) {
    const statusCode = err.message.includes("quyền") ? 403 : 
                      err.message.includes("Thiếu") || err.message.includes("trống") || err.message.includes("không tồn tại") ? 400 : 500;
    res.status(statusCode).json({ error: err.message });
  }
};

/* ================= CREATE QUESTION FOR TEACHER (EXAM ONLY) ================= */
export const createQuestionForTeacher = async (req, res) => {
  try {
    const result = await questionService.createNewQuestionForTeacher(req.user, req.body, req.files);

    if (result.count) {
      return res.status(201).json({
        message: `Đã tạo ${result.count} câu hỏi cho bài kiểm tra`,
        data: result.data
      });
    }

    res.status(201).json({ message: "Tạo câu hỏi bài kiểm tra thành công", question: result });
  } catch (err) {
    const statusCode = err.message.includes("quyền") ? 403 : 
                      err.message.includes("Thiếu") || err.message.includes("trống") ? 400 : 500;
    res.status(statusCode).json({ error: err.message });
  }
};

/* ================= GET QUESTIONS BY LESSON ================= */
export const getQuestionsByLesson = async (req, res) => {
  try {
    const result = await questionService.fetchQuestionsByLesson(req.params.lessonId, req.user);
    res.json(result);
  } catch (err) {
    const statusCode = err.message.includes("chưa được xếp lớp") || err.message.includes("không phải giáo viên") ? 403 : 500;
    res.status(statusCode).json({ error: err.message });
  }
};

/* ================= UPDATE QUESTION ================= */
export const updateQuestion = async (req, res) => {
  try {
    const question = await questionService.updateExistingQuestion(req.params.id, req.user, req.body, req.files);
    res.json({ message: "Cập nhật question thành công", question });
  } catch (err) {
    const statusCode = err.message.includes("Không tồn tại") ? 404 : 
                      err.message.includes("quyền") ? 403 : 500;
    res.status(statusCode).json({ error: err.message });
  }
};

/* ================= DELETE QUESTION ================= */
export const deleteQuestion = async (req, res) => {
  try {
    await questionService.removeQuestion(req.params.id, req.user);
    res.json({ message: "Xóa question thành công" });
  } catch (err) {
    const statusCode = err.message.includes("Không tồn tại") ? 404 : 
                      err.message.includes("quyền") ? 403 : 500;
    res.status(statusCode).json({ error: err.message });
  }
};
