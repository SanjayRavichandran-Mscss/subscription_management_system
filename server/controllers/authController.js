const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const db = require("../config/db");

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
  await db.execute("UPDATE users SET refresh_token=?, last_login_at=UTC_TIMESTAMP() WHERE id=?", [refreshToken, rows[0].id]);
  res.json({ success: true, token: sign(rows[0]), refreshToken, user: { id: rows[0].id, name: rows[0].name, email: rows[0].email, role: rows[0].role_name } });
};

exports.refresh = async (req, res) => {
  const [rows] = await db.execute(`SELECT u.*, r.name role_name FROM users u LEFT JOIN roles r ON r.id=u.role_id WHERE u.refresh_token=? LIMIT 1`, [req.body.refreshToken || ""]);
  if (!rows.length) return res.status(401).json({ success: false, message: "Refresh token is invalid." });
  res.json({ success: true, token: sign(rows[0]) });
};

exports.me = async (req, res) => res.json({ success: true, user: req.user });
