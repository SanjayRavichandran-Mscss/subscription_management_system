const db = require("../config/db");

module.exports = (action) => async (req, res, next) => {
  const finish = res.end;
  res.end = function (...args) {
    if (req.user && !["GET","HEAD"].includes(req.method) && res.statusCode < 400) {
      db.execute(
        "INSERT INTO audit_logs (user_id,action,entity_type,entity_id,new_values) VALUES (?, ?, ?, ?, ?)",
        [req.user.id, action || req.method, req.baseUrl.split("/").filter(Boolean).pop() || "unknown", req.params.id || null, JSON.stringify(req.body || {})]
      ).catch(error => console.error("Audit log write failed:", error.message));
    }
    return finish.apply(this, args);
  };
  next();
};
