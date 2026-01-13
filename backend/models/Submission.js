import mongoose from "mongoose";

/* ===== ANSWER SCHEMA ===== */
const answerSchema = new mongoose.Schema(
  {
    question: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Question",
      required: true,
    },

    userAnswer: {
      type: mongoose.Schema.Types.Mixed,
      required: true,
    },

    isCorrect: {
      type: Boolean,
      default: null, // essay => null
    },
    pointsAwarded: {
      type: Number,
      default: 0,
    },
  },
  { _id: false }
);

/* ===== SUBMISSION SCHEMA ===== */
const submissionSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Lesson",
      required: true,
      index: true,
    },

    answers: [answerSchema],

    /* ===== SCORE BY SKILL ===== */
    scores: {
      vocabulary: { type: Number, default: 0 },
      grammar: { type: Number, default: 0 },
      reading: { type: Number, default: 0 },
      listening: { type: Number, default: 0 },
      speaking: { type: Number, default: 0 },
      writing: { type: Number, default: 0 },
    },

    /* ===== TOTAL SCORE ===== */
    totalScore: {
      type: Number,
      default: 0,
    },

    submittedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

export default mongoose.model("Submission", submissionSchema);
