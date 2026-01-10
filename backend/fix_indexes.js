import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();

async function fixIndexes() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("Connected to MongoDB");

        const collection = mongoose.connection.db.collection("users");

        // Drop old email_1 index if exists
        try {
            await collection.dropIndex("email_1");
            console.log("Dropped old email_1 index");
        } catch (e) {
            console.log("No old email_1 index to drop:", e.message);
        }

        // Create new sparse unique index for email
        try {
            await collection.createIndex(
                { email: 1 },
                { unique: true, sparse: true, name: "email_1_sparse" }
            );
            console.log("Created new sparse email index");
        } catch (e) {
            console.log("Error creating sparse index:", e.message);
        }

        // Update existing users with empty email to null (so sparse index ignores them)
        const result = await collection.updateMany(
            { email: "" },
            { $set: { email: null } }
        );
        console.log("Updated empty emails to null:", result.modifiedCount, "documents");

        // List final indexes
        const indexes = await collection.indexes();
        console.log("Final indexes:", JSON.stringify(indexes, null, 2));

    } catch (e) {
        console.log("Error:", e.message);
    } finally {
        await mongoose.disconnect();
        console.log("Done");
        process.exit(0);
    }
}

fixIndexes();
