import User from "../models/User.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import sendEmail from "../utils/mailHelper.js";
import VerificationEmail from "../utils/VerificationEmail.js";
import ForgotPasswordEmail from "../utils/ForgotPasswordEmail.js";

/* Tạo JWT */
const generateToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      role: user.role,
      username: user.username,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRES_IN,
    }
  );
};

/* REGISTER */
export const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    const exist = await User.findOne({ email });
    if (exist) return res.status(400).json({ message: "Email đã tồn tại" });

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      username,
      email,
      password: hashedPassword,
    });

    const token = generateToken(user);

    res.status(201).json({
      message: "Đăng ký thành công",
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* LOGIN */
export const login = async (req, res) => {
  try {
    const { username, password, use2FA } = req.body;

    const user = await User.findOne({ username });
    if (!user)
      return res.status(404).json({ message: "Không tìm thấy tài khoản" });

    if (user.isDisabled)
      return res.status(403).json({ message: "Tài khoản bị khóa" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "Sai mật khẩu" });

    // KIỂM TRA ĐĂNG NHẬP 2 LỚP
    if (use2FA || user.is2FAEnabled) {
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      
      user.otpCode = otp;
      user.otpExpire = Date.now() + 5 * 60 * 1000;
      await user.save();

      try {
        const emailHtml = VerificationEmail(user.username, otp);
        await sendEmail(user.email, "Mã xác thực đăng nhập 2 lớp", emailHtml);
      } catch (mailErr) {
        return res.status(500).json({ message: "Lỗi mạng: Không thể gửi mã OTP qua Email" });
      }

      return res.status(200).json({
        message: "Vui lòng nhập mã OTP đã được gửi về email của bạn",
        is2FARequired: true,
        username: user.username
      });
    }

    const token = generateToken(user);

    res.status(200).json({
      message: "Đăng nhập thành công",
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* VERIFY OTP */
export const verifyOTP = async (req, res) => {
  try {
    const { username, otp } = req.body;

    const user = await User.findOne({ username });
    if (!user) return res.status(404).json({ message: "User không tồn tại" });

    if (!user.otpCode || user.otpCode !== otp) {
      return res.status(400).json({ message: "Mã OTP không chính xác" });
    }

    if (Date.now() > user.otpExpire) {
      return res.status(400).json({ message: "Mã OTP đã hết hạn" });
    }

    user.otpCode = null;
    user.otpExpire = null;
    await user.save();

    const token = generateToken(user);

    res.status(200).json({
      message: "Xác thực thành công",
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* FORGOT PASSWORD */
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng với email này" });
    }

    // Tạo mã OTP 6 số
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Lưu OTP vào DB (hết hạn sau 10 phút)
    user.otpCode = otp;
    user.otpExpire = Date.now() + 10 * 60 * 1000;
    await user.save();

    // Gửi Email
    try {
      const emailHtml = ForgotPasswordEmail(user.username, otp);
      await sendEmail(user.email, "Mã xác thực khôi phục mật khẩu", emailHtml);
    } catch (mailErr) {
      return res.status(500).json({ message: "Lỗi mạng: Không thể gửi mã OTP qua Email" });
    }

    res.status(200).json({
      message: "Mã OTP khôi phục mật khẩu đã được gửi về email của bạn",
      email: user.email
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* RESET PASSWORD */
export const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "Người dùng không tồn tại" });

    // Kiểm tra mã OTP
    if (!user.otpCode || user.otpCode !== otp) {
      return res.status(400).json({ message: "Mã OTP không chính xác" });
    }

    if (Date.now() > user.otpExpire) {
      return res.status(400).json({ message: "Mã OTP đã hết hạn" });
    }

    // Mã hóa mật khẩu mới
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    
    // Xóa mã OTP sau khi sử dụng thành công
    user.otpCode = null;
    user.otpExpire = null;
    await user.save();

    res.status(200).json({ message: "Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại!" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* CHANGE PASSWORD (Authenticated) */
export const changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const userId = req.user.id; // Lấy từ middleware authenticate

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "Không tìm thấy người dùng" });

    // 1. Kiểm tra mật khẩu cũ
    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Mật khẩu cũ không chính xác" });
    }

    // 2. Kiểm tra mật khẩu mới không trùng mật khẩu cũ
    const isSame = await bcrypt.compare(newPassword, user.password);
    if (isSame) {
      return res.status(400).json({ message: "Mật khẩu mới không được trùng với mật khẩu cũ" });
    }

    // 3. Mã hóa và lưu mật khẩu mới
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    await user.save();

    res.status(200).json({ message: "Đổi mật khẩu thành công!" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
