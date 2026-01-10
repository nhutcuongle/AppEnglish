import mongoose from "mongoose";

const lessonPlanSchema = new mongoose.Schema(
    {
        title: {
            type: String,
            required: true,
        },
        unit: {
            type: String,
            required: true,
        },
        topic: {
            type: String,
            required: true,
        },
        objectives: {
            type: String,
            required: true,
        },
        content: {
            type: String,
            required: true,
        },
        resources: {
            type: [String],
            default: [],
        },
        teacherId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User", // or "Teacher" if you have separate collection
            required: true,
        },
    },
    { timestamps: true }
);

export default mongoose.model("LessonPlan", lessonPlanSchema);
