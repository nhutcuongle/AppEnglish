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

/* ===== GRAMMAR SCHEMA ===== */
const grammarSchema = new mongoose.Schema(
  {
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Lesson",
      required: true,
      index: true,
    },

    title: {
      type: String,
      required: true,
      trim: true,
    },

    theory: {
      type: String, // HTML / rich text
      required: true,
    },

    examples: [
      {
        type: String,
      },
    ],

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

export default mongoose.model("Grammar", grammarSchema);
