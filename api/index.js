require("dotenv").config({
  path: "../.env",
});

const express = require("express");
const app = express();
const cors = require("cors");
const morgan = require("morgan");

const router = require("./routes");
const ether = require("./ether");

app.use(
  cors({
    credentials: true,
    origin: process.env.FRONT_URL,
  })
);
app.use(express.json());
app.use(morgan("dev"));
app.use(router);

app.listen(process.env.API_PORT, () => {
  console.log("Api rodando na porta " + process.env.API_PORT);
});
