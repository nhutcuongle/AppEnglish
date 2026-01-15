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

export const registerUser = async ({ username, email, password }) => {
  const exist = await User.findOne({ email });
  if (exist) throw new Error("Email đã tồn tại");

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await User.create({
    username,
    email,
    password: hashedPassword,
  });

  return user;
};

export const loginUser = async ({ username, password, use2FA }) => {
  const user = await User.findOne({ username });
  if (!user) throw new Error("Không tìm thấy tài khoản");

  if (user.isDisabled) throw new Error("Tài khoản bị khóa");

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) throw new Error("Sai mật khẩu");

  // 2FA Logic
  if (use2FA || user.is2FAEnabled) {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.otpCode = otp;
    user.otpExpire = Date.now() + 5 * 60 * 1000;
    await user.save();

    console.log("📨 Sending OTP via Email...");
    const emailHtml = VerificationEmail(user.username, otp);
    await sendEmail(user.email, "Mã xác thực đăng nhập 2 lớp", emailHtml);

    return { is2FARequired: true, username: user.username };
  }

  const token = generateToken(user);
  return {
    token,
    user: {
      id: user._id,
      username: user.username,
      email: user.email,
      role: user.role,
    },
  };
};

export const verifyOTPCode = async ({ username, otp }) => {
  const user = await User.findOne({ username });
  if (!user) throw new Error("User không tồn tại");

  if (!user.otpCode || user.otpCode !== otp) throw new Error("Mã OTP không chính xác");
  if (Date.now() > user.otpExpire) throw new Error("Mã OTP đã hết hạn");

  user.otpCode = null;
  user.otpExpire = null;
  await user.save();

  const token = generateToken(user);
  return {
    token,
    user: {
      id: user._id,
      username: user.username,
      email: user.email,
      role: user.role,
    },
  };
};

export const requestForgotPassword = async (email) => {
  const user = await User.findOne({ email });
  if (!user) throw new Error("Không tìm thấy người dùng với email này");

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  user.otpCode = otp;
  user.otpExpire = Date.now() + 10 * 60 * 1000;
  await user.save();

  const emailHtml = ForgotPasswordEmail(user.username, otp);
  await sendEmail(user.email, "Mã xác thực khôi phục mật khẩu", emailHtml);

  return user.email;
};

export const resetUserPassword = async ({ email, otp, newPassword }) => {
  const user = await User.findOne({ email });
  if (!user) throw new Error("Người dùng không tồn tại");

  if (!user.otpCode || user.otpCode !== otp) throw new Error("Mã OTP không chính xác");
  if (Date.now() > user.otpExpire) throw new Error("Mã OTP đã hết hạn");

  const salt = await bcrypt.genSalt(10);
  user.password = await bcrypt.hash(newPassword, salt);
  user.otpCode = null;
  user.otpExpire = null;
  await user.save();

  return true;
};

export const changeUserPassword = async (userId, { oldPassword, newPassword }) => {
  const user = await User.findById(userId);
  if (!user) throw new Error("Không tìm thấy người dùng");

  const isMatch = await bcrypt.compare(oldPassword, user.password);
  if (!isMatch) throw new Error("Mật khẩu cũ không chính xác");

  const isSame = await bcrypt.compare(newPassword, user.password);
  if (isSame) throw new Error("Mật khẩu mới không được trùng với mật khẩu cũ");

  const salt = await bcrypt.genSalt(10);
  user.password = await bcrypt.hash(newPassword, salt);
  await user.save();

  return true;
};

export const toggle2FA = async (userId, is2FAEnabled) => {
  const user = await User.findById(userId);
  if (!user) throw new Error("Không tìm thấy người dùng");

  user.is2FAEnabled = is2FAEnabled;
  await user.save();
  return { is2FAEnabled: user.is2FAEnabled };
};
