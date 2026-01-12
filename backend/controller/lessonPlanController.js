import LessonPlan from "../models/LessonPlan.js";

/* CREATE */
export const createLessonPlan = async (req, res) => {
    try {
        const { title, unit, topic, objectives, content, resources, teacherId } = req.body;

        const newPlan = await LessonPlan.create({
            title,
            unit,
            topic,
            objectives,
            content,
            resources,
            teacherId, // In real app, get from req.user.id
        });

        res.status(201).json(newPlan);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

/* GET ALL (Filter by Teacher) */
export const getLessonPlans = async (req, res) => {
    try {
        const { teacherId } = req.query;
        const query = teacherId ? { teacherId } : {};

        const plans = await LessonPlan.find(query).sort({ createdAt: -1 });
        res.status(200).json(plans);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

/* UPDATE */
export const updateLessonPlan = async (req, res) => {
    try {
        const updatedPlan = await LessonPlan.findByIdAndUpdate(
            req.params.id,
            { $set: req.body },
            { new: true }
        );
        res.status(200).json(updatedPlan);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

/* DELETE */
export const deleteLessonPlan = async (req, res) => {
    try {
        await LessonPlan.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: "Lesson Plan deleted" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
