require("dotenv").config();

module.exports = {
  development: {
    username: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
    database: process.env.DB_NAME || "futurex_db",
    host: process.env.DB_HOST || "localhost",
    dialect: "mysql",
    logging: console.log,
  },
  test: {
    username: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
    database: process.env.DB_NAME + "_test" || "futurex_db_test",
    host: process.env.DB_HOST || "localhost",
    dialect: "mysql",
  },

  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    dialect: "mysql",
    dialectOptions: {
      connectTimeout: 10000, // optional, increase timeout
    },
  },
};
