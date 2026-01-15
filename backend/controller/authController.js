import * as authService from "../service/authService.js";

/* REGISTER */
export const register = async (req, res) => {
  try {
    await authService.registerUser(req.body);
    res.status(201).json({
      message: "Đăng ký thành công",
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

/* LOGIN */
export const login = async (req, res) => {
  try {
    const result = await authService.loginUser(req.body);
    
    if (result.is2FARequired) {
      return res.status(200).json({
        message: "Vui lòng nhập mã OTP đã được gửi về email của bạn",
        is2FARequired: true,
        username: result.username
      });
    }

    res.status(200).json({
      message: "Đăng nhập thành công",
      token: result.token,
      user: result.user,
    });
  } catch (err) {
    const statusCode = err.message === "Không tìm thấy tài khoản" ? 404 : 
                      err.message === "Tài khoản bị khóa" ? 403 : 401;
    res.status(statusCode).json({ message: err.message });
  }
};

/* VERIFY OTP */
export const verifyOTP = async (req, res) => {
  try {
    const result = await authService.verifyOTPCode(req.body);
    res.status(200).json({
      message: "Xác thực thành công",
      token: result.token,
      user: result.user,
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

/* FORGOT PASSWORD */
export const forgotPassword = async (req, res) => {
  try {
    const email = await authService.requestForgotPassword(req.body.email);
    res.status(200).json({
      message: "Mã OTP khôi phục mật khẩu đã được gửi về email của bạn",
      email
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

/* RESET PASSWORD */
export const resetPassword = async (req, res) => {
  try {
    await authService.resetUserPassword(req.body);
    res.status(200).json({ message: "Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại!" });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

/* CHANGE PASSWORD (Authenticated) */
export const changePassword = async (req, res) => {
  try {
    await authService.changeUserPassword(req.user.id, req.body);
    res.status(200).json({ message: "Đổi mật khẩu thành công!" });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

/* TOGGLE 2FA (Authenticated) */
export const toggle2FA = async (req, res) => {
  try {
    const result = await authService.toggle2FA(req.user.id, req.body.is2FAEnabled);
    res.status(200).json({ message: "Cập nhật bảo mật 2 lớp thành công!", data: result });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};
