const db = require("../config/db");

const allowedTables = new Set(["customers","users","roles","categories","products","product_variants","subscription_plans","quotations","subscriptions","billing_runs","invoices","taxes","discounts","payments","refunds","notifications","settings"]);

exports.list = table => async (req, res, next) => {
  if (!allowedTables.has(table)) return next(Object.assign(new Error("Resource unavailable"), { status: 404 }));
  try {
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, Number(req.query.limit) || 20));
    const offset = (page - 1) * limit;
    const search = String(req.query.search || "").trim();
    const [columns] = await db.execute(`SHOW COLUMNS FROM \`${table}\``);
    const textColumns = columns.filter(c => /char|text/i.test(c.Type)).map(c => c.Field);
    let where = "", params = [];
    if (search && textColumns.length) {
      where = ` WHERE ${textColumns.map(c => `\`${c}\` LIKE ?`).join(" OR ")}`;
      params = textColumns.map(() => `%${search}%`);
    }
    const [countRows] = await db.execute(`SELECT COUNT(*) total FROM \`${table}\`${where}`, params);
    const [rows] = await db.execute(`SELECT * FROM \`${table}\`${where} ORDER BY id DESC LIMIT ${limit} OFFSET ${offset}`, params);
    res.json({ success: true, data: rows, pagination: { page, limit, total: countRows[0].total } });
  } catch (error) { next(error); }
};

exports.create = table => async (req, res, next) => {
  try {
    const [columns] = await db.execute(`SHOW COLUMNS FROM \`${table}\``);
    const writable = columns.map(c => c.Field).filter(c => !["id","created_at","updated_at"].includes(c));
    const values = {};
    writable.forEach(c => { if (req.body[c] !== undefined && req.body[c] !== "") values[c] = req.body[c]; });
    const keys = Object.keys(values);
    if (!keys.length) return res.status(400).json({ success: false, message: "No valid fields supplied." });
    const [result] = await db.execute(`INSERT INTO \`${table}\` (${keys.map(k => `\`${k}\``).join(",")}) VALUES (${keys.map(() => "?").join(",")})`, keys.map(k => values[k]));
    res.status(201).json({ success: true, data: { id: result.insertId, ...values } });
  } catch (error) { next(error); }
};

exports.update = table => async (req, res, next) => {
  try {
    const [columns] = await db.execute(`SHOW COLUMNS FROM \`${table}\``);
    const writable = columns.map(c => c.Field).filter(c => !["id","created_at","updated_at"].includes(c));
    const keys = writable.filter(k => req.body[k] !== undefined);
    if (!keys.length) return res.status(400).json({ success: false, message: "No valid fields supplied." });
    await db.execute(`UPDATE \`${table}\` SET ${keys.map(k => `\`${k}\`=?`).join(",")}, updated_at=UTC_TIMESTAMP() WHERE id=?`, [...keys.map(k => req.body[k]), req.params.id]);
    res.json({ success: true });
  } catch (error) { next(error); }
};

