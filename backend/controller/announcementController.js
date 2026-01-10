import Announcement from "../models/Announcement.js";

// Tạo thông báo mới
export const createAnnouncement = async (req, res) => {
    try {
        const { title, content, targetClassId, type } = req.body;

        const senderId = req.user._id;
        const senderName = req.user.username || "Admin"; // Fallback name

        if (!title || !content) {
            return res.status(400).json({ message: "Vui lòng nhập tiêu đề và nội dung" });
        }

        const newAnnouncement = new Announcement({
            title,
            content,
            senderId,
            senderName,
            targetClassId,
            type: type || "class",
        });

        await newAnnouncement.save();
        res.status(201).json(newAnnouncement);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

// Lấy danh sách thông báo
export const getAnnouncements = async (req, res) => {
    try {
        const { classId, type } = req.query;
        const filter = {};

        // Nếu có classId, lấy thông báo của lớp đó HOẶC thông báo chung (school)
        if (classId) {
            filter.$or = [
                { targetClassId: classId },
                { type: 'school' }
            ];
        } else if (type) {
            filter.type = type;
        }

        const announcements = await Announcement.find(filter).sort({ createdAt: -1 });
        res.status(200).json(announcements);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

// Cập nhật thông báo
export const updateAnnouncement = async (req, res) => {
    try {
        const updatedAnnouncement = await Announcement.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true }
        );
        if (!updatedAnnouncement) {
            return res.status(404).json({ message: "Không tìm thấy thông báo" });
        }
        res.status(200).json(updatedAnnouncement);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

// Xóa thông báo
export const deleteAnnouncement = async (req, res) => {
    try {
        const deletedAnnouncement = await Announcement.findByIdAndDelete(req.params.id);
        if (!deletedAnnouncement) {
            return res.status(404).json({ message: "Không tìm thấy thông báo" });
        }
        res.status(200).json({ message: "Xóa thành công" });
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};
