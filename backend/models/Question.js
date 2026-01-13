import mongoose from "mongoose";

/* ===== MEDIA SCHEMA ===== */
const mediaSchema = new mongoose.Schema(
  {
    url: { type: String, required: true },
    caption: { type: String, default: "" },
    order: { type: Number, default: 0 },
  },
  { _id: false }
);

/* ===== QUESTION SCHEMA ===== */
const questionSchema = new mongoose.Schema(
  {
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Lesson",
      required: false, // Optional if it's an exam
      index: true,
    },
    exam: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Exam",
      required: false,
      index: true,
    },
    class: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Class",
      required: false, // Optional if it's a school-wide question
      index: true,
    },
    school: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // Role School
      required: false,
      index: true,
    },
    skill: {
      type: String,
      enum: ["vocabulary", "grammar", "reading", "listening", "speaking", "writing"],
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: ["mcq", "true_false", "fill_blank", "matching", "essay"],
      required: true,
    },
    content: {
      type: String,
      required: true,
    },
    options: [{ type: String }],
    correctAnswer: {
      type: mongoose.Schema.Types.Mixed,
      default: null,
    },
    explanation: {
      type: String,
      default: "",
    },
    images: [mediaSchema],
    audios: [mediaSchema],
    videos: [mediaSchema], // Thêm lại trường này để đồng bộ với Controller
    order: {
      type: Number,
      default: 1,
    },
    isPublished: {
      type: Boolean,
      default: true,
    },
    points: {
      type: Number,
      default: 1,
    },
  },
  { timestamps: true }
);

export default mongoose.model("Question", questionSchema);