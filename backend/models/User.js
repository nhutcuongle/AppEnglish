import mongoose from "mongoose";
const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true },

    // Email is optional and sparse (only unique when provided)
    email: { type: String, sparse: true },

    password: { type: String, required: true },

    role: {
      type: String,
      enum: ["admin", "school", "teacher", "student"],
      default: "student",
    },

    isDisabled: { type: Boolean, default: false },

    // Full name for display
    fullName: { type: String, default: "" },

    // Phone number
    phone: { type: String, default: "" },

    // Gender: male, female
    gender: { type: String, enum: ["male", "female", ""], default: "" },

    // Date of birth
    dateOfBirth: { type: Date, default: null },

    // Classes array (for teachers - multiple classes, for students - their class names)
    classes: [{ type: String }],

    // Legacy: Single class reference (keeping for backward compatibility)
    class: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Class",
      default: null,
    },
    // Academic Year (for School role)
    academicYear: { type: String, default: "" },
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);

