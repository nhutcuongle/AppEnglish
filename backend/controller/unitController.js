import Unit from "../models/Unit.js";

/* ================= SCHOOL / ADMIN ================= */

/* CREATE UNIT */
export const createUnit = async (req, res) => {
  try {
    const unit = await Unit.create({
      ...req.body,
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
      .sort({ createdAt: 1 });

    res.json(units);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* GET UNIT BY ID */
export const getUnitById = async (req, res) => {
  try {
    const unit = await Unit.findById(req.params.id).populate(
      "createdBy",
      "username email"
    );

    if (!unit)
      return res.status(404).json({ message: "Không tìm thấy unit" });

    res.json(unit);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* UPDATE UNIT */
export const updateUnit = async (req, res) => {
  try {
    const unit = await Unit.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );

    if (!unit)
      return res.status(404).json({ message: "Không tìm thấy unit" });

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
    const unit = await Unit.findByIdAndDelete(req.params.id);

    if (!unit)
      return res.status(404).json({ message: "Không tìm thấy unit" });

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
      .sort({ createdAt: 1 });

    res.json(units);
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
      .sort({ createdAt: 1 });

    res.json(units);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
