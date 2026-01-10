import mongoose from "mongoose";

const assignmentSchema = new mongoose.Schema(
    {
        title: {
            type: String,
            required: true,
        },
        description: {
            type: String,
            required: true,
        },
        deadline: {
            type: Date,
            required: true,
        },
        classId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Class",
            required: true,
        },
        teacherId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Teacher",
            required: true,
        },
        type: {
            type: String,
            enum: ["homework", "essay", "quiz"],
            default: "homework",
        },
    },
    { timestamps: true }
);

export default mongoose.model("Assignment", assignmentSchema);
