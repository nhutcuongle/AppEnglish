import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";

import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./config/swagger.js";
import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/user.js";
import teacherRoutes from "./routes/teacher.js";
import unitRoutes from "./routes/unit.js";
import lessonRoutes from "./routes/lesson.js";
import classRoutes from "./routes/class.js";
<<<<<<< HEAD
import vocabularyRoutes from "./routes/vocabulary.js";
import grammarRoutes from "./routes/grammar.js";


=======
import assignmentRoutes from "./routes/assignment.js";
import announcementRoutes from "./routes/announcement.js";
>>>>>>> origin/Update-frontend-teacher

const app = express();

app.use(helmet());
app.use(morgan("dev"));
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
<<<<<<< HEAD
app.use("/api/vocabularies", vocabularyRoutes);
app.use("/api/grammar", grammarRoutes);








=======
app.use("/api/assignments", assignmentRoutes);
app.use("/api/announcements", announcementRoutes);
>>>>>>> origin/Update-frontend-teacher
app.get("/", (req, res) => {
  res.send("API is running...");
});

// Xử lý lỗi tập trung
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    message: err.message || "Lỗi hệ thống",
    error: process.env.NODE_ENV === "development" ? err.stack : {}
  });
});

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;
mongoose.connect(MONGO_URI).then(() => {
  console.log("MongoDB connected");

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
});
