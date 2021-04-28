const express = require("express");

const router = express.Router();

const validateSchema = require("../../middleware/validateSchema");

const { requestBattleSchema } = require("./schema");

const { requestBattleController } = require("./controller");

router.post(
  "/requestBattle",
  validateSchema(requestBattleSchema),
  requestBattleController
);

module.exports = router;
