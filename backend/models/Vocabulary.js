import mongoose from "mongoose";

/* ===== MEDIA SCHEMA (reuse) ===== */
const mediaSchema = new mongoose.Schema(
  {
    url: { type: String, required: true },
    caption: { type: String, default: "" },
    order: { type: Number, default: 0 },
  },
  { _id: false }
);

/* ===== VOCABULARY SCHEMA ===== */
const vocabularySchema = new mongoose.Schema(
  {
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Lesson",
      required: true,
      index: true,
    },

    word: {
      type: String,
      required: true,
      trim: true,
    },

    phonetic: {
      type: String,
      default: "",
    },

    meaning: {
      type: String,
      required: true,
    },

    example: {
      type: String,
      default: "",
    },

    images: [mediaSchema],
    audios: [mediaSchema],
    videos: [mediaSchema],

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

export default mongoose.model("Vocabulary", vocabularySchema);
