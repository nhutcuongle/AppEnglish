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
      required: true,
      index: true,
    },
    
class: {
  type: mongoose.Schema.Types.ObjectId,
  ref: "Class",
  required: true,
  index: true,
},

    /* Skill của câu hỏi (đồng bộ lessonType) */
    skill: {
      type: String,
      enum: [
        "vocabulary",
        "grammar",
        "reading",
        "listening",
        "speaking",
        "writing",
      ],
      required: true,
      index: true,
    },

    /* Loại câu hỏi */
    type: {
      type: String,
      enum: [
        "mcq",          // trắc nghiệm
        "true_false",   // đúng / sai
        "fill_blank",   // điền từ
        "matching",     // nối
        "essay",        // tự luận (speaking / writing)
      ],
      required: true,
    },

    /* Nội dung câu hỏi (HTML / Rich Text) */
    content: {
      type: String,
      required: true,
    },

    /* Lựa chọn (MCQ, matching) */
    options: [
      {
        type: String,
      },
    ],

    /* Đáp án đúng */
    correctAnswer: {
      type: mongoose.Schema.Types.Mixed,
      default: null,
      /*
        mcq        -> number (index)
        true_false -> boolean
        fill_blank -> string
        matching   -> object
        essay      -> null
      */
    },

    /* Giải thích đáp án */
    explanation: {
      type: String,
      default: "",
    },

    images: [mediaSchema],
    audios: [mediaSchema],

    order: {
      type: Number,
      default: 1,
    },

    isPublished: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

export default mongoose.model("Question", questionSchema);
