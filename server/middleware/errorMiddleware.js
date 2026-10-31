const { JsonWebTokenError, TokenExpiredError } = require("jsonwebtoken");

module.exports = (error, req, res, next) => {
  if (error instanceof JsonWebTokenError || error instanceof TokenExpiredError) {
    return res.status(401).json({ success: false, message: "Your session has expired. Please sign in again." });
  }

  if (error?.code === "ER_DUP_ENTRY") {
    return res.status(409).json({ success: false, message: "A record with this value already exists." });
  }

  if (error?.code === "ER_ROW_IS_REFERENCED_2" || error?.code === "ER_ROW_IS_REFERENCED") {
    return res.status(409).json({ success: false, message: "This record cannot be deleted because it is used by another screen." });
  }

  if (error?.code === "ER_NO_REFERENCED_ROW_2") {
    return res.status(409).json({ success: false, message: "The selected related record is no longer available. Refresh and try again." });
  }

  if (error?.code === "ER_TRUNCATED_WRONG_VALUE" || error?.code === "ER_WRONG_VALUE" || error?.code === "WARN_DATA_TRUNCATED") {
    return res.status(422).json({ success: false, message: "One of the selected values is invalid. Please choose an option from the available values." });
  }

  const status = Number.isInteger(error?.status) ? error.status : 500;
  if (status >= 500) console.error(`[${req.method} ${req.originalUrl}]`, error);
  return res.status(status).json({
    success: false,
    message: status >= 500 ? "An unexpected server error occurred." : error.message
  });
};
