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
          url: "https://appenglish-0uee.onrender.com",
      //  url: "http://localhost:5000",
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
        name: "Classes",
        description: " Quản lý lớp học (School)",
      },
      {
        name: "Students",
        description: "Quản lý học sinh (School / Admin)",
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
        description: "  Quản lý từ vựng theo lesson",
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
  apis: ["./routes/*.js"],
};

const swaggerSpec = swaggerJSDoc(swaggerOptions);
export default swaggerSpec;
