import Assignment from "../models/Assignment.js";

// Tạo bài tập mới
export const createAssignment = async (req, res) => {
    try {
        const { title, description, deadline, classId, type } = req.body;

        // Auth middleware ensures req.user exists. 
        // Assuming teacher creates assignment.
        const teacherId = req.user._id;

        // Basic validation
        if (!title || !description || !deadline || !classId) {
            return res.status(400).json({ message: "Vui lòng nhập đủ thông tin" });
        }

        const newAssignment = new Assignment({
            title,
            description,
            deadline,
            classId,
            teacherId,
            type: type || "homework",
        });

        await newAssignment.save();
        res.status(201).json(newAssignment);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

// Lấy danh sách bài tập (có thể lọc theo classId)
export const getAssignments = async (req, res) => {
    try {
        const { classId } = req.query;
        const filter = {};
        if (classId) filter.classId = classId;

        const assignments = await Assignment.find(filter).sort({ createdAt: -1 });
        res.status(200).json(assignments);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

// Lấy chi tiết bài tập
export const getAssignmentById = async (req, res) => {
    try {
        const assignment = await Assignment.findById(req.params.id);
        if (!assignment) {
            return res.status(404).json({ message: "Không tìm thấy bài tập" });
        }
        res.status(200).json(assignment);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

// Cập nhật bài tập
export const updateAssignment = async (req, res) => {
    try {
        const updatedAssignment = await Assignment.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true }
        );
        if (!updatedAssignment) {
            return res.status(404).json({ message: "Không tìm thấy bài tập" });
        }
        res.status(200).json(updatedAssignment);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

// Xóa bài tập
export const deleteAssignment = async (req, res) => {
    try {
        const deletedAssignment = await Assignment.findByIdAndDelete(req.params.id);
        if (!deletedAssignment) {
            return res.status(404).json({ message: "Không tìm thấy bài tập" });
        }
        res.status(200).json({ message: "Xóa thành công" });
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};
