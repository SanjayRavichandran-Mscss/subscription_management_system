const { validationResult } = require("express-validator");

module.exports.validate = validations => [
  ...(Array.isArray(validations) ? validations : []),
  (req, res, next) => {
    const errors = validationResult(req);
    if (errors.isEmpty()) return next();

    return res.status(422).json({
      success: false,
      message: "Please correct the highlighted fields.",
      errors: errors.array().map(error => ({
        field: error.path || error.param || "unknown",
        message: error.msg
      }))
    });
  }
];
