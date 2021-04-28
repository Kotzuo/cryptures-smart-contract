const Joi = require("joi");

const requestBattleSchema = Joi.object({
  opponent: Joi.string().required(),
  ammount: Joi.string().required(),
});

module.exports = {
  requestBattleSchema,
};
