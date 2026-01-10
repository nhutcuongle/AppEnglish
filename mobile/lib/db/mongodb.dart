import 'package:apptienganh10/models/teacher_models.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Db? db;
  static DbCollection? userCollection;
  static DbCollection? assignmentCollection;
  static DbCollection? submissionCollection;
  static DbCollection? announcementCollection;
  static DbCollection? lessonPlanCollection;

  static Future<void> connect() async {
    db = await Db.create(mongoUrl);
    await db!.open();
    userCollection = db!.collection(userCollectionName);
    assignmentCollection = db!.collection(assignmentCollectionName);
    submissionCollection = db!.collection(submissionCollectionName);
    announcementCollection = db!.collection(announcementCollectionName);
    lessonPlanCollection = db!.collection(lessonPlanCollectionName);
  }

  // --- API / Database Operations ---

  // Thêm bài tập mới
  static Future<void> insertAssignment(Map<String, dynamic> data) async {
    await assignmentCollection?.insert(data);
  }

  // Cập nhật bài tập
  static Future<void> updateAssignment(ObjectId id, Map<String, dynamic> data) async {
    await assignmentCollection?.update(where.id(id), data);
  }

  // Xóa bài tập
  static Future<void> deleteAssignment(ObjectId id) async {
    await assignmentCollection?.remove(where.id(id));
  }

  // Lấy danh sách học sinh theo bản ghi (Student)
  static Future<List<Student>> getStudents() async {
    try {
      final data = await ApiService.getStudents();
      return data.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      print('MongoDatabase (ApiService) Error: $e');
      return [];
    }
  }

  // Lấy danh sách bài tập (Assignment)
  static Future<List<Assignment>> getAssignments({String? type}) async {
    final selector = type != null ? where.eq('type', type) : where;
    final data = await assignmentCollection?.find(selector).toList() ?? [];
    return data.map((e) => Assignment.fromJson(e)).toList();
  }

  // --- Chấm điểm & Nộp bài ---

  // Lấy danh sách bài nộp (Submission)
  static Future<List<Submission>> getSubmissionsByStudent(ObjectId studentId) async {
    final data = await submissionCollection?.find({'studentId': studentId}).toList() ?? [];
    return data.map((e) => Submission.fromJson(e)).toList();
  }

  // --- Thông báo ---

  static Future<void> insertAnnouncement(Map<String, dynamic> data) async {
    await announcementCollection?.insert(data);
  }

  static Future<List<Announcement>> getAnnouncements() async {
    final data = await announcementCollection?.find(where.sortBy('createdAt', descending: true)).toList() ?? [];
    return data.map((e) => Announcement.fromJson(e)).toList();
  }

  static Future<void> updateAnnouncement(ObjectId id, Map<String, dynamic> data) async {
    await announcementCollection?.update(where.id(id), data);
  }

  static Future<void> deleteAnnouncement(ObjectId id) async {
    await announcementCollection?.remove(where.id(id));
  }

  // --- Thống kê nâng cao ---

  static Future<List<Student>> getTopStudents(int count) async {
    final data = await userCollection?.find(where.eq('role', 'student').sortBy('score', descending: true).limit(count)).toList() ?? [];
    return data.map((e) => Student.fromJson(e)).toList();
  }

  // Cập nhật điểm số cho một bài nộp
  static Future<void> gradeSubmission(ObjectId submissionId, double score, String comment) async {
    await submissionCollection?.update(
      where.id(submissionId),
      modify.set('score', score).set('comment', comment).set('gradedAt', DateTime.now().toIso8601String()),
    );
  }

  // --- Giáo án (Lesson Plans) ---

  static Future<void> insertLessonPlan(Map<String, dynamic> data) async {
    await lessonPlanCollection?.insert(data);
  }

  static Future<List<LessonPlan>> getLessonPlans() async {
    final data = await lessonPlanCollection?.find(where.sortBy('createdAt', descending: true)).toList() ?? [];
    return data.map((e) => LessonPlan.fromJson(e)).toList();
  }

  static Future<void> updateLessonPlan(ObjectId id, Map<String, dynamic> data) async {
    await lessonPlanCollection?.update(where.id(id), data);
  }

  static Future<void> deleteLessonPlan(ObjectId id) async {
    await lessonPlanCollection?.remove(where.id(id));
  }

  static Future<List<Map<String, dynamic>>> getSubmissions() async {
    return await db!.collection('submissions').find().toList();
  }
}

// ĐÃ XÓA URL ĐỂ BẢO MẬT. Vui lòng sử dụng ApiService.
const mongoUrl = ""; 
const userCollectionName = "users";
const assignmentCollectionName = "assignments";
const submissionCollectionName = "submissions";
const announcementCollectionName = "announcements";
const lessonPlanCollectionName = "lesson_plans";
