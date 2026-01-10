import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();
import cors from "cors";

import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./config/swagger.js";
import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/user.js";
import teacherRoutes from "./routes/teacher.js";
import unitRoutes from "./routes/unit.js";
import lessonRoutes from "./routes/lesson.js";
import classRoutes from "./routes/class.js";
import lessonPlanRoutes from "./routes/lessonPlan.js";
import vocabularyRoutes from "./routes/vocabulary.js";
import grammarRoutes from "./routes/grammar.js";
import questionRoutes from "./routes/question.js";
import submissionRoutes from "./routes/submission.js";

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/swagger", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/teachers", teacherRoutes);
app.use("/api/units", unitRoutes);
app.use("/api/lessons", lessonRoutes);
app.use("/api/classes", classRoutes);
app.use("/api/lesson-plans", lessonPlanRoutes);
app.use("/api/vocabularies", vocabularyRoutes);
app.use("/api/grammar", grammarRoutes);
app.use("/api/questions", questionRoutes);
app.use("/api/submissions", submissionRoutes);

app.get("/", (req, res) => {
  res.send("API is running...");
});

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;
mongoose.connect(MONGO_URI).then(() => {
  console.log("MongoDB connected");

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
});