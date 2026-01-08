import Unit from "../models/Unit.js";
import { cloudinary } from "../config/cloudinary.js";
import { getPublicIdFromUrl } from "../utils/cloudinaryHelper.js";

/* ================= SCHOOL / ADMIN ================= */

/* CREATE UNIT */
export const createUnit = async (req, res) => {
  try {
    const { title, description, isPublished, order } = req.body;

    if (!title) {
      return res.status(400).json({ message: "Title là bắt buộc" });
    }

    const image = req.file ? req.file.path : null;

    const unit = await Unit.create({
      title,
      description,
      image,
      isPublished,
      order,
      createdBy: req.user.id,
    });

    res.status(201).json({
      message: "Tạo unit thành công",
      unit,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* GET ALL UNITS (SCHOOL / ADMIN) */
export const getAllUnitsForSchool = async (req, res) => {
  try {
    const units = await Unit.find()
      .select("-__v")
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: units.length,
      data: units,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* GET UNIT BY ID */
export const getUnitById = async (req, res) => {
  try {
    const unit = await Unit.findById(req.params.id)
      .populate("createdBy", "username email")
      .lean();

    if (!unit) {
      return res.status(404).json({ message: "Không tìm thấy unit" });
    }

    res.json(unit);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* UPDATE UNIT */
export const updateUnit = async (req, res) => {
  try {
    const allowedFields = ["title", "description", "isPublished", "order"];

    const updateData = {};
    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    // 👇 thêm đoạn này
    if (req.file) {
      updateData.image = req.file.path;
    }

    const unit = await Unit.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
    });

    if (!unit) {
      return res.status(404).json({ message: "Không tìm thấy unit" });
    }

    res.json({
      message: "Cập nhật unit thành công",
      unit,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* DELETE UNIT */
export const deleteUnit = async (req, res) => {
  try {
    const unit = await Unit.findById(req.params.id);

    if (!unit) {
      return res.status(404).json({ message: "Không tìm thấy unit" });
    }

    // 🔥 XÓA ẢNH TRÊN CLOUDINARY NẾU CÓ
    if (unit.image) {
      const publicId = getPublicIdFromUrl(unit.image);
      await cloudinary.uploader.destroy(`lms/units/${publicId}`);
    }

    await unit.deleteOne();

    res.json({ message: "Xóa unit thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


/* ================= TEACHER ================= */

/* GET ALL UNITS (TEACHER) */
export const getAllUnitsForTeacher = async (req, res) => {
  try {
    const units = await Unit.find()
      .select("-__v")
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: units.length,
      data: units,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ================= STUDENT ================= */

/* GET PUBLISHED UNITS (STUDENT) */
export const getPublishedUnits = async (req, res) => {
  try {
    const units = await Unit.find({ isPublished: true })
      .select("-__v")
      .sort({ order: 1, createdAt: 1 })
      .lean();

    res.json({
      total: units.length,
      data: units,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
export const getPublishedUnitById = async (req, res) => {
  try {
    const unit = await Unit.findOne({
      _id: req.params.id,
      isPublished: true,
    })
      .select("-__v")
      .lean();

    if (!unit) {
      return res.status(404).json({ message: "Không tìm thấy unit" });
    }

    res.json(unit);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
