import * as lessonService from "../service/lessonService.js";

/* ================= CREATE LESSON ================= */
export const createLesson = async (req, res) => {
  try {
    const lesson = await lessonService.createNewLesson(req.body, req.files);
    res.status(201).json({
      message: "Tạo lesson thành công",
      lesson,
    });
  } catch (err) {
    const statusCode = err.message.includes("Thiếu") || err.message.includes("không hợp lệ") ? 400 : 500;
    res.status(statusCode).json({ error: err.message });
  }
};

/* ================= GET LESSONS BY UNIT ================= */
export const getLessonsByUnit = async (req, res) => {
  try {
    const result = await lessonService.fetchLessonsByUnit(req.params.unitId);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= UPDATE LESSON (PARTIAL) ================= */
export const updateLesson = async (req, res) => {
  try {
    const lesson = await lessonService.updateExistingLesson(req.params.id, req.body, req.files);
    res.json({
      message: "Cập nhật lesson thành công",
      lesson,
    });
  } catch (err) {
    const statusCode = err.message.includes("Không tìm thấy") ? 404 : 500;
    res.status(statusCode).json({ error: err.message });
  }
};
res.json({
  message: "Cập nhật lesson thành công",
  lesson,
});
  } catch (err) {
  const statusCode = err.message.includes("Không tìm thấy") ? 404 : 500;
  res.status(statusCode).json({ error: err.message });
}
};

/* ================= DELETE LESSON ================= */
export const deleteLesson = async (req, res) => {
  try {
    await lessonService.removeLesson(req.params.id);
    res.json({ message: "Xóa lesson thành công" });
  } catch (err) {
    const statusCode = err.message.includes("Không tìm thấy") ? 404 : 500;
    res.status(statusCode).json({ error: err.message });
  }
};