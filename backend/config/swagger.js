import swaggerJSDoc from "swagger-jsdoc";

const swaggerOptions = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "enghish 10 API",
      version: "1.0.0",
      description: "API quản lý học tiếng anh",
    },
    servers: [
      {
       // url: "https://appenglish-0uee.onrender.com",
          url: "http://localhost:5000",
      },
    ],

    tags: [
      {
        name: "Auth",
        description: "API xác thực người dùng",
      },
      {
        name: "Teachers",
        description: "Quản lý giảng viên (School)",
      },
      {
        name: "Students",
        description: "Quản lý học sinh (School / Admin)",
      },
      {
        name: "Classes",
        description: " Quản lý lớp học (School)",
      },
    
      {
        name: "Units",
        description: "Quản lý Unit (School / Teacher / Student)",
      },
      {
        name: "Lessons",
        description:
          " Quản lý bài học(có test full routes này: upload hình ảnh video audio dùng postman upload cho tao trên ui chạy đéo đc) (School CRUD, Teacher / Student xem)",
      },
      {
        name: "Vocabulary",
        description: "  Quản lý từ vựng theo lesson(School CRUD, Teacher / Student xem)",
      },
      {
        name: "Grammar",
        description: "   Quản lý ngữ pháp theo lesson",
      },
      {
        name: "Questions",
        description: " Bài tập / câu hỏi cho tất cả kỹ năng ",
      },
      {
        name: "Exams",
        description: " Chức năng Bài kiểm tra (15 phút / 45 phút) dành cho Giảng viên và Học sinh",
      },
       {
        name: "Assignments",
        description: "Thiết lập bài tập (Hạn nộp, công khai...) cho từng lớp/bài học",
      },
      {
        name: "Submissions",
        description: "Học sinh làm bài & nộp bài (Student only)",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
    },
  },
  apis: ["./docs/*.js"],
};

const swaggerSpec = swaggerJSDoc(swaggerOptions);
export default swaggerSpec;
