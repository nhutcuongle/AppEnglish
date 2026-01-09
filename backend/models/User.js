
import mongoose from "mongoose";
const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true },

    email: { type: String, required: true, unique: true },

    password: { type: String, required: true },

    role: {
      type: String,
      enum: ["admin", "school", "teacher", "student"],
      default: "student",
    },

    isDisabled: { type: Boolean, default: false },

    phone: { type: String, default: "" },

    classes: { type: [String], default: [] },

    fullName: { type: String, default: "" },
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);
