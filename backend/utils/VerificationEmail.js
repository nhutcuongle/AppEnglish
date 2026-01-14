const VerificationEmail = (username, otp) => {
  return `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Xác thực đăng nhập 2 lớp</title>
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
      color: #1e90ff;
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
      color: #1e90ff;
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
      <span class="emoji">🔐</span>
      <h1>Xác thực đăng nhập</h1>
    </div>

    <div class="content">
      <p>Xin chào <strong>${username}</strong>,</p>
      <p>Bạn đang thực hiện <strong>đăng nhập bảo mật 2 lớp</strong> vào hệ thống.</p>
      <p>Vui lòng nhập mã OTP dưới đây để hoàn tất việc đăng nhập:</p>
      <div class="otp">${otp}</div>
      <p><span class="emoji">⏳</span> Mã OTP có hiệu lực trong 5 phút. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>
      <p>Nếu bạn không thực hiện đăng nhập này, vui lòng đổi mật khẩu ngay lập tức.</p>
    </div>

    <div class="footer">
      <p>&copy; 2024 AppEnglish. Mọi quyền được bảo lưu.</p>
    </div>
  </div>
</body>
</html>`;
};

export default VerificationEmail;
