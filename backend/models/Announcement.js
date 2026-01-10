import mongoose from "mongoose";

const announcementSchema = new mongoose.Schema(
    {
        title: {
            type: String,
            required: true,
        },
        content: {
            type: String,
            required: true,
        },
        senderId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User", // Can be Teacher or School (User collection generic or specific)
            required: true,
        },
        senderName: {
            type: String,
            required: true,
        },
        targetClassId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Class",
            required: false, // If null -> School wide announcement or specific logic
        },
        type: {
            type: String,
            enum: ["class", "school"],
            default: "class",
        },
    },
    { timestamps: true }
);

export default mongoose.model("Announcement", announcementSchema);
