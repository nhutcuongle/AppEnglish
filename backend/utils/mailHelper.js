import nodemailer from "nodemailer";

const sendEmail = async (to, subject, html) => {
  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
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
    console.error("❌ Full error:", error);
    throw new Error("Không thể gửi mã xác thực qua Email");
  }
};

export default sendEmail;
