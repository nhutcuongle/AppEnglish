import mongoose from "mongoose";

const classSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true, // Ví dụ: 10A1
      trim: true,
    },

    room: {
      type: String,
      default: "",
      trim: true,
    },

    grade: {

      type: Number,
      required: true, // 10
    },

    school: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true, // role = school
    },

    homeroomTeacher: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // role = teacher
      default: null,
    },

    students: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],

    isActive: {
      type: Boolean,
      default: true,
    },

    schedule: {
      type: [String], // ['Sáng'], ['Chiều'], or ['Sáng', 'Chiều']
      default: ['Sáng'],
    },
  },

  { timestamps: true }
);

export default mongoose.model("Class", classSchema);
