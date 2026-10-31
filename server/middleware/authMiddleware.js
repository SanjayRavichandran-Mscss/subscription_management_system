const jwt = require("jsonwebtoken");
const db = require("../config/db");

module.exports = async (req, res, next) => {
  const token = (req.headers.authorization || "").replace(/^Bearer\s+/i, "");
  if (!token) return res.status(401).json({ success: false, message: "Authentication required." });
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET || "development-only-secret");
    const [rows] = await db.execute(`SELECT u.id,u.name,u.email,u.status,r.name role_name FROM users u LEFT JOIN roles r ON r.id=u.role_id WHERE u.id=? LIMIT 1`, [payload.sub]);
    if (!rows.length || rows[0].status !== "active") return res.status(401).json({ success: false, message: "Account is inactive." });
    req.user = { ...rows[0], role: rows[0].role_name };
    next();
  } catch {
    res.status(401).json({ success: false, message: "Session has expired. Please sign in again." });
  }
};
