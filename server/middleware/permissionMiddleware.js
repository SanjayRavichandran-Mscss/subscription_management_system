const db = require("../config/db");

module.exports = permission => async (req, res, next) => {
  try {
    if (!req.user) return res.status(401).json({ success: false, message: "Authentication required." });
    if (req.user.role === "SUPER_ADMIN") return next();
    const [rows] = await db.execute(
      `SELECT 1 FROM role_permissions rp
       JOIN permissions p ON p.id=rp.permission_id
       JOIN roles r ON r.id=rp.role_id
       WHERE r.name=? AND p.permission_key=? LIMIT 1`,
      [req.user.role, permission]
    );
    if (!rows.length) return res.status(403).json({ success: false, message: "You do not have permission to perform this action." });
    next();
  } catch (error) {
    next(error);
  }
};
