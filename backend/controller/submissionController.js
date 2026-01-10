import Submission from "../models/Submission.js";

export const getSubmissions = async (req, res) => {
  try {
    const { assignmentId, studentId } = req.query;
    const query = {};
    if (assignmentId) query.assignmentId = assignmentId;
    if (studentId) query.studentId = studentId;

    const submissions = await Submission.find(query)
      .populate("studentId", "username fullName email")
      .populate("assignmentId", "title");

    res.status(200).json(submissions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createSubmission = async (req, res) => {
  try {
    const { assignmentId, content } = req.body;
    const studentId = req.user.id; // From authMiddleware

    // Check if exists
    let submission = await Submission.findOne({ assignmentId, studentId });
    if (submission) {
      submission.content = content || submission.content;
      submission.submittedAt = Date.now();
      await submission.save();
    } else {
      submission = await Submission.create({
        assignmentId,
        studentId,
        content,
      });
    }

    res.status(201).json(submission);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const gradeSubmission = async (req, res) => {
  try {
    const { score, comment } = req.body;
    const submission = await Submission.findByIdAndUpdate(
      req.params.id,
      { score, comment, gradedAt: Date.now() },
      { new: true }
    );
    res.status(200).json(submission);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
