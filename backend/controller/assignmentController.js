import Assignment from "../models/Assignment.js";
import Class from "../models/Class.js";

/* ================= CREATE OR UPDATE ASSIGNMENT ================= */
export const createOrUpdateAssignment = async (req, res) => {
    try {
        const { lessonId, classId, deadline, description, isPublished } = req.body;

        if (!lessonId) {
            return res.status(400).json({ message: "Thiếu lessonId" });
        }

        let targetClassId = classId;

        /* Nếu không truyền classId, tìm lớp mà giáo viên này làm chủ nhiệm */
        if (!targetClassId) {
            const teacherClass = await Class.findOne({
                homeroomTeacher: req.user._id,
                isActive: true,
            });

            if (!teacherClass) {
                return res.status(403).json({
                    message: "Bạn không phải giáo viên chủ nhiệm lớp nào và không cung cấp classId",
                });
            }
            targetClassId = teacherClass._id;
        }

        /* Upsert Assignment */
        const assignment = await Assignment.findOneAndUpdate(
            { class: targetClassId, lesson: lessonId },
            {
                deadline: deadline !== undefined ? deadline : null,
                description: description || "",
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
            // Ưu tiên tìm theo query classId nếu có, nếu không tìm lớp chủ nhiệm
            classId = req.query.classId;
            if (!classId) {
                const teacherClass = await Class.findOne({
                    homeroomTeacher: req.user._id,
                    isActive: true,
                });
                if (teacherClass) {
                    classId = teacherClass._id;
                }
            }
        }

        if (!classId) {
            return res.status(400).json({ message: "Thiếu classId" });
        }

        const assignment = await Assignment.findOne({ class: classId, lesson: lessonId });

        res.json({
            data: assignment || null,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
