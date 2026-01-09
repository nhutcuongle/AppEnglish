import mongoose from "mongoose";

/* ===== MEDIA SCHEMA ===== */
const mediaSchema = new mongoose.Schema(
  {
    url: {
      type: String,
      required: true,
    },
    caption: {
      type: String,
      default: "",
    },
    order: {
      type: Number,
      default: 0,
    },
  },
  { _id: false }
);

/* ===== LESSON SCHEMA ===== */
const lessonSchema = new mongoose.Schema(
  {
    unit: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Unit",
      required: true,
      index: true,
    },

    lessonType: {
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

    title: {
      type: String,
      required: true,
      trim: true,
    },

    content: {
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

export default mongoose.model("Lesson", lessonSchema);
