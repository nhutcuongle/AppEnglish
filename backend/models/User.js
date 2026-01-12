// import mongoose from "mongoose";
// const userSchema = new mongoose.Schema(
//   {
//     username: { type: String, required: true },

//     email: { type: String, required: true, unique: true },

//     password: { type: String, required: true },

//     role: {
//       type: String,
//       enum: ["admin", "school", "teacher", "student"],
//       default: "student",
//     },

//     isDisabled: { type: Boolean, default: false },
    
//     class: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: "Class",
//       default: null,
//     },
//   },
//   { timestamps: true }
// );

// export default mongoose.model("User", userSchema);


import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    // Auth
    username: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    // Role
    role: {
      type: String,
      enum: ["admin", "school", "teacher", "student"],
      default: "student",
    },

    isDisabled: {
      type: Boolean,
      default: false,
    },

    // Profile
    fullName: {
      type: String,
      default: "",
      trim: true,
    },

    phone: {
      type: String,
      default: "",
      trim: true,
    },

    gender: {
      type: String,
      enum: ["male", "female", ""],
      default: "",
    },

    dateOfBirth: {
      type: Date,
      default: null,
    },

    // Class relation (chuẩn vì bạn đã có bảng Class)
    class: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Class",
      default: null,
    },
    // Academic Year (for School role)
    academicYear: { type: String, default: "" },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("User", userSchema);
