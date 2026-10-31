const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const db = require("../config/db");
const notification = require("../services/notificationService");

const sign = user => jwt.sign({ sub: user.id, role: user.role_name || "STAFF" }, process.env.JWT_SECRET || "development-only-secret", { expiresIn: process.env.JWT_EXPIRES || "8h" });

exports.register = async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !/^(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{9,}$/.test(password || "")) {
    return res.status(400).json({ success: false, message: "Password must have 9+ characters and uppercase, lowercase, and special characters." });
  }
  const [existing] = await db.execute("SELECT id FROM users WHERE email = ?", [email.toLowerCase()]);
  if (existing.length) return res.status(409).json({ success: false, message: "An account with this email already exists." });
  const hash = await bcrypt.hash(password, 12);
  const [role] = await db.execute("SELECT id FROM roles WHERE name = 'CUSTOMER' LIMIT 1");
  const [result] = await db.execute("INSERT INTO users (name, email, password_hash, role_id, status) VALUES (?, ?, ?, ?, 'active')", [name.trim(), email.toLowerCase(), hash, role[0]?.id || null]);
  res.status(201).json({ success: true, user: { id: result.insertId, name, email: email.toLowerCase() } });
};

exports.login = async (req, res) => {
  const [rows] = await db.execute(`SELECT u.*, r.name role_name FROM users u LEFT JOIN roles r ON r.id=u.role_id WHERE u.email=? LIMIT 1`, [String(req.body.email || "").toLowerCase()]);
  if (!rows.length || rows[0].status !== "active" || !(await bcrypt.compare(req.body.password || "", rows[0].password_hash))) {
    return res.status(401).json({ success: false, message: "Invalid email or password." });
  }
  const refreshToken = crypto.randomBytes(48).toString("hex");
  await db.execute(
    "INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY))",
    [rows[0].id, crypto.createHash("sha256").update(refreshToken).digest("hex")]
  );
  await db.execute("UPDATE users SET refresh_token=?, last_login_at=UTC_TIMESTAMP() WHERE id=?", [refreshToken, rows[0].id]);
  res.json({ success: true, token: sign(rows[0]), refreshToken, user: { id: rows[0].id, name: rows[0].name, email: rows[0].email, role: rows[0].role_name } });
};

exports.refresh = async (req, res) => {
  const supplied = req.body.refreshToken || "";
  const hash = crypto.createHash("sha256").update(supplied).digest("hex");
  const [rows] = await db.execute(`SELECT u.*, r.name role_name, rt.id token_id FROM users u JOIN refresh_tokens rt ON rt.user_id=u.id LEFT JOIN roles r ON r.id=u.role_id WHERE rt.token_hash=? AND rt.revoked_at IS NULL AND rt.expires_at > UTC_TIMESTAMP() LIMIT 1`, [hash]);
  if (!rows.length) return res.status(401).json({ success: false, message: "Refresh token is invalid." });
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    await connection.execute("UPDATE refresh_tokens SET revoked_at=UTC_TIMESTAMP() WHERE id=? AND revoked_at IS NULL", [rows[0].token_id]);
    const replacement = crypto.randomBytes(48).toString("hex");
    await connection.execute(
      "INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY))",
      [rows[0].id, crypto.createHash("sha256").update(replacement).digest("hex")]
    );
    await connection.commit();
    res.json({ success: true, token: sign(rows[0]), refreshToken: replacement, user: { id: rows[0].id, name: rows[0].name, email: rows[0].email, role: rows[0].role_name } });
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

exports.forgotPassword = async (req, res) => {
  const [users] = await db.execute("SELECT id,email,name FROM users WHERE email=? LIMIT 1", [String(req.body.email || "").toLowerCase()]);
  if (users.length) {
    const rawToken = crypto.randomBytes(32).toString("hex");
    await db.execute("UPDATE password_reset_tokens SET used_at=UTC_TIMESTAMP() WHERE user_id=? AND used_at IS NULL", [users[0].id]);
    await db.execute(
      "INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 1 HOUR))",
      [users[0].id, crypto.createHash("sha256").update(rawToken).digest("hex")]
    );
    const resetUrl = `${process.env.CLIENT_URL || "http://localhost:5173"}/reset-password?token=${rawToken}`;
    await notification.sendEmail({
      to: users[0].email,
      subject: "Reset your Brightloop ERP password",
      text: `Reset your password using this link: ${resetUrl}`,
      html: `<p>Reset your Brightloop ERP password.</p><p><a href="${resetUrl}">Reset password</a></p><p>This link expires in one hour.</p>`
    });
    if (process.env.NODE_ENV !== "production") console.info(`Password reset token for ${users[0].email}: ${rawToken}`);
  }
  res.json({ success: true, message: "If the account exists, password reset instructions have been sent." });
};

exports.resetPassword = async (req, res) => {
  const { token, password } = req.body;
  if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{9,}$/.test(password || "")) {
    return res.status(400).json({ success: false, message: "Password must have 9+ characters and uppercase, lowercase, and special characters." });
  }
  const hash = crypto.createHash("sha256").update(token || "").digest("hex");
  const [tokens] = await db.execute("SELECT id,user_id FROM password_reset_tokens WHERE token_hash=? AND used_at IS NULL AND expires_at > UTC_TIMESTAMP() LIMIT 1", [hash]);
  if (!tokens.length) return res.status(400).json({ success: false, message: "Reset token is invalid or has expired." });
  const passwordHash = await bcrypt.hash(password, 12);
  await db.execute("UPDATE users SET password_hash=?, refresh_token=NULL WHERE id=?", [passwordHash, tokens[0].user_id]);
  await db.execute("UPDATE password_reset_tokens SET used_at=UTC_TIMESTAMP() WHERE id=?", [tokens[0].id]);
  await db.execute("UPDATE refresh_tokens SET revoked_at=UTC_TIMESTAMP() WHERE user_id=? AND revoked_at IS NULL", [tokens[0].user_id]);
  res.json({ success: true, message: "Password has been reset. Please sign in again." });
};

exports.logout = async (req, res) => {
  await db.execute("UPDATE refresh_tokens SET revoked_at=UTC_TIMESTAMP() WHERE user_id=? AND revoked_at IS NULL", [req.user.id]);
  await db.execute("UPDATE users SET refresh_token=NULL WHERE id=?", [req.user.id]);
  res.json({ success: true, message: "Signed out successfully." });
};

exports.me = async (req, res) => res.json({ success: true, user: req.user });
