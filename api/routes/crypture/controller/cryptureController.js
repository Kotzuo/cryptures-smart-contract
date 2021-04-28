module.exports = (req, res) => {
  const { cryptureId } = req.params;

  res.send({ cryptureId });
};
