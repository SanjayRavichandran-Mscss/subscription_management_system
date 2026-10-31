const rateLimit = require("express-rate-limit");

module.exports = options => rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 100,
  standardHeaders: "draft-7",
  legacyHeaders: false,
  handler: (req, res) => res.status(429).json({
    success: false,
    message: "Too many requests. Please wait a moment and try again."
  }),
  ...options
});
