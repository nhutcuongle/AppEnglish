import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();

async function dropEmailIndex() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("Connected to MongoDB");

        // List all indexes first
        const indexes = await mongoose.connection.db.collection("users").indexes();
        console.log("Current indexes:", JSON.stringify(indexes, null, 2));

        // Drop email_1 index
        try {
            const result = await mongoose.connection.db.collection("users").dropIndex("email_1");
            console.log("Successfully dropped email_1 index:", result);
        } catch (dropError) {
            console.log("Error dropping index:", dropError.message);
        }

        // List indexes again to confirm
        const newIndexes = await mongoose.connection.db.collection("users").indexes();
        console.log("Indexes after drop:", JSON.stringify(newIndexes, null, 2));

    } catch (e) {
        console.log("Connection error:", e.message);
    } finally {
        await mongoose.disconnect();
        console.log("Done");
        process.exit(0);
    }
}

dropEmailIndex();
