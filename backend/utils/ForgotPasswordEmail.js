const ForgotPasswordEmail = (username, otp) => {
  return `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Khôi phục mật khẩu</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 0;
      background-color: #f4f4f4;
      color: #333;
    }
    .container {
      max-width: 600px;
      margin: 30px auto;
      background: #ffffff;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
      text-align: center;
    }
    .header h1 {
      color: #ff4757;
      font-size: 24px;
      margin-bottom: 10px;
    }
    .header span {
      font-size: 48px;
    }
    .content {
      font-size: 16px;
      line-height: 1.6;
    }
    .otp {
      font-size: 28px;
      font-weight: bold;
      color: #ff4757;
      margin: 20px 0;
      letter-spacing: 4px;
    }
    .footer {
      font-size: 13px;
      color: #888;
      margin-top: 30px;
      border-top: 1px solid #eee;
      padding-top: 15px;
    }
    .emoji {
      font-size: 22px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <span class="emoji">🔑</span>
      <h1>Khôi phục mật khẩu</h1>
    </div>

    <div class="content">
      <p>Xin chào <strong>${username}</strong>,</p>
      <p>Hệ thống đã nhận được yêu cầu <strong>đặt lại mật khẩu</strong> của bạn.</p>
      <p>Vui lòng nhập mã OTP dưới đây để tiến hành thay đổi mật khẩu:</p>
      <div class="otp">${otp}</div>
      <p><span class="emoji">⏳</span> Mã OTP có hiệu lực trong 10 phút. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>
      <p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>
    </div>

    <div class="footer">
      <p>&copy; 2024 AppEnglish. Mọi quyền được bảo lưu.</p>
    </div>
  </div>
</body>
</html>`;
};

export default ForgotPasswordEmail;
