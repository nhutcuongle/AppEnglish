import mongoose from "mongoose";
import dotenv from "dotenv";
import bcrypt from "bcryptjs";
import User from "./models/User.js";

dotenv.config();

/**
 * Hàm khởi tạo tài khoản School mặc định nếu chưa tồn tại.
 * Được gọi tự động khi server start.
 */
export const initSchoolAccount = async () => {
  try {
    const existingSchool = await User.findOne({ role: "school" });

    if (existingSchool) {
      console.log("ℹ️ [System] Tài khoản School đã tồn tại.");
      return;
    }

    console.log("🚀 [System] Không tìm thấy tài khoản School. Đang tự động khởi tạo...");
    
    // Ưu tiên mật khẩu từ biến môi trường, nếu không có dùng mặc định
    const defaultPassword = process.env.ADMIN_PASSWORD || "admin123";
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(defaultPassword, salt);

    await User.create({
      username: "admin_school",
      email: process.env.ADMIN_EMAIL || "admin@school.edu.vn",
      password: hashedPassword,
      role: "school",
      fullName: "Ban Giám Hiệu - Trường Anh Ngữ",
      phoneNumber: "0123456789",
      address: "TP. Hồ Chí Minh",
      academicYear: "2023-2024"
    });

    console.log("✅ [System] Khởi tạo tài khoản School (Admin) thành công!");
    console.log("   Username: admin_school");
    console.log("   Mật khẩu: " + (process.env.ADMIN_PASSWORD ? "******** (từ .env)" : "admin123 (mặc định)"));

  } catch (err) {
    console.error("❌ [System Error] Lỗi khi khởi tạo tài khoản School:", err.message);
  }
};

// Cho phép chạy độc lập bằng lệnh node seed.js hoặc npm run seed
if (import.meta.url === `file://${process.argv[1]}` || process.argv[1]?.endsWith('seed.js')) {
  mongoose.connect(process.env.MONGO_URI)
    .then(async () => {
      await initSchoolAccount();
      process.exit();
    })
    .catch(err => {
      console.error("❌ Kết nối DB thất bại:", err.message);
      process.exit(1);
    });
}
