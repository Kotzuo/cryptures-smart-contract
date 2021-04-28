const express = require("express");

const router = express.Router();

const { cryptureController } = require("./controller");

router.get("/:cryptureId", cryptureController);

module.exports = router;
