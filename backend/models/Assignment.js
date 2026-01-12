import mongoose from "mongoose";

const assignmentSchema = new mongoose.Schema(
  {
    class: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Class",
      required: true,
      index: true,
    },
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Lesson",
      required: true,
      index: true,
    },
    deadline: {
      type: Date,
      default: null,
    },
    isPublished: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

// Ràng buộc duy nhất: Một lớp chỉ có một thiết lập cho một bài học cụ thể
assignmentSchema.index({ class: 1, lesson: 1 }, { unique: true });

export default mongoose.model("Assignment", assignmentSchema);
