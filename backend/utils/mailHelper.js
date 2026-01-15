import nodemailer from "nodemailer";

const sendEmail = async (to, subject, html) => {
  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
      // Thêm timeout để tránh treo server quá lâu
      connectionTimeout: 10000, // 10 giây
      greetingTimeout: 10000,
      socketTimeout: 10000,
    });

    console.log("Debug Email Config:", {
      user: process.env.EMAIL_USER ? "Present" : "Missing",
      pass: process.env.EMAIL_PASS ? "Present" : "Missing"
    });

    const mailOptions = {
      from: `"AppEnglish Security" <${process.env.EMAIL_USER}>`,
      to,
      subject,
      html,
    };

    await transporter.sendMail(mailOptions);
    console.log(`📧 Email sent successfully to ${to}`);
  } catch (error) {
    console.error("❌ Email sending failed:", error.message);
    throw new Error("Không thể gửi mã xác thực qua Email");
  }
};

export default sendEmail;
