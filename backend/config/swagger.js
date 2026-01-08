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
        name: "Units",
        description: "Quản lý Unit (School / Teacher / Student)",
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
