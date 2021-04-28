const express = require("express");
const router = express.Router();

const crypture = require("./crypture");
const battle = require("./battle");

router.use("/crypture", crypture);
router.use("/battle", battle);

module.exports = router;
