// import Class from "../models/Class.js";
// import User from "../models/User.js";

// /**
//  * SCHOOL: CREATE CLASS
//  */
// export const createNewClass = async (schoolId, classData) => {
//   const { name, grade, homeroomTeacher } = classData;

//   // 1. Validate dữ liệu cơ bản
//   if (!name || !grade) {
//     throw new Error("Tên lớp và khối là bắt buộc");
//   }

//   // 2. Kiểm tra trùng lớp trong cùng school
//   const existedClass = await Class.findOne({
//     name,
//     grade,
//     school: schoolId,
//   });

//   if (existedClass) {
//     throw new Error("Lớp đã tồn tại trong hệ thống");
//   }

//   // 3. Tạo lớp
//   const newClass = await Class.create({
//     name,
//     grade,
//     school: schoolId,
//     homeroomTeacher: homeroomTeacher || null,
//   });

//   return newClass;
// };

// /**
//  * SCHOOL: ASSIGN TEACHER
//  */
// export const assignTeacher = async (classId, teacherId) => {
//   const updatedClass = await Class.findByIdAndUpdate(
//     classId,
//     { homeroomTeacher: teacherId },
//     { new: true }
//   ).populate("homeroomTeacher", "username email");

//   if (!updatedClass) throw new Error("Không tìm thấy lớp");
  
//   return updatedClass;
// };

// /**
//  * SCHOOL: GET ALL CLASSES
//  */
// export const fetchAllClasses = async (schoolId) => {
//   const classes = await Class.find({ school: schoolId })
//     .populate("homeroomTeacher", "username email fullName")
//     .sort({ grade: 1, name: 1 });

//   // Count students for each class
//   const classesWithCounts = await Promise.all(
//     classes.map(async (classDoc) => {
//       const studentCount = await User.countDocuments({
//         role: "student",
//         class: classDoc._id, // Ưu tiên query theo ID cho chính xác
//       });

//       // Nếu không tìm thấy theo ID, thử tìm theo name như logic cũ (nếu app cũ lưu theo name)
//       if (studentCount === 0) {
//         const studentCountByName = await User.countDocuments({
//           role: "student",
//           class: classDoc.name,
//         });
//         return {
//           ...classDoc.toObject(),
//           studentCount: studentCountByName,
//         };
//       }

//       return {
//         ...classDoc.toObject(),
//         studentCount,
//       };
//     })
//   );

//   return classesWithCounts;
// };

// /**
//  * SCHOOL: UPDATE CLASS
//  */
// export const updateExistingClass = async (classId, schoolId, updateFields) => {
//   const { name, grade, homeroomTeacher, schedule, room } = updateFields;

//   // Kiểm tra trùng lớp (nếu có đổi tên/khối)
//   if (name || grade) {
//     const duplicatedClass = await Class.findOne({
//       _id: { $ne: classId },
//       name: name || undefined,
//       grade: grade || undefined,
//       school: schoolId,
//     });

//     if (duplicatedClass) {
//       throw new Error("Lớp đã tồn tại trong hệ thống");
//     }
//   }

//   const updateData = {};
//   if (name !== undefined) updateData.name = name;
//   if (grade !== undefined) updateData.grade = grade;
//   if (homeroomTeacher !== undefined) updateData.homeroomTeacher = homeroomTeacher;
//   if (schedule !== undefined) updateData.schedule = schedule;
//   if (room !== undefined) updateData.room = room;

//   const updatedClass = await Class.findOneAndUpdate(
//     { _id: classId, school: schoolId },
//     updateData,
//     { new: true }
//   ).populate("homeroomTeacher", "username email");

//   if (!updatedClass) throw new Error("Không tìm thấy lớp");

//   return updatedClass;
// };

// /**
//  * SCHOOL: DELETE CLASS
//  */
// export const removeIdClass = async (classId, schoolId) => {
//   const classData = await Class.findOne({
//     _id: classId,
//     school: schoolId,
//   });

//   if (!classData) throw new Error("Không tìm thấy lớp");

//   // Gỡ lớp khỏi học sinh
//   await User.updateMany(
//     { class: classData._id },
//     { $set: { class: null } }
//   );

//   await classData.deleteOne();
//   return true;
// };

// /**
//  * SCHOOL: GET CLASS DETAIL
//  */
// export const fetchClassDetails = async (classId, schoolId) => {
//   const classData = await Class.findOne({
//     _id: classId,
//     school: schoolId,
//   })
//     .populate("homeroomTeacher", "username email")
//     .populate("students", "username email");

//   if (!classData) throw new Error("Không tìm thấy lớp");

//   return classData;
// };

// /**
//  * TEACHER: GET MY CLASSES
//  */
// export const fetchTeacherClasses = async (teacherId) => {
//   const classes = await Class.find({ 
//     homeroomTeacher: teacherId,
//     isActive: true 
//   })
//   .populate("school", "username fullName")
//   .sort({ grade: 1, name: 1 });

//   const classesWithCounts = await Promise.all(
//     classes.map(async (classDoc) => {
//       const studentCount = await User.countDocuments({
//         role: "student",
//         class: classDoc._id,
//       });

//       return {
//         ...classDoc.toObject(),
//         studentCount,
//       };
//     })
//   );

//   return classesWithCounts;
// };
